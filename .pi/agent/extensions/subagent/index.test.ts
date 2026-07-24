import assert from "node:assert/strict";
import { describe, test } from "node:test";
import * as os from "node:os";
import * as path from "node:path";
import {
	formatTokens,
	formatUsageStats,
	formatToolCall,
	getFinalOutput,
	isFailedResult,
	getResultOutput,
	truncateParallelOutput,
	getDisplayItems,
	mapWithConcurrencyLimit,
} from "./index.ts";

const outputCap = 50 * 1024;
const identityTheme = (_color: unknown, text: string) => text;

function result(overrides: Record<string, unknown> = {}): any {
	return {
		agent: "agent",
		agentSource: "user",
		task: "task",
		exitCode: 0,
		messages: [],
		stderr: "",
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
		...overrides,
	};
}

describe("index helpers", () => {
test("formats tokens at unit boundaries", () => {
	assert.equal(formatTokens(999), "999");
	assert.equal(formatTokens(1_000), "1.0k");
	assert.equal(formatTokens(9_999), "10.0k");
	assert.equal(formatTokens(10_000), "10k");
	assert.equal(formatTokens(999_999), "1000k");
	assert.equal(formatTokens(1_000_000), "1.0M");
});

test("formats usage fields, singular and plural turns, and omits zero fields", () => {
	assert.equal(formatUsageStats({ input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 }), "");
	assert.equal(
		formatUsageStats(
			{ input: 1_000, output: 2_000, cacheRead: 3_000, cacheWrite: 4_000, cost: 1.23456, contextTokens: 5, turns: 2 },
			"model",
		),
		"2 turns ↑1.0k ↓2.0k R3.0k W4.0k $1.2346 ctx:5 model",
	);
	assert.equal(
		formatUsageStats({ input: 1, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 1 }),
		"1 turn ↑1",
	);
});

test("formats recognized tool calls and generic fallback", () => {
	const homeFile = path.join(os.homedir(), "project", "file.ts");
	assert.equal(formatToolCall("bash", { command: "x".repeat(61) }, identityTheme), `$ ${"x".repeat(60)}...`);
	assert.equal(formatToolCall("read", { path: homeFile, offset: 5, limit: 5 }, identityTheme), "read ~/project/file.ts:5-9");
	assert.equal(formatToolCall("read", { file_path: "/tmp/file.ts", offset: 3 }, identityTheme), "read /tmp/file.ts:3");
	assert.equal(formatToolCall("write", { path: "/tmp/file.ts", content: "one\ntwo" }, identityTheme), "write /tmp/file.ts (2 lines)");
	assert.equal(formatToolCall("edit", { file_path: homeFile }, identityTheme), "edit ~/project/file.ts");
	assert.equal(formatToolCall("ls", { path: homeFile }, identityTheme), "ls ~/project/file.ts");
	assert.equal(formatToolCall("find", { pattern: "*.ts", path: homeFile }, identityTheme), "find *.ts in ~/project/file.ts");
	assert.equal(formatToolCall("grep", { pattern: "needle", path: homeFile }, identityTheme), "grep /needle/ in ~/project/file.ts");
	assert.equal(formatToolCall("unknown", { value: "x" }, identityTheme), 'unknown {"value":"x"}');
	const longArgs = JSON.stringify({ value: "x".repeat(60) });
	assert.equal(formatToolCall("unknown", { value: "x".repeat(60) }, identityTheme), `unknown ${longArgs.slice(0, 50)}...`);
	assert.equal(formatToolCall("bash", {}, identityTheme), "$ ...");
});

test("extracts latest assistant text and returns empty when absent", () => {
	const messages: any[] = [
		{ role: "user", content: [{ type: "text", text: "user" }] },
		{ role: "assistant", content: [{ type: "text", text: "old" }] },
		{ role: "toolResult", content: [{ type: "text", text: "tool result" }] },
		{ role: "assistant", content: [{ type: "toolCall", name: "read", arguments: {} }, { type: "text", text: "latest" }] },
	];
	assert.equal(getFinalOutput(messages), "latest");
	assert.equal(getFinalOutput([{ role: "user", content: [{ type: "text", text: "only user" }] }] as any), "");
});

test("detects failed results and applies output precedence", () => {
	assert.equal(isFailedResult(result({ exitCode: 1 })), true);
	assert.equal(isFailedResult(result({ stopReason: "error" })), true);
	assert.equal(isFailedResult(result({ stopReason: "aborted" })), true);
	assert.equal(isFailedResult(result()), false);

	const assistant = [{ role: "assistant", content: [{ type: "text", text: "assistant output" }] }];
	assert.equal(getResultOutput(result({ exitCode: 1, errorMessage: "error message", stderr: "stderr", messages: assistant })), "error message");
	assert.equal(getResultOutput(result({ exitCode: 1, stderr: "stderr", messages: assistant })), "stderr");
	assert.equal(getResultOutput(result({ exitCode: 1, messages: assistant })), "assistant output");
	assert.equal(getResultOutput(result({ exitCode: 1 })), "(no output)");
	assert.equal(getResultOutput(result({ messages: assistant })), "assistant output");
	assert.equal(getResultOutput(result()), "(no output)");
});

test("truncates parallel output at UTF-8 byte cap without broken characters", () => {
	const underCap = "😀".repeat(100);
	assert.equal(truncateParallelOutput(underCap), underCap);

	const output = "a".repeat(outputCap - 2) + "😀" + "tail";
	const truncated = truncateParallelOutput(output);
	const kept = truncated.slice(0, truncated.indexOf("\n\n[Output truncated:"));
	assert.equal(Buffer.byteLength(kept, "utf8"), outputCap - 2);
	assert.ok(!kept.includes("�"));
	assert.ok(truncated.includes(`[Output truncated: ${Buffer.byteLength(output, "utf8") - (outputCap - 2)} bytes omitted.`));
});

test("extracts assistant display items in source order", () => {
	const items = getDisplayItems([
		{ role: "user", content: [{ type: "text", text: "ignored" }] },
		{
			role: "assistant",
			content: [
				{ type: "text", text: "first" },
				{ type: "toolCall", name: "read", arguments: { path: "file" } },
				{ type: "image", data: "ignored" },
			],
		},
		{ role: "toolResult", content: [{ type: "text", text: "ignored" }] },
		{ role: "assistant", content: [{ type: "toolCall", name: "bash", arguments: { command: "pwd" } }, { type: "text", text: "last" }] },
	] as any);
	assert.deepEqual(items, [
		{ type: "text", text: "first" },
		{ type: "toolCall", name: "read", args: { path: "file" } },
		{ type: "toolCall", name: "bash", args: { command: "pwd" } },
		{ type: "text", text: "last" },
	]);
});

test("maps with bounded concurrency, input order, empty input, and minimum one worker", async () => {
	let active = 0;
	let maximum = 0;
	const values = await mapWithConcurrencyLimit([0, 1, 2, 3, 4], 2, async (value, index) => {
		active++;
		maximum = Math.max(maximum, active);
		await new Promise((resolve) => setTimeout(resolve, (4 - index) * 2));
		active--;
		return value * 10;
	});
	assert.deepEqual(values, [0, 10, 20, 30, 40]);
	assert.equal(maximum, 2);

	let singleMaximum = 0;
	active = 0;
	await mapWithConcurrencyLimit([1, 2, 3], 0, async (value) => {
		active++;
		singleMaximum = Math.max(singleMaximum, active);
		await Promise.resolve();
		active--;
		return value;
	});
	assert.equal(singleMaximum, 1);
	assert.deepEqual(await mapWithConcurrencyLimit([], 4, async (value) => value), []);
});
});
