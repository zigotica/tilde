import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { executeSubagent, type ExecutionDependencies } from "./execute.ts";
import { runSingleAgent, type ProcessRunner } from "./runner.ts";
import type { SingleResult } from "./schema.ts";

const agents = [
	{ name: "one", description: "", systemPrompt: "", source: "user" as const, filePath: "one.md" },
	{ name: "two", description: "", systemPrompt: "", source: "project" as const, filePath: "two.md" },
];
const context = { cwd: "/project", hasUI: false, fallbackThinking: "medium" };
function result(agent: string, task: string, output: string, exitCode = 0): SingleResult {
	return { agent, agentSource: "user", task, exitCode, messages: [{ role: "assistant", content: [{ type: "text", text: output }] }] as any, stderr: "", usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 1 } };
}
function deps(run: (options: any) => Promise<SingleResult>, writes: string[] = []): ExecutionDependencies {
	return {
		discoverAgents: () => ({ agents, projectAgentsDir: "/project/.pi/agents" }),
		runAgent: run,
		outputWriter: { async write(file, output) { writes.push(`${file}:${output}`); } },
		confirmProjectAgents: async () => true,
	};
}

describe("execute", () => {
test("returns unknown-agent failure without starting a process", async () => {
	let spawned = false;
	const processRunner: ProcessRunner = { spawn() { spawned = true; throw new Error("must not spawn"); } };
	const response = await executeSubagent(
		{ agent: "missing", task: "task" },
		context,
		{
			discoverAgents: () => ({ agents, projectAgentsDir: null }),
			runAgent: (options) => runSingleAgent(options, {
				processRunner,
				promptFileStore: { async create() { throw new Error("must not create"); } },
				getInvocation: (args) => ({ command: "pi", args }),
			}),
			outputWriter: { async write() {} },
			confirmProjectAgents: async () => true,
		},
	);
	assert.equal(spawned, false);
	assert.equal(response.isError, true);
	assert.equal((response.details as any).results[0].agent, "missing");
	assert.equal((response.details as any).results[0].agentSource, "unknown");
	assert.match(response.content[0].text as string, /Unknown agent: "missing"/);
});

test("rejects more than eight parallel tasks without running agents", async () => {
	let called = 0;
	const response = await executeSubagent(
		{ tasks: Array.from({ length: 9 }, (_, index) => ({ agent: "one", task: String(index) })) },
		context,
		deps(async () => { called++; throw new Error("must not run"); }),
	);
	assert.equal(called, 0);
	assert.match(response.content[0].text as string, /Too many parallel tasks \(9\)/);
	assert.deepEqual((response.details as any).results, []);
});

test("validates mode, confirms project agents, and runs single output", async () => {
	let called = 0;
	let session: string | undefined;
	const writes: string[] = [];
	const resultValue = await executeSubagent({ agent: "one", task: "task", session: "stable", outputFile: "out.txt" }, context, deps(async (options) => { called++; session = options.session; return result(options.agentName, options.task, "done"); }, writes));
	assert.equal(called, 1);
	assert.equal(session, "stable");
	assert.equal(resultValue.content[0].text, "done");
	assert.deepEqual(writes, ["out.txt:done"]);
	const invalid = await executeSubagent({ agent: "one", task: "task", tasks: [{ agent: "one", task: "other" }] } as any, context, deps(async () => { throw new Error("not called"); }));
	assert.match(invalid.content[0].text as string, /exactly one mode/);
});

test("preserves parallel ordering, limit, and chain substitution", async () => {
	let active = 0;
	let maximum = 0;
	const parallel = await executeSubagent({ tasks: [0, 1, 2, 3, 4].map((i) => ({ agent: "one", task: String(i) })) }, context, deps(async (options) => {
		active++; maximum = Math.max(maximum, active);
		await new Promise((resolve) => setTimeout(resolve, (4 - Number(options.task)) * 2));
		active--;
		return result("one", options.task, `out-${options.task}`);
	}));
	assert.equal(maximum, 4);
	assert.equal((parallel.details as any).results.map((item: SingleResult) => item.task).join(","), "0,1,2,3,4");
	const tasks: string[] = [];
	const chain = await executeSubagent({ chain: [{ agent: "one", task: "first" }, { agent: "one", task: "again {previous} {previous}" }] }, context, deps(async (options) => {
		tasks.push(options.task);
		return result("one", options.task, options.task === "first" ? "value" : "final");
	}));
	assert.deepEqual(tasks, ["first", "again value value"]);
	assert.equal(chain.content[0].text, "final");
});

test("parallel streaming keeps placeholders until task completion", async () => {
	const updates: any[] = [];
	const response = await executeSubagent(
		{ tasks: [{ agent: "one", task: "first" }, { agent: "one", task: "second" }] },
		{ ...context, onUpdate: (update) => updates.push(update) },
		deps(async (options) => {
			const streamed = result(options.agentName, options.task, `stream-${options.task}`);
			options.onUpdate?.({ content: [{ type: "text", text: "running" }], details: options.makeDetails([streamed]) });
			await Promise.resolve();
			return result(options.agentName, options.task, `done-${options.task}`);
		}),
	);
	assert.ok(updates.some((update) => update.details.results.some((item: SingleResult) => item.task === "first" && item.exitCode === -1 && item.messages.length === 1)));
	assert.deepEqual((response.details as any).results.map((item: SingleResult) => item.exitCode), [0, 0]);
});

test("chain stops on first failed result", async () => {
	const tasks: string[] = [];
	const response = await executeSubagent(
		{ chain: [{ agent: "one", task: "first" }, { agent: "one", task: "never" }] },
		context,
		deps(async (options) => {
			tasks.push(options.task);
			return result(options.agentName, options.task, "failed", 1);
		}),
	);
	assert.deepEqual(tasks, ["first"]);
	assert.equal(response.isError, true);
	assert.equal((response.details as any).results.length, 1);
	assert.match(response.content[0].text as string, /Chain stopped at step 1/);
});

test("output write failure is logged and does not fail successful execution", async () => {
	const originalError = console.error;
	let logged = false;
	console.error = () => { logged = true; };
	try {
		const response = await executeSubagent(
			{ agent: "one", task: "task", outputFile: "out.txt" },
			context,
			{ ...deps(async (options) => result(options.agentName, options.task, "done")), outputWriter: { async write() { throw new Error("disk full"); } } },
		);
		assert.equal(response.isError, undefined);
		assert.equal(response.content[0].text, "done");
	} finally {
		console.error = originalError;
	}
	assert.equal(logged, true);
});

test("project confirmation approval proceeds with execution", async () => {
	let ran = false;
	let confirmation: { names: string[]; directory: string | null } | undefined;
	const dependencies = deps(async (options) => {
		ran = true;
		return result(options.agentName, options.task, "approved");
	});
	dependencies.confirmProjectAgents = async (names, directory) => {
		confirmation = { names, directory };
		return true;
	};
	const response = await executeSubagent({ agent: "two", task: "x", agentScope: "project" }, { ...context, hasUI: true }, dependencies);
	assert.equal(ran, true);
	assert.deepEqual(confirmation, { names: ["two"], directory: "/project/.pi/agents" });
	assert.equal(response.content[0].text, "approved");
});

test("project confirmation rejection stops before run", async () => {
	let called = false;
	const dependencies = deps(async () => { called = true; return result("two", "x", "x"); });
	dependencies.confirmProjectAgents = async () => false;
	const response = await executeSubagent({ agent: "two", task: "x", agentScope: "project" }, { ...context, hasUI: true }, dependencies);
	assert.equal(called, false);
	assert.equal(response.content[0].text, "Canceled: project-local agents not approved.");
});
});
