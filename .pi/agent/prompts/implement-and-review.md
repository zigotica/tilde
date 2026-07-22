---
description: Builder implements, reviewer reviews, builder applies feedback
---
Use the subagent tool with the chain parameter to execute this workflow:

1. First, use the "builder" agent to implement: $@
2. Then, use the "reviewer" agent to review the implementation from the previous step (use {previous} placeholder)
3. Finally, use the "builder" agent to apply the feedback from the review (use {previous} placeholder)

Execute this as a chain, passing output between steps via {previous}.
