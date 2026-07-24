import assert from "node:assert/strict";
import { afterEach, describe, test } from "node:test";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { discoverAgents, formatAgentList } from "./agents.ts";

const agentDirEnv = "PI_CODING_AGENT_DIR";
let testRoot: string | undefined;
const previousAgentDir = process.env[agentDirEnv];

afterEach(() => {
	if (testRoot) fs.rmSync(testRoot, { recursive: true, force: true });
	testRoot = undefined;
	if (previousAgentDir === undefined) delete process.env[agentDirEnv];
	else process.env[agentDirEnv] = previousAgentDir;
});

function root(): string {
	testRoot = fs.mkdtempSync(path.join(os.tmpdir(), "pi-subagent-agents-"));
	return testRoot;
}

function agentFile(dir: string, fileName: string, fields: Record<string, string>, body = "prompt"): string {
	fs.mkdirSync(dir, { recursive: true });
	const frontmatter = Object.entries(fields).map(([key, value]) => `${key}: ${value}`).join("\n");
	const filePath = path.join(dir, fileName);
	fs.writeFileSync(filePath, `---\n${frontmatter}\n---\n${body}\n`);
	return filePath;
}

function useUserDir(dir: string): void {
	process.env[agentDirEnv] = dir;
}

function projectDir(base: string): string {
	return path.join(base, ".pi", "agents");
}

describe("agents", () => {
test("returns no agents when user and project directories are missing or unusable", () => {
	const base = root();
	const userBase = path.join(base, "user-file");
	fs.writeFileSync(userBase, "not a directory");
	useUserDir(userBase);

	const missing = discoverAgents(path.join(base, "missing"), "both");
	assert.deepEqual(missing.agents, []);
	assert.equal(missing.projectAgentsDir, null);

	const projectAsFile = path.join(base, ".pi", "agents");
	fs.mkdirSync(path.dirname(projectAsFile), { recursive: true });
	fs.writeFileSync(projectAsFile, "not a directory");
	const unusable = discoverAgents(base, "both");
	assert.deepEqual(unusable.agents, []);
	assert.equal(unusable.projectAgentsDir, null);
});

test("loads valid markdown agents and skips invalid entries", () => {
	const base = root();
	const agents = path.join(base, "agents");
	useUserDir(base);
	const validPath = agentFile(agents, "valid.md", {
		name: "valid",
		description: "valid agent",
		tools: " read, , bash ,",
		model: "provider/model",
		thinking: "medium",
	}, "system prompt");
	const linkedTarget = agentFile(base, "linked-target.md", { name: "linked", description: "linked agent" });
	const linkedPath = path.join(agents, "linked.md");
	fs.symlinkSync(linkedTarget, linkedPath);

	agentFile(agents, "missing-name.md", { description: "missing name" });
	agentFile(agents, "missing-description.md", { name: "missing-description" });
	fs.writeFileSync(path.join(agents, "not-markdown.txt"), "ignored");
	fs.mkdirSync(path.join(agents, "directory.md"));
	fs.writeFileSync(path.join(agents, "invalid-frontmatter.md"), "---\n: invalid\n---\nignored");
	fs.symlinkSync(path.join(agents, "does-not-exist.md"), path.join(agents, "unreadable.md"));

	const result = discoverAgents(base, "user");
	assert.equal(result.agents.length, 2);
	const valid = result.agents.find((agent) => agent.name === "valid");
	assert.deepEqual(valid, {
		name: "valid",
		description: "valid agent",
		tools: ["read", "bash"],
		model: "provider/model",
		thinking: "medium",
		systemPrompt: "system prompt",
		source: "user",
		filePath: validPath,
	});
	assert.equal(result.agents.find((agent) => agent.name === "linked")?.filePath, linkedPath);
});

test("accepts all supported thinking levels and clears unsupported values", () => {
	const base = root();
	const agents = path.join(base, "agents");
	useUserDir(base);
	const levels = ["off", "minimal", "low", "medium", "high", "xhigh", "max"];
	for (const level of levels) {
		agentFile(agents, `${level}.md`, { name: level, description: level, thinking: level });
	}
	agentFile(agents, "unsupported.md", { name: "unsupported", description: "unsupported", thinking: "extreme" });
	agentFile(agents, "absent.md", { name: "absent", description: "absent" });

	const result = discoverAgents(base, "user");
	const byName = new Map(result.agents.map((agent) => [agent.name, agent]));
	for (const level of levels) assert.equal(byName.get(level)?.thinking, level);
	assert.equal(byName.get("unsupported")?.thinking, undefined);
	assert.equal(byName.get("absent")?.thinking, undefined);
});

test("selects nearest project agents directory", () => {
	const base = root();
	const nested = path.join(base, "repo", "child");
	fs.mkdirSync(nested, { recursive: true });
	const outerAgents = projectDir(base);
	const nearestAgents = projectDir(path.join(base, "repo"));
	agentFile(outerAgents, "outer.md", { name: "outer", description: "outer" });
	agentFile(nearestAgents, "nearest.md", { name: "nearest", description: "nearest" });
	useUserDir(path.join(base, "missing-user"));

	const result = discoverAgents(nested, "project");
	assert.equal(result.projectAgentsDir, nearestAgents);
	assert.deepEqual(result.agents.map((agent) => agent.name), ["nearest"]);
});

test("loads user, project, and both scopes with project override", () => {
	const base = root();
	const userBase = path.join(base, "user");
	const userAgents = path.join(userBase, "agents");
	const cwd = path.join(base, "project");
	const projects = projectDir(cwd);
	fs.mkdirSync(cwd, { recursive: true });
	useUserDir(userBase);
	agentFile(userAgents, "user-only.md", { name: "user-only", description: "user" });
	agentFile(userAgents, "shared.md", { name: "shared", description: "user version" });
	agentFile(projects, "project-only.md", { name: "project-only", description: "project" });
	agentFile(projects, "shared.md", { name: "shared", description: "project version" });

	const user = discoverAgents(cwd, "user");
	assert.deepEqual(user.agents.map((agent) => agent.name), ["shared", "user-only"]);
	assert.ok(user.agents.every((agent) => agent.source === "user"));

	const project = discoverAgents(cwd, "project");
	assert.deepEqual(project.agents.map((agent) => agent.name), ["project-only", "shared"]);
	assert.ok(project.agents.every((agent) => agent.source === "project"));

	const both = discoverAgents(cwd, "both");
	const shared = both.agents.find((agent) => agent.name === "shared");
	assert.equal(shared?.description, "project version");
	assert.equal(shared?.source, "project");
	assert.deepEqual(both.agents.map((agent) => agent.name), ["shared", "user-only", "project-only"]);
});

test("formats empty and limited agent lists", () => {
	assert.deepEqual(formatAgentList([], 10), { text: "none", remaining: 0 });
	const agents = [
		{ name: "one", description: "first", source: "user" },
		{ name: "two", description: "second", source: "project" },
		{ name: "three", description: "third", source: "user" },
	];
	assert.deepEqual(formatAgentList(agents, 2), {
		text: "one (user): first; two (project): second",
		remaining: 1,
	});
	assert.deepEqual(formatAgentList(agents, 0), { text: "", remaining: 3 });
});
});
