import type { AgentToolResult } from "@earendil-works/pi-agent-core";
import type { Message } from "@earendil-works/pi-ai";
import type { AgentConfig, AgentDiscoveryResult, AgentScope } from "./agents.ts";
import {
	MAX_CONCURRENCY,
	MAX_PARALLEL_TASKS,
	type ChainItem,
	type ModelFallback,
	type ParallelTaskParams,
	type SingleResult,
	type SubagentDetails,
	type SubagentParams,
} from "./schema.ts";
import type { RunAgentOptions } from "./runner.ts";

export type OnUpdate = (partial: AgentToolResult<SubagentDetails>) => void;
export type SubagentToolResult = AgentToolResult<SubagentDetails> & { isError?: boolean };

export interface ExecutionContext {
	cwd: string;
	hasUI: boolean;
	ui?: { confirm(title: string, message: string): Promise<boolean> };
	signal?: AbortSignal;
	onUpdate?: OnUpdate;
	fallbackModel?: string;
	fallbackThinking: string;
}

export interface OutputWriter {
	write(filePath: string, output: string): Promise<void>;
}

export interface ExecutionDependencies {
	discoverAgents(cwd: string, scope: AgentScope): AgentDiscoveryResult;
	runAgent(options: RunAgentOptions): Promise<SingleResult>;
	outputWriter: OutputWriter;
	confirmProjectAgents(names: string[], directory: string | null, context: ExecutionContext): Promise<boolean>;
}

function finalOutput(messages: Message[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (message.role === "assistant") {
			for (const part of message.content) if (part.type === "text") return part.text;
		}
	}
	return "";
}

function isFailedResult(result: SingleResult): boolean {
	return result.exitCode !== 0 || result.stopReason === "error" || result.stopReason === "aborted";
}

function resultOutput(result: SingleResult): string {
	if (isFailedResult(result)) return result.errorMessage || result.stderr || finalOutput(result.messages) || "(no output)";
	return finalOutput(result.messages) || "(no output)";
}

function truncateOutput(output: string): string {
	const cap = 50 * 1024;
	const byteLength = Buffer.byteLength(output, "utf8");
	if (byteLength <= cap) return output;
	let truncated = "";
	let truncatedBytes = 0;
	for (const character of output) {
		const characterBytes = Buffer.byteLength(character, "utf8");
		if (truncatedBytes + characterBytes > cap) break;
		truncated += character;
		truncatedBytes += characterBytes;
	}
	return `${truncated}\n\n[Output truncated: ${byteLength - truncatedBytes} bytes omitted. Full output preserved in tool details.]`;
}

function makeResultDetails(
	mode: "single" | "parallel" | "chain",
	agentScope: AgentScope,
	discovery: AgentDiscoveryResult,
	totalSteps?: number,
) {
	return (results: SingleResult[]): SubagentDetails => ({
		mode,
		agentScope,
		projectAgentsDir: discovery.projectAgentsDir,
		results,
		totalSteps,
	});
}

function runnerOptions(
	context: ExecutionContext,
	agents: AgentConfig[],
	commonFallback: ModelFallback,
	makeDetails: (results: SingleResult[]) => SubagentDetails,
	options: {
		agentName: string;
		task: string;
		model?: string;
		modelFallback?: ModelFallback;
		cwd?: string;
		session?: string;
		step?: number;
	},
): RunAgentOptions {
	return {
		defaultCwd: context.cwd,
		agents,
		agentName: options.agentName,
		task: options.task,
		modelOverride: options.model,
		modelFallback: options.modelFallback ?? commonFallback,
		fallbackModel: context.fallbackModel,
		fallbackThinking: context.fallbackThinking,
		cwd: options.cwd,
		session: options.session,
		step: options.step,
		signal: context.signal,
		onUpdate: context.onUpdate,
		makeDetails,
	};
}

