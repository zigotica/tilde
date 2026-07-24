import { spawn as nodeSpawn, type ChildProcess } from "node:child_process";
import { createHash } from "node:crypto";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { AgentToolResult } from "@earendil-works/pi-agent-core";
import type { Message } from "@earendil-works/pi-ai";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import type { AgentConfig } from "./agents.ts";
import type { SingleResult, SubagentDetails } from "./schema.ts";

export interface ProcessOptions {
	cwd: string;
	shell: false;
	stdio: ["ignore", "pipe", "pipe"];
}

export interface ProcessStream {
	onData(callback: (chunk: Uint8Array) => void): void;
}

export interface ProcessHandle {
	stdout: ProcessStream;
	stderr: ProcessStream;
	onClose(callback: (code: number | null) => void): void;
	onError(callback: (error: Error) => void): void;
	kill(signal?: NodeJS.Signals): boolean;
	readonly killed: boolean;
}

/** Raw process boundary. It carries byte chunks and lifecycle events only. */
export interface ProcessRunner {
	spawn(command: string, args: string[], options: ProcessOptions): ProcessHandle;
}

class ChildProcessStream implements ProcessStream {
	private readonly stream: NodeJS.ReadableStream;

	constructor(stream: NodeJS.ReadableStream) {
		this.stream = stream;
	}

	onData(callback: (chunk: Uint8Array) => void): void {
		this.stream.on("data", (chunk: Buffer | string) => callback(typeof chunk === "string" ? Buffer.from(chunk) : chunk));
	}
}

class ChildProcessHandle implements ProcessHandle {
	readonly stdout: ProcessStream;
	readonly stderr: ProcessStream;
	private readonly child: ChildProcess;

	constructor(child: ChildProcess) {
		this.child = child;
		this.stdout = new ChildProcessStream(child.stdout!);
		this.stderr = new ChildProcessStream(child.stderr!);
	}

	onClose(callback: (code: number | null) => void): void {
		this.child.on("close", callback);
	}

	onError(callback: (error: Error) => void): void {
		this.child.on("error", callback);
	}

	kill(signal?: NodeJS.Signals): boolean {
		return this.child.kill(signal);
	}

	get killed(): boolean {
		return this.child.killed;
	}
}

export const productionProcessRunner: ProcessRunner = {
	spawn(command, args, options) {
		return new ChildProcessHandle(nodeSpawn(command, args, options));
	},
};

export function createProductionProcessRunner(): ProcessRunner {
	return productionProcessRunner;
}

export interface PromptFile {
	path: string;
	cleanup(): Promise<void>;
}

export interface PromptFileStore {
	create(agentName: string, prompt: string): Promise<PromptFile>;
}

export const productionPromptFileStore: PromptFileStore = {
	async create(agentName, prompt) {
		const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-subagent-"));
		const safeName = agentName.replace(/[^\w.-]+/g, "_");
		const filePath = path.join(dir, `prompt-${safeName}.md`);
		await withFileMutationQueue(filePath, async () => {
			await fs.promises.writeFile(filePath, prompt, { encoding: "utf-8", mode: 0o600 });
		});
		return {
			path: filePath,
			async cleanup() {
				try {
					await fs.promises.unlink(filePath);
				} catch {
					/* ignore */
				}
				try {
					await fs.promises.rmdir(dir);
				} catch {
					/* ignore */
				}
			},
		};
	},
};

export function createPromptFileStore(): PromptFileStore {
	return productionPromptFileStore;
}

export interface PiInvocation {
	command: string;
	args: string[];
}

export function getPiInvocation(args: string[]): PiInvocation {
	const currentScript = process.argv[1];
	const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
	if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}

	const execName = path.basename(process.execPath).toLowerCase();
	const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
	if (!isGenericRuntime) return { command: process.execPath, args };
	return { command: "pi", args };
}

