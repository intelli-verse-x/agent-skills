---
name: ivx-cf-video-loop
description: >
  Content Factory video production loop for Cursor agents. Use when the user
  says @video-loop, make/create/generate a video with Content Factory, or asks
  to run a calendar slot into a finished accepted video. Enforces plan APPROVE
  gate and video-acceptance criteria before completion.
---

# Content Factory Video Loop Skill

## When to use

- User invokes `@video-loop`
- “Make a video / short / reel with Content Factory”
- “Run this calendar slot and generate the video”
- “Generate until it passes QA / acceptance”

## When not to use

- Pure code changes to pipelines (use `@implement`)
- Operating a **failed in-flight** cluster job (use `@operator-loop`)
- Publishing-only (use Postiz plan/schedule tools after video PASS)

## Read first

1. `.cursor/loops/video-generation-loop.md` — CF MCP pipeline stage order  
2. `.cursor/loops/sf-wan-video-loop.md` — SiliconFlow dashboard Wan + Fish Speech + combine (when user gens in Playground)  
3. `.cursor/checklists/video-acceptance.md` — PASS/REVISE/FAIL  
4. Matching `accounts-*` skill if `brand_id` known  
5. `get_generation_guide(pipeline_type)` for required fields  

**Which loop?** MCP `trigger_pipeline` → video-generation-loop. User pastes into SiliconFlow dashboard / drops clips → **sf-wan-video-loop**.

## Tool map (MCP `user-content-factory`)

| Stage | Tools |
|-------|-------|
| Intake | `list_available_pipelines`, `get_generation_guide`, `route_content_skills` |
| Research | `research_topic`, `trending_ideas`, `search_web` |
| Plan | `plan_generation`, `enhance_prompt`, `preview_storyboard`, `select_model` |
| GPU | `warm_video_stack`, `gpu_service_status`, `cool_gpu_service` |
| Generate | `trigger_pipeline` (**only** with `user_approved=True`) |
| Poll | `get_task_status`, `get_pipeline_log`, `list_output_files`, `cancel_task` |
| Publish (after PASS) | `plan_social_post` → APPROVE → `schedule_social_post` |

## CLI fallback

Prefer MCP. If MCP is down, use local runner:

```bash
python pipelines/runner.py run \
  --config <configs path for pipeline> \
  --pipeline viral_shorts \
  --args "{\"topic\":\"...\",\"platform\":\"tiktok\",\"style\":\"trendy\",\"audience\":\"Gen Z\"}" \
  --local
```

Still enforce: human plan approval in chat + acceptance checklist before DONE.

## Acceptance (non-negotiable)

A run is **complete** only when:

1. All **MUST** items in `video-acceptance.md` pass  
2. Score **≥ 80 / 100**  
3. Acceptance report posted in the chat  

Otherwise: **REVISE** or **FAIL** and continue the loop (max 3 iterations).

## Minimal happy path

```text
1. route_content_skills / get_generation_guide
2. research_topic
3. plan_generation  →  SHOW PLAN  →  WAIT "APPROVE"
4. (optional) warm_video_stack
5. trigger_pipeline(..., user_approved=True)
6. poll get_task_status every 60–90s
7. list_output_files
8. score vs video-acceptance.md
9. PASS → deliver paths | REVISE → fix → goto 3 or 5
```

## Calendar slot mode

If user points at `VIRAL_CONTENT_CALENDAR.html` / `viral_content_calendar_jul2026.json` slot:

1. Prefer the slot’s **`cursor_agent_prompt`** (already includes @video-loop + skills + brief)
2. Or load slot fields: topic, pipeline, platform, style, audience, brand_id, caption, goal, visual_plan, script_beats
3. Follow **video-generation-loop** until acceptance PASS (≥80)
4. After PASS, attach slot caption/hashtags/CTA in the deliverable
5. Do **not** auto-publish unless user asks and approves `plan_social_post`

### One-liner from calendar

```
@video-loop run calendar slot w1-mon-qv
```

Or paste the green **Copy Cursor @video-loop prompt** button output from the HTML page.

## Output contract (always)

```markdown
### Loop status
- Stage: INTAKE|RESEARCH|PLAN|GENERATE|POLL|ACCEPT|DONE
- task_id:
- iteration: n/3
- verdict: (after ACCEPT) PASS|REVISE|FAIL
- outputs: (paths if any)
```
