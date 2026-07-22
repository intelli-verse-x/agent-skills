---
name: ivx-ams-content-eval
description: >-
  Generate and score content ideas with an expert panel from transcripts, notes,
  competitors, and trends. Use for ranked content menus or production schedules.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: content-eval
  install: cursor-personal
---


## Working directory

```bash
cd ~/.cursor/skills/ams-content-eval
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-content-eval
```
## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

## Step 1: Gather Raw Material

Collect signal from all available sources. Skip any source that's unavailable.

### Podcast episodes
- Read recent episodes from your podcast transcript directory (last 7 days)
- Extract: topics covered, guest insights, audience questions, contrarian takes
- Note episode titles for dedup against new ideas

### Meeting notes
- Check your meeting notes directory for recent notes
- Extract: client questions, recurring themes, interesting moments, pain points
- Focus on what your target buyers are actually asking about

### Sales call insights
- Check your call recording platform data for recent calls
- Extract: objection patterns, recurring questions, competitor mentions
- Note what prospects are confused about or struggling with

### Trending topics
- Note any topics the user mentions directly
- Check competitor scan results (Step 2) for trending formats/topics
- Look for news hooks or industry shifts you could react to

## Step 3: Generate Ideas

Generate 20-30 content ideas across three formats. Read `references/pillars.md` for
pillar definitions and `references/voice-rules.md` for content voice rules.

### Format targets
| Format | Count | Details |
|--------|-------|---------|
| YouTube Long-form (10-20 min) | 8-10 ideas | Deep dives, screen recordings, frameworks |
| YouTube Shorts (<60 sec) | 8-10 ideas | One punch, one insight, one hook |
| X / LinkedIn Articles | 5-7 ideas | Manifesto-style, data-heavy, contrarian takes |

### Pillar requirement
Every idea MUST connect to at least one pillar defined in `references/pillars.md`.
Ideas that don't clearly serve a pillar get killed.

### Idea format
Each idea needs:
- **Title** — specific, hook-driven, follows voice-rules.md
- **Description** — 1-2 sentences on the content and angle
- **Format** — Long-form / Short / Article
- **Pillar(s)** — which pillar(s) it serves
- **Source signal** — what raw material inspired it (podcast topic, competitor gap, client question, etc.)

### Dedup check
- Check recent published content (last 30 days)
- If a similar angle was covered recently, either kill it or document a genuinely new hook
- Apply the dedup rule from `references/voice-rules.md`

### Manual override
If the user passes specific ideas to score (e.g., "score these content ideas: [list]"),
skip idea generation and go directly to Step 4 with the provided ideas.

## Step 5: Rank and Schedule

### Rank passing ideas
Sort all ideas scoring 85+ by average score, highest first.

### Create 4-week production schedule
Assign passing ideas to weeks based on effort vs impact:

| Week | Focus | Typical content |
|------|-------|-----------------|
| Week 1 | Low effort, high impact | Shorts that can ship same day, reaction clips |
| Week 2 | Medium effort, highest ceiling | Long-form with screen recordings, tutorials |
| Week 3 | High effort, strategic anchors | Articles, manifesto pieces, deep-dive frameworks |
| Week 4 | Compounding content | Reference pieces, reaction content, series starters |

### Kill list
List all ideas that scored <85 with:
- Title
- Average score
- Primary reason for failure (the expert dimension that killed it)

## Reference Files

| File | Purpose | When to read |
|------|---------|--------------|
| `references/pillars.md` | Messaging pillar definitions | Step 3 (idea generation) |
| `references/panel.md` | 7-expert panel with scoring criteria | Step 4 (scoring) |
| `references/competitors.md` | YouTube competitor channel sets | Step 2 (competitive scan) |
| `references/voice-rules.md` | Content voice/style rules | Step 3 (idea generation) |
