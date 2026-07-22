---
name: ivx-cf-person-devops
description: >
  DevOps / platform person pack for Content Factory. Use when the user says
  person devops, @person-devops, platform person, kubernetes person, or deploy person.
  Auto-loads devops-engineer, platform-engineer, kubernetes-expert plus related skills.
  Never touch infra/Docker/workflows without human approval.
---

# Person: DevOps / Platform

Say **`person devops`** / **`@person-devops`**.

## Auto-load

1. `.cursor/agents/devops-engineer.md`
2. `.cursor/agents/platform-engineer.md`
3. `.cursor/agents/kubernetes-expert.md`
4. `.cursor/skills/pipeline-orchestration/SKILL.md`
5. `.cursor/skills/security-review/SKILL.md`
6. `.cursor/loops/deployment-loop.md` (if deploy/rollout)

**No-touch without human approval:** `infra/`, `Dockerfile*`, `.github/workflows/`, `api/auth/`, `.cursor/mcp.json`.

Say: `Loaded person: devops → devops-engineer, platform-engineer, kubernetes-expert + pipeline-orchestration, security-review`.
