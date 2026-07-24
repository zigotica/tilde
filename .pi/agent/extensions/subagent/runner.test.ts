import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { runSingleAgent, type ProcessHandle, type ProcessRunner, type ProcessStream, type PromptFileStore } from "./runner.ts";

class Stream implements ProcessStream {
	private callback?: (chunk: Uint8Array) => void;
	onData(callback: (chunk: Uint8Array) => void): void { this.callback = callback; }
	emit(text: string): void { this.callback?.(Buffer.from(text)); }
}

class Process implements ProcessHandle {
	stdout = new Stream();
	stderr = new Stream();
	killed = false;
	signals: Array<NodeJS.Signals | undefined> = [];
	private close?: (code: number | null) => void;
	private error?: (error: Error) => void;
	onClose(callback: (code: number | null) => void): void { this.close = callback; }
	onError(callback: (error: Error) => void): void { this.error = callback; }
	kill(signal?: NodeJS.Signals): boolean { this.signals.push(signal); this.killed = true; return true; }
	finish(code = 0): void { this.close?.(code); }
	fail(): void { this.error?.(new Error("spawn")); }
}

function agent() {
	return [{ name: "worker", description: "", systemPrompt: "system", source: "user" as const, filePath: "agent.md", tools: ["read"], model: "provider/model", thinking: "low" as const }];
}

function deps(process: Process, calls: Array<{ command: string; args: string[]; cwd: string }>) {
	const processRunner: ProcessRunner = { spawn(command, args, options) { calls.push({ command, args, cwd: options.cwd }); return process; } };
	const promptFileStore: PromptFileStore = {
		async create() { return { path: "/tmp/prompt", async cleanup() {} }; },
	};
	return { processRunner, promptFileStore, getInvocation: (args: string[]) => ({ command: "pi", args }) };
}

function options(onUpdate?: () => void) {
	return {
		defaultCwd: "/project", agents: agent(), agentName: "worker", task: "do it",
		modelFallback: "stop" as const, fallbackThinking: "high", session: "stable",
		onUpdate: onUpdate ? () => onUpdate() : undefined,
		makeDetails: (results: any[]) => ({ mode: "single" as const, agentScope: "user" as const, projectAgentsDir: null, results }),
	};
}

describe("runner", () => {
test("parses chunked, final, malformed, and accepted event lines", async () => {
	const process = new Process();
	const calls: any[] = [];
	const updates: unknown[] = [];
	const promise = runSingleAgent(options(() => updates.push(true)), deps(process, calls));
	await new Promise((resolve) => setImmediate(resolve));
	process.stdout.emit('{"type":"bad"}\n{"type":"message_end","message":{"role":"assistant","content":[{"type":"text","text":"hel');
	process.stdout.emit('lo"}],"usage":{"input":2,"output":3,"cost":{"total":0.5},"totalTokens":5,"cacheRead":1,"cacheWrite":2},"model":"m","stopReason":"end"}}\n');
	process.stdout.emit('{not valid json}\n');
	process.stdout.emit('{"type":"tool_result_end","message":{"role":"toolResult","content":[]}}');
	process.stderr.emit("warning");
	process.finish(0);
	const result = await promise;
	assert.equal(result.exitCode, 0);
	assert.equal(result.messages.length, 2);
	assert.equal((result.messages[0] as any).content[0].text, "hello");
	assert.equal((result.messages[1] as any).role, "toolResult");
	assert.equal(result.usage.input, 2);
	assert.equal(result.usage.turns, 1);
	assert.equal(result.stderr, "warning");
	assert.ok(updates.length > 0);
	assert.equal(calls[0].cwd, "/project");
	assert.deepEqual(calls[0].args.slice(calls[0].args.indexOf("--session-id"), calls[0].args.indexOf("--session-id") + 2), [
		"--session-id",
		"subagent-f379ccb92b9116442dc65bdc",
	]);
	assert.equal(calls[0].args[calls[0].args.indexOf("--tools") + 1], "read");
	assert.equal(calls[0].args[calls[0].args.indexOf("--thinking") + 1], "low");
	assert.equal(calls[0].args[calls[0].args.indexOf("--append-system-prompt") + 1], "/tmp/prompt");
});

test("uses --no-session when session key is absent", async () => {
	const process = new Process();
	const calls: any[] = [];
	const promise = runSingleAgent({ ...options(), session: undefined }, deps(process, calls));
	await new Promise((resolve) => setImmediate(resolve));
	process.finish(0);
	await promise;
	assert.equal(calls[0].args.includes("--no-session"), true);
	assert.equal(calls[0].args.includes("--session-id"), false);
});

test("abort requests SIGTERM without spawning real Pi", async () => {
	const process = new Process();
	const controller = new AbortController();
	const promise = runSingleAgent({ ...options(), signal: controller.signal }, deps(process, []));
	await new Promise((resolve) => setImmediate(resolve));
	controller.abort();
	process.finish(143);
	await promise;
	assert.deepEqual(process.signals, ["SIGTERM"]);
});

test("skips temporary prompt file for empty system prompt", async () => {
	const process = new Process();
	const calls: any[] = [];
	let created = 0;
	const promise = runSingleAgent(
		{ ...options(), agents: [{ ...agent()[0], systemPrompt: "   " }] },
		{
			...deps(process, calls),
			promptFileStore: { async create() { created++; return { path: "/tmp/prompt", async cleanup() {} }; } },
		},
	);
	await new Promise((resolve) => setImmediate(resolve));
	process.finish(0);
	await promise;
	assert.equal(created, 0);
	assert.equal(calls[0].args.includes("--append-system-prompt"), false);
});

test("returns unknown agent without spawning", async () => {
	let spawned = false;
	const processRunner: ProcessRunner = { spawn() { spawned = true; throw new Error("must not spawn"); } };
	const result = await runSingleAgent({ ...options(), agentName: "missing" }, {
		processRunner,
		promptFileStore: { async create() { throw new Error("must not create"); } },
		getInvocation: (args) => ({ command: "pi", args }),
	});
	assert.equal(spawned, false);
	assert.equal(result.exitCode, 1);
	assert.match(result.stderr, /Unknown agent: "missing"/);
});

test("retries model failure and cleans prompt file", async () => {
	const first = new Process();
	const second = new Process();
	let count = 0;
	let cleaned = 0;
	const calls: any[] = [];
	const processRunner: ProcessRunner = { spawn(command, args, options) {
		calls.push({ command, args, cwd: options.cwd });
		return count++ === 0 ? first : second;
	} };
	const promptFileStore: PromptFileStore = { async create() { return { path: "/tmp/prompt", async cleanup() { cleaned++; } }; } };
	const promise = runSingleAgent({ ...options(), modelFallback: "current", fallbackModel: "parent/model" }, { processRunner, promptFileStore, getInvocation: (args) => ({ command: "pi", args }) });
	await new Promise((resolve) => setImmediate(resolve));
	first.stderr.emit("model unavailable");
	first.finish(1);
	await new Promise((resolve) => setImmediate(resolve));
	second.stdout.emit('{"type":"message_end","message":{"role":"assistant","content":[{"type":"text","text":"ok"}]}}\n');
	second.finish(0);
	const result = await promise;
	assert.equal(result.exitCode, 0);
	assert.equal(cleaned, 1);
	assert.equal(calls.length, 2);
	assert.ok(calls[1].args.includes("parent/model"));
});
});
