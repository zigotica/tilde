---
description: Interactive planning through persistent planner session
argument-hint: "<feature task>"
---
Plan feature interactively: $@

## Start

1. Derive stable feature slug from task.
2. Create `.ai/features/{slug}/`.
3. Run scout and save its output to `.ai/features/{slug}/scout.md`:
   ```
   subagent({
     agent: "scout",
     task: "Investigate codebase for: $@. Focus on relevant files, patterns, constraints, and architecture.",
     outputFile: ".ai/features/{slug}/scout.md"
   })
   ```
4. Start persistent planner:
   ```
   subagent({
     agent: "planner",
     session: "feature-{slug}-planner",
     task: "Plan feature: $@. Feature slug: {slug}. Read .ai/features/{slug}/scout.md. Follow structured QUESTIONS/SPEC_READY protocol."
   })
   ```
5. If planner returns `STATUS: QUESTIONS`, show numbered questions unchanged.
6. Stop current turn and wait for user to reply. Do not answer for them.

## Completion

Planner must receive explicit confirmation before writing spec. When planner returns `STATUS: SPEC_READY`:

1. Verify reported `spec.md` exists.
2. Read it and summarize agreed scope.
3. Tell user `/build {slug}` is ready.

## Important

- Planner child owns planning context; parent only presents questions and passes user replies back to planner.
- Always reuse exact planner session key.
- Never restart planner for later replies.
- Never infer or fill missing answers.