export interface RunAgentOptions {
	defaultCwd: string;
	agents: AgentConfig[];
	agentName: string;
	task: string;
	modelOverride?: string;
	modelFallback: "stop" | "current";
	fallbackModel?: string;
	fallbackThinking: string;
	cwd?: string;
	session?: string;
	step?: number;
	signal?: AbortSignal;
	onUpdate?: (partial: AgentToolResult<SubagentDetails>) => void;
	makeDetails: (results: SingleResult[]) => SubagentDetails;
}

export interface AgentRunnerDeps {
	processRunner: ProcessRunner;
	promptFileStore: PromptFileStore;
	getInvocation?: (args: string[]) => PiInvocation;
}

function getFinalOutput(messages: Message[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (message.role === "assistant") {
			for (const part of message.content) if (part.type === "text") return part.text;
		}
	}
	return "";
}

function emptyUsage() {
	return { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 };
}

function addMessage(result: SingleResult, message: Message, emit: () => void): void {
	result.messages.push(message);
	if (message.role === "assistant") {
		result.usage.turns++;
		const usage = message.usage;
		if (usage) {
			result.usage.input += usage.input || 0;
			result.usage.output += usage.output || 0;
			result.usage.cacheRead += usage.cacheRead || 0;
			result.usage.cacheWrite += usage.cacheWrite || 0;
			result.usage.cost += usage.cost?.total || 0;
			result.usage.contextTokens = usage.totalTokens || 0;
		}
		if (message.model) result.model = result.model || message.model;
		if (message.stopReason) result.stopReason = message.stopReason;
		if (message.errorMessage) result.errorMessage = message.errorMessage;
	}
	emit();
}

function handleEvent(result: SingleResult, line: string, emit: () => void): void {
	if (!line.trim()) return;
	let event: any;
	try {
		event = JSON.parse(line);
	} catch {
		return;
	}
	if (event.type === "message_end" && event.message) addMessage(result, event.message as Message, emit);
	if (event.type === "tool_result_end" && event.message) result.messages.push(event.message as Message);
	if (event.type === "tool_result_end" && event.message) emit();
}

async function runProcess(
	args: string[],
	options: RunAgentOptions,
	deps: AgentRunnerDeps,
	result: SingleResult,
	allowAbort: boolean,
): Promise<{ exitCode: number; wasAborted: boolean }> {
	const invocation = (deps.getInvocation ?? getPiInvocation)(args);
	const proc = deps.processRunner.spawn(invocation.command, invocation.args, {
		cwd: options.cwd ?? options.defaultCwd,
		shell: false,
		stdio: ["ignore", "pipe", "pipe"],
	});
	let buffer = "";
	let wasAborted = false;
	let settled = false;

	return new Promise((resolve) => {
		const processLine = (line: string) => handleEvent(result, line, () => options.onUpdate?.({
			content: [{ type: "text", text: getFinalOutput(result.messages) || "(running...)" }],
			details: options.makeDetails([result]),
		}));
		proc.stdout.onData((chunk) => {
			buffer += Buffer.from(chunk).toString();
			const lines = buffer.split("\n");
			buffer = lines.pop() || "";
			for (const line of lines) processLine(line);
		});
		proc.stderr.onData((chunk) => {
			result.stderr += Buffer.from(chunk).toString();
		});
		proc.onClose((code) => {
			if (buffer.trim()) processLine(buffer);
			if (!settled) {
				settled = true;
				resolve({ exitCode: code ?? 0, wasAborted });
			}
		});
		proc.onError(() => {
			if (!settled) {
				settled = true;
				resolve({ exitCode: 1, wasAborted });
			}
		});

		if (allowAbort && options.signal) {
			const killProc = () => {
				wasAborted = true;
				proc.kill("SIGTERM");
				const timer = setTimeout(() => {
					if (!proc.killed) proc.kill("SIGKILL");
				}, 5000);
				(timer as any).unref?.();
			};
			if (options.signal.aborted) killProc();
			else options.signal.addEventListener("abort", killProc, { once: true });
		}
	});
}

