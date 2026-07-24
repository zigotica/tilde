# Subagent Extension

Enhanced version of [Pi agent harness](https://pi.dev) [official subagent example](https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent). Adds persistent interactive planning, structured build-validation workflows, per-agent model and thinking configuration, and fallback to parent session settings.

Extension uses modular, testable architecture: schemas, process execution, workflow orchestration, and TUI rendering are separated behind explicit dependency boundaries. This enables deterministic testing of single, parallel, and chained subagents without launching real Pi processes or calling models.

## Workflow

```text
/plan <task>   Start scout plus persistent interactive planner
/build <task>  Run blocking implementation and validation chain
```

## Extension Architecture

```text
extensions/subagent/
├── index.ts    Tool registration and production dependency wiring
├── schema.ts   Tool schemas and shared contracts
├── agents.ts   User and project agent discovery
├── runner.ts   Pi process lifecycle, event parsing, fallback, and prompts
├── execute.ts  Single, parallel, and chain orchestration
└── render.ts   TUI call and result rendering
```

Side effects use explicit boundaries:

- `ProcessRunner` abstracts child-process lifecycle and output streams.
- Prompt-file storage owns secure temporary prompt creation and cleanup.
- Output writer owns result persistence and directory creation.
- Execution accepts injected discovery, runner, confirmation, and storage dependencies.

Production uses real Pi, filesystem, and UI adapters. Tests use deterministic fakes, covering orchestration, process parsing, fallback, abort handling, rendering, and registration without real model calls.

## Agents

| Agent | Role |
|---|---|
| scout | Codebase reconnaissance → `scout.md` |
| planner | Planning agent → `spec.md` |
| builder | Implement spec → `changes.md` |
| linter | Lint, formatting, and type checks |
| tester | Test suite |
| validator | Validate implementation against spec |
| auditor | Security audit |

Standard `/plan` starts scout, then a persistent planner child. Planner returns a numbered `STATUS: QUESTIONS` batch. Parent shows it unchanged and passes user replies back into same planner session until explicit confirmation produces `STATUS: SPEC_READY` and `spec.md`.

## Artifacts

```text
.ai/features/{slug}/
├── scout.md
├── spec.md
└── changes.md
```

Downstream lint, test, validation, and audit results return through chain output rather than extra artifact files.

Planner sessions use Pi's standard project-scoped session storage under global Pi config. Extension supplies stable session ID but does not override Pi's session directory.

## Chain Composition

Parent chooses smallest suitable chain:

| Chain | Use |
|---|---|
| builder | Quick implementation |
| builder → linter | Quick static verification |
| builder → tester | Functional verification |
| builder → linter → tester | Standard |
| builder → linter → tester → validator | Standard plus spec check |
| builder → linter → tester → validator → auditor | Full pipeline |
| builder → auditor | Security-focused |

Build uses existing blocking `subagent` chain mode. Re-run `/build` to retry. No workflow status or resume commands.

## Development

```bash
cd extensions/subagent
npm test
npm run typecheck
```

Tests use Node's built-in test runner and do not invoke real Pi processes or models.

## Install

Project-local:

```bash
mkdir -p .pi/extensions/subagent .pi/agents .pi/prompts
cp -r extensions/subagent/. .pi/extensions/subagent/
cp README.md .pi/extensions/subagent/README.md
cp agents/*.md .pi/agents/
cp prompts/*.md .pi/prompts/
```

Global:

```bash
mkdir -p ~/.pi/agent/extensions/subagent ~/.pi/agent/agents ~/.pi/agent/prompts
cp -r extensions/subagent/. ~/.pi/agent/extensions/subagent/
cp README.md ~/.pi/agent/extensions/subagent/README.md
cp agents/*.md ~/.pi/agent/agents/
cp prompts/*.md ~/.pi/agent/prompts/
```

Reload Pi after installation.
