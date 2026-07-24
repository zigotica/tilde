/**
 * Subagent tool registration and production wiring.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, getAgentDir } from "@earendil-works/pi-coding-agent";
import { discoverAgents, type AgentScope } from "./agents.ts";
import {
	executeSubagent,
	type ExecutionContext,
	type ExecutionDependencies,
	type OutputWriter,
} from "./execute.ts";
import { renderCall, renderResult } from "./render.ts";
import {
	createAgentRunner,
	productionProcessRunner,
	productionPromptFileStore,
} from "./runner.ts";
import { SubagentParamsSchema, type SubagentParams } from "./schema.ts";

export {
	formatTokens,
	formatUsageStats,
	formatToolCall,
	getFinalOutput,
	isFailedResult,
	getResultOutput,
	truncateParallelOutput,
	getDisplayItems,
} from "./render.ts";
export { mapWithConcurrencyLimit } from "./execute.ts";

export interface SubagentToolDependencies extends ExecutionDependencies {
	getThinkingLevel?: () => string;
}

export function createSubagentTool(deps: SubagentToolDependencies): any {
	return {
		name: "subagent",
		label: "Subagent",
		description: [
			"Delegate tasks to specialized subagents with isolated context.",
			"Modes: single (agent + task), parallel (tasks array), chain (sequential with {previous} placeholder).",
			`Default agent scope is "user" (from ${path.join(getAgentDir(), "agents")}).`,
			`To enable project-local agents in ${CONFIG_DIR_NAME}/agents, set agentScope: "both" (or "project").`,
		].join(" "),
		parameters: SubagentParamsSchema,

		async execute(_toolCallId: string, params: SubagentParams, signal: AbortSignal | undefined, onUpdate: any, ctx: any) {
			const executionContext: ExecutionContext = {
				cwd: ctx.cwd,
				hasUI: ctx.hasUI,
				ui: ctx.ui,
				signal,
				onUpdate,
				fallbackModel: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined,
				fallbackThinking: deps.getThinkingLevel?.() ?? ctx.thinkingLevel ?? "medium",
			};
			return executeSubagent(params, executionContext, deps);
		},

		renderCall(args: SubagentParams, theme: any, context: any) {
		return renderCall(args, theme, context);
	},

		renderResult(result: any, options: { expanded: boolean }, theme: any, context: any) {
		return renderResult(result, options, theme, context);
	},
	};
}

function createOutputWriter(): OutputWriter {
	return {
		async write(filePath, output) {
			await fs.promises.mkdir(path.dirname(filePath), { recursive: true });
			await fs.promises.writeFile(filePath, output, "utf-8");
		},
	};
}

export default function (pi: ExtensionAPI) {
	const runner = createAgentRunner({
		processRunner: productionProcessRunner,
		promptFileStore: productionPromptFileStore,
	});
	const outputWriter = createOutputWriter();
	const tool = createSubagentTool({
		discoverAgents,
		runAgent: runner,
		outputWriter,
		getThinkingLevel: () => pi.getThinkingLevel(),
		async confirmProjectAgents(names, directory, context) {
			if (!context.ui) return true;
			return context.ui.confirm(
				"Run project-local agents?",
				`Agents: ${names.join(", ")}\nSource: ${directory ?? "(unknown)"}\n\nProject agents are repo-controlled. Only continue for trusted repositories.`,
			);
		},
	});

	// Host registration keeps tool metadata and callbacks identical to direct construction.
	pi.registerTool(tool);
}
