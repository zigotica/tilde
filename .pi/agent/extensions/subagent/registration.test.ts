import assert from "node:assert/strict";
import { test } from "node:test";
import { createSubagentTool } from "./index.ts";
import { SubagentParamsSchema } from "./schema.ts";

test("registration construction exposes metadata and delegates callbacks", async () => {
	let executed = false;
	const tool = createSubagentTool({
		discoverAgents: () => ({ agents: [], projectAgentsDir: null }),
		runAgent: async () => { executed = true; throw new Error("not expected"); },
		outputWriter: { async write() {} },
		confirmProjectAgents: async () => true,
	});
	assert.equal(tool.name, "subagent");
	assert.equal(tool.parameters, SubagentParamsSchema);
	assert.equal(typeof tool.execute, "function");
	assert.equal(typeof tool.renderCall, "function");
	assert.equal(typeof tool.renderResult, "function");
	const theme = { fg: (_color: string, text: string) => text, bold: (text: string) => text };
	const call = tool.renderCall({ agent: "one", task: "task" }, theme, {});
	assert.ok(call);
	const rendered = tool.renderResult({
		content: [{ type: "text", text: "output" }],
		details: {
			mode: "single",
			agentScope: "user",
			projectAgentsDir: null,
			results: [{
				agent: "one",
				agentSource: "user",
				task: "task",
				exitCode: 0,
				messages: [{ role: "assistant", content: [{ type: "text", text: "output" }] }],
				stderr: "",
				usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 1 },
			}],
		},
	}, { expanded: false }, theme, {});
	assert.ok(rendered);
	const response = await tool.execute("id", {}, undefined, undefined, { cwd: "/tmp", hasUI: false });
	assert.match(response.content[0].text, /exactly one mode/);
	assert.equal(executed, false);
});