export async function executeSubagent(
	params: SubagentParams,
	context: ExecutionContext,
	deps: ExecutionDependencies,
): Promise<SubagentToolResult> {
	const agentScope: AgentScope = params.agentScope ?? "user";
	const modelFallback: ModelFallback = params.modelFallback ?? "current";
	const discovery = deps.discoverAgents(context.cwd, agentScope);
	const agents = discovery.agents;
	const hasChain = (params.chain?.length ?? 0) > 0;
	const hasTasks = (params.tasks?.length ?? 0) > 0;
	const hasSingle = Boolean(params.agent && params.task);
	const modeCount = Number(hasChain) + Number(hasTasks) + Number(hasSingle);
	const mode = hasChain ? "chain" : hasTasks ? "parallel" : "single";
	const details = (kind: "single" | "parallel" | "chain", totalSteps?: number) =>
		makeResultDetails(kind, agentScope, discovery, totalSteps);

	if (modeCount !== 1) {
		const available = agents.map((agent) => `${agent.name} (${agent.source})`).join(", ") || "none";
		return {
			content: [{ type: "text", text: `Invalid parameters. Provide exactly one mode.\nAvailable agents: ${available}` }],
			details: details("single")([]),
		};
	}

	if ((agentScope === "project" || agentScope === "both") && (params.confirmProjectAgents ?? true) && context.hasUI) {
		const requested = new Set<string>();
		if (params.chain) for (const item of params.chain) requested.add(item.agent);
		if (params.tasks) for (const item of params.tasks) requested.add(item.agent);
		if (params.agent) requested.add(params.agent);
		const projectNames = Array.from(requested)
			.map((name) => agents.find((agent) => agent.name === name))
			.filter((agent): agent is AgentConfig => agent?.source === "project")
			.map((agent) => agent.name);
		if (projectNames.length > 0) {
			const ok = await deps.confirmProjectAgents(projectNames, discovery.projectAgentsDir, context);
			if (!ok) {
				return {
					content: [{ type: "text", text: "Canceled: project-local agents not approved." }],
					details: details(mode)([]),
				};
			}
		}
	}

	if (params.chain && params.chain.length > 0) {
		const results: SingleResult[] = [];
		let previousOutput = "";
		for (let i = 0; i < params.chain.length; i++) {
			const item: ChainItem = params.chain[i];
			const task = item.task.replace(/\{previous\}/g, previousOutput);
			const chainDetails = details("chain", params.chain.length);
			const chainUpdate: OnUpdate | undefined = context.onUpdate
				? (partial) => {
						const current = partial.details?.results[0];
						if (current) context.onUpdate!({ content: partial.content, details: chainDetails([...results, current]) });
				  }
				: undefined;
			const result = await deps.runAgent(
				runnerOptions({ ...context, onUpdate: chainUpdate }, agents, modelFallback, chainDetails, {
					agentName: item.agent,
					task,
					model: item.model,
					modelFallback: item.modelFallback,
					cwd: item.cwd,
					step: i + 1,
				}),
			);
			results.push(result);
			if (isFailedResult(result)) {
				return {
					content: [{ type: "text", text: `Chain stopped at step ${i + 1} (${item.agent}): ${resultOutput(result)}` }],
					details: details("chain", params.chain.length)(results),
					isError: true,
				};
			}
			previousOutput = finalOutput(result.messages);
		}
		const output = finalOutput(results[results.length - 1].messages) || "(no output)";
		const last = params.chain[params.chain.length - 1];
		if (last.outputFile) {
			try {
				await deps.outputWriter.write(last.outputFile, output);
			} catch (error) {
				console.error(`[subagent] Failed to save output to ${last.outputFile}:`, error);
			}
		}
		return { content: [{ type: "text", text: output }], details: details("chain", params.chain.length)(results) };
	}

	if (params.tasks && params.tasks.length > 0) {
		if (params.tasks.length > MAX_PARALLEL_TASKS) {
			return {
				content: [{ type: "text", text: `Too many parallel tasks (${params.tasks.length}). Max is ${MAX_PARALLEL_TASKS}.` }],
				details: details("parallel")([]),
			};
		}
		const allResults: SingleResult[] = params.tasks.map((task: ParallelTaskParams) => ({
			agent: task.agent,
			agentSource: "unknown",
			task: task.task,
			exitCode: -1,
			messages: [],
			stderr: "",
			usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
		}));
		const emitParallelUpdate = () => {
			if (!context.onUpdate) return;
			const running = allResults.filter((result) => result.exitCode === -1).length;
			const done = allResults.length - running;
			context.onUpdate({
				content: [{ type: "text", text: `Parallel: ${done}/${allResults.length} done, ${running} running...` }],
				details: details("parallel")([...allResults]),
			});
		};
		const results = await mapWithConcurrencyLimit(params.tasks, MAX_CONCURRENCY, async (task, index) => {
			const result = await deps.runAgent(
				runnerOptions({
					...context,
					onUpdate: (partial) => {
							if (partial.details?.results[0]) {
								// Keep placeholder status until runAgent resolves. Preserve streamed state.
								allResults[index] = { ...partial.details.results[0], exitCode: -1 };
								emitParallelUpdate();
							}
						},
			}, agents, modelFallback, details("parallel"), {
					agentName: task.agent,
					task: task.task,
					model: task.model,
					modelFallback: task.modelFallback,
					cwd: task.cwd,
				}),
			);
			allResults[index] = result;
			emitParallelUpdate();
			return result;
		});
		const successCount = results.filter((result) => !isFailedResult(result)).length;
		const summaries = results.map((result) => {
			const output = truncateOutput(resultOutput(result));
			const status = isFailedResult(result)
				? `failed${result.stopReason && result.stopReason !== "end" ? ` (${result.stopReason})` : ""}`
				: "completed";
			return `### [${result.agent}] ${status}\n\n${output}`;
		});
		for (let i = 0; i < results.length; i++) {
			const task = params.tasks[i];
			if (task.outputFile && !isFailedResult(results[i])) {
				try {
					await deps.outputWriter.write(task.outputFile, resultOutput(results[i]));
				} catch (error) {
					console.error(`[subagent] Failed to save output to ${task.outputFile}:`, error);
				}
			}
		}
		return {
			content: [{ type: "text", text: `Parallel: ${successCount}/${results.length} succeeded\n\n${summaries.join("\n\n---\n\n")}` }],
			details: details("parallel")(results),
		};
	}

	if (params.agent && params.task) {
		const singleDetails = details("single");
		const result = await deps.runAgent(
			runnerOptions(context, agents, modelFallback, singleDetails, {
				agentName: params.agent,
				task: params.task,
				model: params.model,
				cwd: params.cwd,
				session: params.session,
			}),
		);
		if (isFailedResult(result)) {
			return {
				content: [{ type: "text", text: `Agent ${result.stopReason || "failed"}: ${resultOutput(result)}` }],
				details: singleDetails([result]),
				isError: true,
			};
		}
		const output = finalOutput(result.messages) || "(no output)";
		if (params.outputFile) {
			try {
				await deps.outputWriter.write(params.outputFile, output);
			} catch (error) {
				console.error(`[subagent] Failed to save output to ${params.outputFile}:`, error);
			}
		}
		return { content: [{ type: "text", text: output }], details: singleDetails([result]) };
	}

	const available = agents.map((agent) => `${agent.name} (${agent.source})`).join(", ") || "none";
	return { content: [{ type: "text", text: `Invalid parameters. Available agents: ${available}` }], details: details("single")([]) };
}

export async function mapWithConcurrencyLimit<TIn, TOut>(
	items: TIn[],
	concurrency: number,
	fn: (item: TIn, index: number) => Promise<TOut>,
): Promise<TOut[]> {
	if (items.length === 0) return [];
	const limit = Math.max(1, Math.min(concurrency, items.length));
	const results: TOut[] = new Array(items.length);
	let nextIndex = 0;
	const workers = new Array(limit).fill(null).map(async () => {
		while (true) {
			const current = nextIndex++;
			if (current >= items.length) return;
			results[current] = await fn(items[current], current);
		}
	});
	await Promise.all(workers);
	return results;
}
