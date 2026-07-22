---
name: ivx-cf-persona-router
description: >
  Easy person packs for Content Factory personas. Use when the user says person
  pack, persona router, person backend, person frontend, person unity, which
  persona, or asks for backend/frontend/Unity/devops/creative/ML/product person.
  Maps one person type to the right .cursor/agents persona plus required skills,
  then auto-loads them.
---

# CF Persona Router (easy person packs)

**Point:** Say a **person type** → agent loads that persona file **and** the skills that person needs.

Personas live in `.cursor/agents/<name>.md` (not `agents/` Python folder).

## Mandatory agent behavior

1. Match a person pack from the table (or ask once if unclear).
2. **Read** the pack skill (if any) OR every persona + skill listed below.
3. Act **as that person** (use their Approach / Expertise).
4. Say one line: `Loaded person: <pack> → personas […] + skills […]`.

## Person packs (say these)

| Say this | Primary personas (Read `.cursor/agents/…`) | Also load skills |
|----------|--------------------------------------------|------------------|
| **person backend** / `@person-backend` | `senior-backend-engineer`, `api-architect`, `database-architect` | `api-design`, `contentx-pipeline-dev`, `testing`, `security-review` |
| **person frontend** / `@person-frontend` | `react-expert`, `nextjs-expert`, `ux-strategist` | `browser-automation`, `testing`, `jeremylongshore-claude-code-plugins-plus-skills-top-design` (UI) |
| **person unity** / `@person-unity` | `unity-expert` | `cf-hyworld-fortnite`, `image-generation`, `storyboarding` |
| **person devops** / `@person-devops` | `devops-engineer`, `platform-engineer`, `kubernetes-expert` | `pipeline-orchestration`, `security-review` (no touch `infra/` / Docker / workflows unless human approved) |
| **person gpu** / `@person-gpu` | `gpu-infrastructure-engineer`, `mlops-engineer` | `gpu-optimization`, `cf-llm-model-usage`, `cost-optimization` |
| **person creative** / `@person-creative` | `creative-ai-director`, `video-generation-scientist`, `image-generation-scientist`, `prompt-engineer` | `video-skills` pack (or video-generation + storyboarding + style-consistency), `cf-creative-marketing` |
| **person ml** / `@person-ml` | `ml-research-engineer`, `llm-researcher`, `ai-research-scientist` | `experiment-tracking`, `evaluation`, `cf-llm-model-usage` |
| **person product** / `@person-product` | `product-manager`, `ai-product-manager` | planning via `AGENTS.md` `@plan` |
| **person orchestrator** / `@person-orchestrator` | `orchestrator` | `cf-orchestrator`, `cf-skill-router`, `orchestrator-loop.md` |

Dedicated pack skills (prefer these — stronger triggers):

- `.cursor/skills/person-backend/SKILL.md`
- `.cursor/skills/person-frontend/SKILL.md`
- `.cursor/skills/person-unity/SKILL.md`
- `.cursor/skills/person-devops/SKILL.md`
- `.cursor/skills/person-gpu/SKILL.md`
- `.cursor/skills/person-creative/SKILL.md`
- `.cursor/skills/person-ml/SKILL.md`
- `.cursor/skills/person-product/SKILL.md`
- `.cursor/skills/person-orchestrator/SKILL.md`

## How to pick in chat

Examples:

- “Act as **person backend** and fix the FastAPI route”
- “**person frontend** — review this React page”
- “**person unity** — Fortnite map on RunPod”
- “`@person-creative` for a QuizVerse short”

## Related

- Skill packs: `@cf-skill-router`, `@loop-skills`, `@video-skills`, …
- Layman map: `docs/HOW_TO_USE_SKILLS.md`
- All personas: `.cursor/agents/*.md` (each has `## Person type`)
