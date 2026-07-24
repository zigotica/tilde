import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { Value } from "typebox/value";
import { SubagentParamsSchema } from "./schema.ts";

describe("schema", () => {
	test("accepts valid single-mode input with required fields", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { agent: "researcher", task: "Find the answer" }), true);
	});

	test("accepts optional single-mode fields", () => {
		assert.equal(
			Value.Check(SubagentParamsSchema, {
				agent: "researcher",
				task: "Find the answer",
				model: "anthropic/claude-sonnet-4",
				outputFile: "answer.md",
				cwd: "/tmp/project",
				session: "research-session",
				agentScope: "project",
				modelFallback: "stop",
				confirmProjectAgents: false,
			}),
			true,
		);
	});

	test("accepts every agentScope value", () => {
		for (const agentScope of ["user", "project", "both"]) {
			assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", agentScope }), true);
		}
	});

	test("accepts every top-level modelFallback value", () => {
		for (const modelFallback of ["stop", "current"]) {
			assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", modelFallback }), true);
		}
	});

	test("accepts parallel tasks and item options", () => {
		assert.equal(
			Value.Check(SubagentParamsSchema, {
				tasks: [
					{
						agent: "worker",
						task: "First task",
						model: "openai/gpt-4.1",
						modelFallback: "stop",
						outputFile: "first.md",
						cwd: "/tmp/first",
					},
					{ agent: "worker", task: "Second task", modelFallback: "current" },
				],
			}),
			true,
		);
	});

	test("accepts chain items and item options", () => {
		assert.equal(
			Value.Check(SubagentParamsSchema, {
				chain: [
					{
						agent: "planner",
						task: "Plan work",
						model: "anthropic/claude-sonnet-4",
						modelFallback: "current",
						outputFile: "plan.md",
						cwd: "/tmp/plan",
					},
					{ agent: "writer", task: "Write {previous}", modelFallback: "stop" },
				],
			}),
			true,
		);
	});

	test("rejects invalid top-level primitive types", () => {
		const invalidValues = [
			{ agent: 1, task: "Work" },
			{ agent: "worker", task: 1 },
			{ agent: "worker", task: "Work", model: false },
			{ agent: "worker", task: "Work", outputFile: 1 },
			{ agent: "worker", task: "Work", cwd: false },
			{ agent: "worker", task: "Work", session: 1 },
			{ agent: "worker", task: "Work", tasks: "not-an-array" },
			{ agent: "worker", task: "Work", chain: {} },
			{ agent: "worker", task: "Work", agentScope: true },
			{ agent: "worker", task: "Work", modelFallback: 1 },
			{ agent: "worker", task: "Work", confirmProjectAgents: "yes" },
		];

		for (const value of invalidValues) {
			assert.equal(Value.Check(SubagentParamsSchema, value), false);
		}
	});

	test("rejects invalid primitive types in parallel items", () => {
		const invalidItems = [
			{ agent: 1, task: "Work" },
			{ agent: "worker", task: 1 },
			{ agent: "worker", task: "Work", model: false },
			{ agent: "worker", task: "Work", modelFallback: 1 },
			{ agent: "worker", task: "Work", outputFile: false },
			{ agent: "worker", task: "Work", cwd: 1 },
		];

		for (const item of invalidItems) {
			assert.equal(Value.Check(SubagentParamsSchema, { tasks: [item] }), false);
		}
	});

	test("rejects invalid primitive types in chain items", () => {
		const invalidItems = [
			{ agent: 1, task: "Work" },
			{ agent: "worker", task: 1 },
			{ agent: "worker", task: "Work", model: false },
			{ agent: "worker", task: "Work", modelFallback: 1 },
			{ agent: "worker", task: "Work", outputFile: false },
			{ agent: "worker", task: "Work", cwd: 1 },
		];

		for (const item of invalidItems) {
			assert.equal(Value.Check(SubagentParamsSchema, { chain: [item] }), false);
		}
	});

	test("rejects parallel items missing agent or task", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { tasks: [{ task: "Work" }] }), false);
		assert.equal(Value.Check(SubagentParamsSchema, { tasks: [{ agent: "worker" }] }), false);
	});

	test("rejects chain items missing agent or task", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { chain: [{ task: "Work" }] }), false);
		assert.equal(Value.Check(SubagentParamsSchema, { chain: [{ agent: "worker" }] }), false);
	});

	test("rejects unsupported agentScope values", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", agentScope: "workspace" }), false);
		assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", agentScope: 1 }), false);
	});

	test("rejects unsupported top-level modelFallback values", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", modelFallback: "retry" }), false);
		assert.equal(Value.Check(SubagentParamsSchema, { agent: "worker", task: "Work", modelFallback: false }), false);
	});

	test("rejects unsupported item-level modelFallback values", () => {
		assert.equal(Value.Check(SubagentParamsSchema, { tasks: [{ agent: "worker", task: "Work", modelFallback: "retry" }] }), false);
		assert.equal(Value.Check(SubagentParamsSchema, { chain: [{ agent: "worker", task: "Work", modelFallback: 1 }] }), false);
	});
});
