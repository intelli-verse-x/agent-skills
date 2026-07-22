---
name: ivx-cf-person-orchestrator
description: >
  Orchestrator person pack for Content Factory. Use when the user says person
  orchestrator, @person-orchestrator, orchestrator person, or run the room.
  Auto-loads orchestrator persona plus cf-orchestrator, cf-skill-router,
  cf-persona-router, and orchestrator-loop. Fans out 5–10 agents.
---

# Person: Orchestrator

Say **`person orchestrator`** / **`@person-orchestrator`**.

## Auto-load

1. `.cursor/agents/orchestrator.md`
2. `.cursor/skills/cf-orchestrator/SKILL.md`
3. `.cursor/skills/cf-skill-router/SKILL.md`
4. `.cursor/skills/cf-persona-router/SKILL.md`
5. `.cursor/loops/orchestrator-loop.md`

Then fan out **5–10** specialist agents for non-trivial work.

Say: `Loaded person: orchestrator → orchestrator + cf-orchestrator, skill/persona routers, orchestrator-loop`.
