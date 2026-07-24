import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { renderCall, renderResult } from "./render.ts";

const theme = { fg: (_color: string, text: string) => text, bold: (text: string) => text };
const message = (text: string) => ({ role: "assistant", content: [{ type: "text", text }] });
function result(agent: string, task: string, step?: number) {
	return { agent, agentSource: "user", task, exitCode: 0, messages: [message("output")], stderr: "", usage: { input: 1, output: 1, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 1 }, step };
}

describe("render", () => {
test("smoke covers single, parallel, and chain paths", () => {
	const calls = [
		renderCall({ agent: "one", task: "task" }, theme, {}),
		renderCall({ tasks: [{ agent: "one", task: "task" }] }, theme, {}),
		renderCall({ chain: [{ agent: "one", task: "task {previous}" }] }, theme, {}),
	];
	assert.equal(calls.length, 3);
	for (const call of calls) assert.ok(call);
	const single = renderResult({ content: [{ type: "text", text: "output" }], details: { mode: "single", agentScope: "user", projectAgentsDir: null, results: [result("one", "task")] } }, { expanded: false }, theme, {});
	const parallel = renderResult({ content: [{ type: "text", text: "output" }], details: { mode: "parallel", agentScope: "user", projectAgentsDir: null, results: [result("one", "task")] } }, { expanded: false }, theme, {});
	const chain = renderResult({ content: [{ type: "text", text: "output" }], details: { mode: "chain", agentScope: "user", projectAgentsDir: null, results: [result("one", "task", 1)], totalSteps: 1 } }, { expanded: false }, theme, {});
	assert.ok(single && parallel && chain);
});
});
