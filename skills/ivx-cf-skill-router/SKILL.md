---
name: ivx-cf-skill-router
description: >
  Easy entry skill packs for Content Factory. Use when the user says skill pack,
  skill router, loop skills, video skills, pipeline skills, debug skills,
  marketing skills, or asks which skills to load. Maps one short phrase to the
  required .cursor/skills and .cursor/loops files, then auto-loads them.
---

# CF Skill Router (easy packs)

**Point:** User says one easy phrase → agent **Read**s every required skill/loop for this codebase. No hunting.

## Mandatory agent behavior

When this skill (or any pack below) matches:

1. Pick the pack from the table (or ask once if truly ambiguous).
2. **Immediately Read** every listed `SKILL.md` / loop file with the Read tool (parallel OK).
3. Follow those skills’ workflows — do not invent a parallel process.
4. Tell the user in one line: `Loaded pack: <name> → <skill list>`.

Do **not** stop after naming skills. **Load** them.

## Packs (say these)

| Say this | Loads (Read these) |
|----------|-------------------|
| **loop skills** / `@loop-skills` | See `@loop-skills` pack (CF workflow loops — not Loops.so email) |
| **loops email** / `@loops-email` | `@loops-email` + personal `loops-api`, `loops-cli`, `loops-lmx`, `loops-email-sending-best-practices` |
| **video skills** / `@video-skills` | `@cf-video-loop`, `@video-generation`, `@storyboarding`, `@style-consistency`, `@visual-evaluation`, `@cf-llm-model-usage` + loop `video-generation-loop.md` |
| **pipeline skills** / `@pipeline-skills` | `@contentx-pipeline-dev`, `@pipeline-orchestration`, `@cf-llm-model-usage`, `@contentx-firecrawl-validation` |
| **debug skills** / `@debug-skills` | `@systematic-debugging`, `@cf-orchestrator` + `debugging-loop.md` + `bug-fixing.md` |
| **marketing skills** | `@cf-creative-marketing`, matching `accounts-*`, `@contentx-firecrawl-validation` |
| **AI marketing skills** / **ams skills** / Single Grain pack | `@ai-marketing-skills` → personal `~/.cursor/skills/ams-*/` (open-source pack) |
| **pr skills** / git pr | `@github-pr-workflow`, `@code-review` + `pr-review-loop.md` |
| **orchestrator** / big job | `@cf-orchestrator` + `orchestrator-loop.md` (then fan out 5–10 agents) |
| **sid orchestra** / **sid swarm** | `@sid-orchestra` + `sid-orchestra-loop.md` (Master→Research→Gate A→Plan→Work→Review→Harness + Bus) |
| **graphify** / codebase map / where does X live | `@cf-graphify` → then `graphify query` / `path` / `explain` on `graphify-out/` (not product Memory Service RAG) |

Paths are under:

- Skills: `.cursor/skills/<name>/SKILL.md`
- Loops: `.cursor/loops/<name>.md`
- Workflows: `.cursor/workflows/<name>.md`
- Personal Loops.so: `~/.cursor/skills/loops-*/SKILL.md`
- Personal AI marketing pack: `~/.cursor/skills/ams-*/SKILL.md` + router `ai-marketing-skills`

## Disambiguation: “loop”

| User likely means | Route to |
|-------------------|----------|
| “loop skills”, “CF loops”, “run the loop”, “video loop”, “debug loop” | **`@loop-skills`** (this repo’s `.cursor/loops/`) |
| “Loops.so”, “Loops email”, “transactional email”, “LMX” | **`@loops-email`** |

If unclear: ask once — “CF workflow loops, or Loops.so email?”

## Related thin pack skills

Prefer the dedicated pack skill when present (same redirect tables, stronger triggers):

- `.cursor/skills/loop-skills/SKILL.md`
- `.cursor/skills/video-skills/SKILL.md`
- `.cursor/skills/pipeline-skills/SKILL.md`
- `.cursor/skills/debug-skills/SKILL.md`

## Rules

- No phantom `src/`
- No secrets in chat
- After loading a pack, do the user’s actual task using those skills
