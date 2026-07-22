---
description: Scout gathers context, planner creates implementation plan with interactive Q&A
---
Use the subagent tool with the chain parameter to execute this workflow:

1. First, use the "scout" agent to find all code relevant to: $@
2. Then, use the "planner" agent to create an implementation plan for "$@" using the context from the previous step (use {previous} placeholder). Set interactive: true so the planner can ask you clarifying questions.

Execute this as a chain, passing output between steps via {previous}. The planner runs interactively — it will ask questions and you can answer them before it finalizes the plan.

Example call:
```
subagent({
  chain: [
    { agent: "scout", task: "Find all code relevant to: $@" },
    { agent: "planner", task: "Create an implementation plan for \"$@\" using this context: {previous}", interactive: true }
  ]
})
```
