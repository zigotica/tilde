import { StringEnum, type Message } from "@earendil-works/pi-ai";
import { Type, type Static } from "typebox";
import type { AgentScope } from "./agents.ts";

export const MAX_PARALLEL_TASKS = 8;
export const MAX_CONCURRENCY = 4;
export const PER_TASK_OUTPUT_CAP = 50 * 1024;
export const COLLAPSED_ITEM_COUNT = 10;

export const ModelFallbackSchema = StringEnum(["stop", "current"] as const, {
	description:
		'What to do when agent model fails (quota, missing key, etc). "stop" halts the flow. "current" retries with the parent session\'s current model and thinking level.',
	default: "current",
});

export const AgentScopeSchema = StringEnum(["user", "project", "both"] as const, {
	description: 'Which agent directories to use. Default: "user". Use "both" to include project-local agents.',
	default: "user",
});

export const TaskItemSchema = Type.Object({
	agent: Type.String({ description: "Name of the agent to invoke" }),
	task: Type.String({ description: "Task to delegate to the agent" }),
	model: Type.Optional(Type.String({ description: "Override model for this agent (e.g. 'anthropic/claude-opus-4-5')" })),
	modelFallback: Type.Optional(ModelFallbackSchema),
	outputFile: Type.Optional(Type.String({ description: "Save final output to this file path" })),
	cwd: Type.Optional(Type.String({ description: "Working directory for the agent process" })),
});

export const ChainItemSchema = Type.Object({
	agent: Type.String({ description: "Name of the agent to invoke" }),
	task: Type.String({ description: "Task with optional {previous} placeholder for prior output" }),
	model: Type.Optional(Type.String({ description: "Override model for this agent" })),
	modelFallback: Type.Optional(ModelFallbackSchema),
	outputFile: Type.Optional(Type.String({ description: "Save final output to this file path" })),
	cwd: Type.Optional(Type.String({ description: "Working directory for the agent process" })),
});

export const SubagentParamsSchema = Type.Object({
	agent: Type.Optional(Type.String({ description: "Name of the agent to invoke (for single mode)" })),
	task: Type.Optional(Type.String({ description: "Task to delegate (for single mode)" })),
	model: Type.Optional(Type.String({ description: "Override model (single mode only)" })),
	outputFile: Type.Optional(Type.String({ description: "Save final output to this file path (single mode)" })),
	tasks: Type.Optional(Type.Array(TaskItemSchema, { description: "Array of {agent, task} for parallel execution" })),
	chain: Type.Optional(Type.Array(ChainItemSchema, { description: "Array of {agent, task} for sequential execution" })),
	agentScope: Type.Optional(AgentScopeSchema),
	modelFallback: Type.Optional(ModelFallbackSchema),
	confirmProjectAgents: Type.Optional(
		Type.Boolean({ description: "Prompt before running project-local agents. Default: true.", default: true }),
	),
	cwd: Type.Optional(Type.String({ description: "Working directory for the agent process (single mode)" })),
	session: Type.Optional(
		Type.String({
			description: "Persistent session key for single mode. Pi stores and reuses the project-scoped session in its standard session store.",
		}),
	),
});

export type ModelFallback = "stop" | "current";
export type SubagentParams = Static<typeof SubagentParamsSchema>;
export type TaskItem = Static<typeof TaskItemSchema>;
export type ChainItem = Static<typeof ChainItemSchema>;
export type SingleTaskParams = {
	agent: string;
	task: string;
	model?: string;
	modelFallback?: ModelFallback;
	outputFile?: string;
	cwd?: string;
	session?: string;
};
export type ParallelTaskParams = TaskItem;
export type ChainTaskParams = ChainItem;

export interface UsageStats {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	contextTokens: number;
	turns: number;
}

export interface SingleResult {
	agent: string;
	agentSource: "user" | "project" | "unknown";
	task: string;
	exitCode: number;
	messages: Message[];
	stderr: string;
	usage: UsageStats;
	model?: string;
	stopReason?: string;
	errorMessage?: string;
	step?: number;
}

export interface SubagentDetails {
	mode: "single" | "parallel" | "chain";
	agentScope: AgentScope;
	projectAgentsDir: string | null;
	results: SingleResult[];
	totalSteps?: number;
}

export type DisplayItem =
	| { type: "text"; text: string }
	| { type: "toolCall"; name: string; args: Record<string, any> };