function isModelFailure(result: SingleResult): boolean {
	const stderr = result.stderr.toLowerCase();
	const error = (result.errorMessage || "").toLowerCase();
	return (
		stderr.includes("model") || stderr.includes("quota") || stderr.includes("credit") || stderr.includes("balance") ||
		stderr.includes("billing") || stderr.includes("payment") || stderr.includes("insufficient") ||
		stderr.includes("rate limit") || stderr.includes("overloaded") || stderr.includes("api key") ||
		stderr.includes("not found") || stderr.includes("invalid") || error.includes("credit") || error.includes("balance") ||
		error.includes("billing") || error.includes("payment") || error.includes("insufficient") || error.includes("rate limit") ||
		error.includes("overloaded") || result.stopReason === "error" || result.stopReason === "overloaded" ||
		result.stopReason === "credit_limit" || result.stopReason === "billing"
	);
}

export async function runSingleAgent(options: RunAgentOptions, deps: AgentRunnerDeps): Promise<SingleResult> {
	const agent = options.agents.find((candidate) => candidate.name === options.agentName);
	if (!agent) {
		const available = options.agents.map((candidate) => `"${candidate.name}"`).join(", ") || "none";
		return {
			agent: options.agentName,
			agentSource: "unknown",
			task: options.task,
			exitCode: 1,
			messages: [],
			stderr: `Unknown agent: "${options.agentName}". Available agents: ${available}.`,
			usage: emptyUsage(),
			step: options.step,
		};
	}

	const args = ["--mode", "json", "-p"];
	if (options.session) {
		const sessionId = `subagent-${createHash("sha256").update(options.session).digest("hex").slice(0, 24)}`;
		args.push("--session-id", sessionId);
	} else args.push("--no-session");
	const effectiveModel = options.modelOverride ?? agent.model;
	if (effectiveModel) args.push("--model", effectiveModel);
	if (agent.thinking) args.push("--thinking", agent.thinking);
	if (agent.tools && agent.tools.length > 0) args.push("--tools", agent.tools.join(","));

	const result: SingleResult = {
		agent: options.agentName,
		agentSource: agent.source,
		task: options.task,
		exitCode: 0,
		messages: [],
		stderr: "",
		usage: emptyUsage(),
		model: effectiveModel,
		step: options.step,
	};
	let promptFile: PromptFile | undefined;
	try {
		if (agent.systemPrompt.trim()) {
			promptFile = await deps.promptFileStore.create(agent.name, agent.systemPrompt);
			args.push("--append-system-prompt", promptFile.path);
		}
		args.push(`Task: ${options.task}`);

		const first = await runProcess(args, options, deps, result, true);
		result.exitCode = first.exitCode;
		if (first.wasAborted) throw new Error("Subagent was aborted");

		if (effectiveModel && options.modelFallback === "current" && isModelFailure(result)) {
			console.error(`[subagent] Model error detected (stopReason: ${result.stopReason}, errorMessage: ${result.errorMessage}). Retrying with parent model and thinking level...`);
			const retryArgs = args.filter(
				(value, index) =>
					value !== "--model" && value !== "--thinking" && args[index - 1] !== "--model" && args[index - 1] !== "--thinking",
			);
			const prompt = retryArgs.pop();
			if (options.fallbackModel) retryArgs.push("--model", options.fallbackModel);
			retryArgs.push("--thinking", options.fallbackThinking);
			if (prompt) retryArgs.push(prompt);
			result.messages = [];
			result.stderr = "";
			result.model = undefined;
			result.stopReason = undefined;
			result.errorMessage = undefined;
			const retry = await runProcess(retryArgs, options, deps, result, false);
			result.exitCode = retry.exitCode;
			result.model = result.model || "(current model)";
		}
		return result;
	} catch {
		return result;
	} finally {
		if (promptFile) await promptFile.cleanup();
	}
}

export function createAgentRunner(deps: AgentRunnerDeps) {
	return (options: RunAgentOptions) => runSingleAgent(options, deps);
}
