---
name: ivx-cf-loop-skills
description: >
  Content Factory workflow loop pack. Use when the user says loop skills, CF loops,
  run the loop, which loop, video loop, debug loop, coding loop, planning loop,
  orchestrator loop, or @loop-skills. Auto-loads the matching .cursor/loops file
  plus required Cursor skills for this codebase. Not for Loops.so email (use loops-email).
---

# Loop Skills Pack (CF `.cursor/loops/`)

**Easy use:** say `loop skills` or `@loop-skills` → agent loads the right loop **and** the skills that loop needs.

**Not this pack:** Loops.so email → `@loops-email`.

## Auto-load protocol (do this first)

1. Pick the loop from “Which loop?” below (from user words or task).
2. **Read** the loop file + every skill in that row (parallel Read OK).
3. Say: `Loaded loop pack: <loop> → <skills>`.
4. Run the user’s task following those files.

## Which loop?

| User says / task | Read loop | Also Read these skills |
|------------------|-----------|------------------------|
| orchestrator, fan out, multi-file, swarm | `.cursor/loops/orchestrator-loop.md` | `cf-orchestrator`, `cf-skill-router` |
| video, reels, shorts, `@video-loop` | `.cursor/loops/video-generation-loop.md` | `cf-video-loop`, `video-generation`, `storyboarding`, `style-consistency`, `visual-evaluation`, `cf-llm-model-usage` |
| bug, broken, failed task, `@bugfixing` | `.cursor/loops/debugging-loop.md` | `systematic-debugging`, `cf-orchestrator` + workflow `.cursor/workflows/bug-fixing.md` |
| plan, PRD, roadmap | `.cursor/loops/planning-loop.md` | (personas via AGENTS.md `@plan`) |
| implement, write code | `.cursor/loops/coding-loop.md` | `contentx-pipeline-dev` if pipeline; else task-matched skills |
| review PR | `.cursor/loops/pr-review-loop.md` | `code-review`, `github-pr-workflow` |
| deploy, rollout | `.cursor/loops/deployment-loop.md` | (devops persona; do not touch `infra/` without approval) |
| architecture | `.cursor/loops/architecture-loop.md` | `architecture-review` |
| eval, QA gate | `.cursor/loops/evaluation-loop.md` | `evaluation`, `testing` |
| creative iterate | `.cursor/loops/creative-iteration-loop.md` | `cf-creative-marketing` or video pack as fits |
| research model/topic | `.cursor/loops/research-loop.md` | `contentx-firecrawl-validation`, `cf-llm-model-usage` if models |
| experiment / ML | `.cursor/loops/experiment-loop.md` | `experiment-tracking`, `evaluation` |
| unclear “loop skills” | `.cursor/loops/orchestrator-loop.md` | `cf-orchestrator`, `cf-skill-router` — then ask which job |

Skill paths: `.cursor/skills/<name>/SKILL.md`

## Recurring `/loop` (Cursor wake loop)

If the user uses Cursor **`/loop`** (timed wake): follow `~/.cursor/skills-cursor/loop/SKILL.md` **and** still load the CF loop pack above for the work inside each tick.

## Related

- Master pack table: `@cf-skill-router`
- Email product: `@loops-email`
- Layman map: `docs/HOW_TO_USE_SKILLS.md`
