---
description: Build pipeline — implement spec then validate with lint/test/validate/audit
---
Use the subagent tool to build the feature: $@

## Steps

1. Derive the feature slug from the task
2. Verify `.ai/features/{slug}/spec.md` exists
3. Choose the smallest suitable chain based on the spec and user preference
4. Run it with the subagent tool
5. Report every stage result clearly

## Full Pipeline

```
subagent({
  chain: [
    { agent: "builder", task: "Implement the spec at .ai/features/{slug}/spec.md. Read scout.md for context if available." },
    { agent: "linter", task: "Lint the changed files listed in .ai/features/{slug}/changes.md" },
    { agent: "tester", task: "Run tests for the changed files listed in .ai/features/{slug}/changes.md" },
    { agent: "validator", task: "Validate implementation matches spec. Read .ai/features/{slug}/spec.md and .ai/features/{slug}/changes.md" },
    { agent: "auditor", task: "Security audit the changes. Read .ai/features/{slug}/changes.md and .ai/features/{slug}/spec.md" }
  ]
})
```

## Chain Variants

- **Quick iteration:** builder only
- **Standard:** builder → linter → tester
- **With validation:** builder → linter → tester → validator
- **Full pipeline:** builder → linter → tester → validator → auditor
- **Security focus:** builder → auditor

## Important

- Build blocks while chain runs and streams progress
- Process failures stop chain at failing step
- Re-run `/build` to retry
- Report what passed, failed, or produced findings
