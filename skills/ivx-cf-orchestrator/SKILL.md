---
name: ivx-cf-orchestrator
description: >
  Content Factory multi-agent orchestrator. Use when the user says @orchestrator,
  asks to divide work, run a swarm, coordinate specialists, or when the task is
  non-trivial (multi-file, audit, cleanup, feature, incident). ALWAYS launch
  5–10 agents with clear scopes; merge results; block guesswork.
---

# CF Orchestrator Skill

## When to use

- User invokes `@orchestrator`
- Multi-file / multi-domain / unclear scope
- Project cleanup, agent-OS fixes, audits
- Features that touch API + pipeline + prompts + tests
- Incidents that need code + infra + provider lanes

## When not to use

- Single-sentence Q&A
- One-line typo / rename in one known file
- User explicitly says “solo / no swarm / don’t spawn agents”

## Read first

1. `.cursor/agents/orchestrator.md` — persona + lane templates  
2. `.cursor/loops/orchestrator-loop.md` — stage order  
3. `.cursor/rules/core.mdc` — no-touch / LiteLLM / prompt_registry  
4. `.cursor/HOT_CONTEXT.md` — real paths  
5. Root `AGENTS.md` — command map (not `.cursor/AGENTS.md`)  

## Mandatory swarm size

| | |
|--|--|
| Minimum agents | **5** |
| Maximum agents | **10** |
| Default | **7** for medium tasks, **9–10** for audits/incidents |

**Always-on rule** `.cursor/rules/orchestrator.mdc`: for non-trivial CF work you **must** fan out. Solo only for true one-liners or explicit `solo` opt-out.

## Launch protocol (Cursor Task tool)

In **one** assistant turn, fire independent lanes together:

```
Task(subagent_type=..., description="Lane 1 short title", prompt="...", readonly=true|false)
Task(...)
... up to 10
```

Each `prompt` MUST include:

1. Goal (one line)  
2. In-scope paths (exact)  
3. Out-of-scope / forbidden paths  
4. Done-when checklist  
5. “Do not invent files; if path missing, say MISSING”  
6. Return format: findings / evidence paths / recommended action  

### Suggested subagent_type map

| Lane | subagent_type |
|------|----------------|
| Layout / find files | `explore` |
| Broad research | `generalPurpose` |
| Shell counts / git | `shell` |
| FastAPI / Python | `senior-backend-engineer` |
| API contracts | `api-architect` |
| K8s / EKS | `kubernetes-expert` |
| Deploy | `devops-engineer` |
| GPU / inference | `gpu-infrastructure-engineer` |
| Video gen | `video-generation-scientist` |
| Image gen | `image-generation-scientist` |
| Prompts | `prompt-engineer` |
| Product priority | `product-manager` / `ai-product-manager` |
| Security pass | `security-review` (readonly) |
| Platform / DX | `platform-engineer` |

## Anti-guess rules (inject into every lane brief)

- Real source roots: `api/`, `pipelines/`, `utils/`, `tools/`, `mcp_server/`, `prompt_registry/`, `agents/` (Python), `configs/`, `interfaces/`
- **Do not** write under `src/` or `src/contentx/` — they do not exist
- Cursor personas: `.cursor/agents/` — not `agents/`
- Workflow commands: root `AGENTS.md`
- Never modify `.cursor/mcp.json`, `infra/`, Dockerfiles, or `api/auth/` unless human approved

## Merge protocol

1. Collect all lane returns  
2. Drop claims with no path evidence  
3. Resolve conflicts by reading the winning file once (parent agent)  
4. Produce one plan or one patch set  
5. If lanes disagree on architecture → stop and ask user (do not pick silently)

## Done criteria

- [ ] 5–10 agents launched (or user opted out)  
- [ ] Each lane had scoped paths + done-when  
- [ ] Merged result cites real paths  
- [ ] No phantom `src/` changes  
- [ ] User gets Goal / Lanes / Status / Result / Next  

## Incident / pipeline triage (Orchestra-inspired)

For **CF pipelines** (Redis / KEDA / LiteLLM) — not Orchestra.io product skills:

1. Identify failing task / step → classify → route a specialist fixer  
2. Triage mode: propose fix + **STOP** for human APPROVE before merge / production retry  
3. Related: `@systematic-debugging`, `@bugfixing` workflow  

## Related

- Loop: `.cursor/loops/orchestrator-loop.md`
- Persona: `.cursor/agents/orchestrator.md`
- Rule: `.cursor/rules/orchestrator.mdc`
- Harness notes: `.cursor/harness/orchestration.md`
