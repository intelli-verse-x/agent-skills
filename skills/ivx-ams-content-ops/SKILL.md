---
name: ivx-ams-content-ops
description: >-
  Score and iteratively improve marketing content with an expert panel until 90+. Use for
  content quality gates, expert panel reviews, editorial scoring, or when another skill
  needs a content QA loop.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: content-ops
  install: cursor-personal
---


## Working directory

```bash
cd ~/.cursor/skills/ams-content-ops
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-content-ops
```
## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

## Step 1: Intake — Understand What's Being Scored

Collect or infer from context:

1. **Content/artifact** — The thing(s) to score (paste, file path, or URL)
2. **Content type** — Copy, sequence, landing page, strategy, title, chart, candidate eval, etc.
3. **Offer context** — What's being sold/promoted? To whom? What domain/industry?
4. **Variants** — Are there multiple versions to compare? (A/B/C)
5. **Source skill** — Is this output from another skill? (e.g., cold-outbound-optimizer)
   If yes, note the source for feedback-to-source routing in Step 6.

If context is obvious from the conversation, don't ask — just proceed.

## Step 3: Select Scoring Rubric

Choose the appropriate rubric from `scoring-rubrics/`:

| Content type | Rubric file |
|---|---|
| Blog, social, email, newsletter, scripts | `scoring-rubrics/content-quality.md` |
| Strategy, recommendations, analysis | `scoring-rubrics/strategic-quality.md` |
| Landing pages, ads, CTAs | `scoring-rubrics/conversion-quality.md` |
| Charts, data viz, infographics | `scoring-rubrics/visual-quality.md` |
| Candidate evaluations | `scoring-rubrics/evaluation-quality.md` |
| Other | Synthesize a rubric from the two closest matches |

Read the selected rubric file for detailed criteria and point allocation.

## Step 5: Output Format

### Winner + Score (always at top)

```
## 🏆 Result: [SCORE]/100 — [PASS ✅ | NEEDS WORK ⚠️]

[Final content/artifact here]

**Iterations:** [N] rounds
**Panel:** [Expert names, comma-separated]
```

If variants: show winner first, then runner-up scores.

```
## 🏆 Winner: Variant [X] — [SCORE]/100

[Winning content]

### Runner-up scores
- Variant A: 87/100
- Variant B: 82/100
- Variant C: 91/100 ← Winner
```

### Feedback History (below the result)

Show full scoring rounds.

```
## Step 6: Feedback-to-Source (When Scoring Another Skill's Output)

When the scored content came from another skill, generate a **Source Improvement Brief**:

```
## 🔁 Feedback for [Source Skill]

### What scored low
- [Pattern]: [Specific example from this content]

### Suggested skill improvements
- [Concrete change to the source skill's process/rubric/prompt]

### Patterns to add to source skill
- [Any recurring weakness that should become a rule]
```

This brief can be used to update the source skill's SKILL.md or rubrics.

## Reference Files

| File | Purpose | When to read |
|---|---|---|
| `experts/humanizer.md` | AI writing detection rubric (24 patterns) | Every scoring run |
| `experts/[domain].md` | Pre-built expert panels for common domains | When domain matches |
| `scoring-rubrics/content-quality.md` | Content scoring rubric | Content scoring |
| `scoring-rubrics/strategic-quality.md` | Strategy scoring rubric | Strategy scoring |
| `scoring-rubrics/conversion-quality.md` | Landing page/ad/CTA rubric | Conversion scoring |
| `scoring-rubrics/visual-quality.md` | Chart/data viz/infographic rubric | Visual scoring |
| `scoring-rubrics/evaluation-quality.md` | Candidate/assessment rubric | Eval scoring |
| `references/patterns.md` | Learned rejection patterns | Every scoring run |
| `references/expert-assembly.md` | Domain-expert examples for auto-assembly | When building unfamiliar panels |
