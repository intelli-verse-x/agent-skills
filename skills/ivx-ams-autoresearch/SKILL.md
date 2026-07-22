---
name: ivx-ams-autoresearch
description: >-
  Karpathy-style conversion optimization: 50+ variants, expert panel scoring, evolution
  rounds. Use to optimize landing pages, email, ads, headlines before real traffic tests.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: autoresearch
  install: cursor-personal
---

## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

# Autoresearch Skill

## Working directory

```bash
cd ~/.cursor/skills/ams-autoresearch
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-autoresearch
```

Karpathy-style optimization loops for any conversion-focused content. No traffic needed. Simulated expert panel. Minutes, not weeks.

**When to use this:** Pre-launch content optimization. Generate 50+ variants, score with 5 simulated experts, evolve winners, output the best version + full experiment log.

**When NOT to use this:** Post-launch real-traffic A/B testing — that requires real analytics, not simulated scoring.

> **The sequence:** Run autoresearch FIRST to hit 85+ simulated score. Then deploy. Then validate with real traffic.

## Expert Panel (5 Personas)

Score every variant against all 5. Batch all variants into a **single API call** per round.

| # | Persona | Scoring Lens |
|---|---------|-------------|
| 1 | **CMO at a mid-market B2B company (50M+ revenue)** | "Would this make me stop and engage?" |
| 2 | **Skeptical founder** | "Do I believe this? Would I trust this company?" |
| 3 | **Conversion rate optimizer** | "Is this clear, specific, and action-driving?" |
| 4 | **Senior copywriter** | "Is this compelling, differentiated, and well-crafted?" |
| 5 | **Your CEO/founder** | "Direct, ROI-obsessed, no BS. Would I put this on my site?" |

> **Customization:** Replace persona #5 with your own CEO/founder voice. Define their priorities and communication style in a `references/founder-voice.md` file.

Each judge scores 0–100. **Final score = average across all 5 judges.**

## Content Types & Score Dimensions

### Landing Pages
**Elements to optimize:** Hero headline, subheadline, CTA text, problem section, social proof

**Score dimensions:**
- `first_impression` — Does it grab immediately?
- `clarity` — Is the offer instantly understood?
- `trust` — Does it feel credible?
- `urgency` — Is there a reason to act now?
- `would_convert` — Would the judge actually click?

### Email Sequences
**Elements to optimize:** Subject line, opening line, body copy, CTA, PS line

**Score dimensions:**
- `would_open` — Subject line pass rate
- `would_read` — Does the opening hook?
- `would_click` — Is the CTA compelling?
- `would_reply` — Does it feel personal enough to respond to?
- `spam_risk` — Does it feel spammy? (lower = better; invert for final score)

### Ad Copy
**Elements to optimize:** Headline, description, CTA

**Score dimensions:**
- `scroll_stopping` — Does it interrupt the scroll?
- `clarity` — Is the value prop clear in 3 seconds?
- `click_worthiness` — Does the judge want to click?
- `relevance` — Does it match likely audience intent?
- `differentiation` — Does it stand out from competitors?

### Form Pages
**Elements to optimize:** Headline, subtext, value prop bullets, button text, field order, thank-you copy

**Score dimensions:**
- `first_impression` — Does it feel worth filling out?
- `trust` — Do they believe their info is safe and the offer is real?
- `completion_likelihood` — Would the judge start filling it out?
- `lead_quality` — Would this attract serious prospects (not tire-kickers)?
- `would_fill_out` — Final gut check: would they submit?

## User Options

| Option | Default | Description |
|--------|---------|-------------|
| `elements` | all | Which elements to optimize |
| `variants_per_round` | 10 | How many variants to generate per round |
| `min_score` | 80 | Stop when this score is hit |
| `rounds` | 3 | Max rounds before stopping |
| `auto_apply` | false | Whether to overwrite the source file with winners |
| `content_type` | auto-detect | Force a content type if auto-detect is wrong |

## Anti-Patterns to Avoid

- **Never call the API once per variant.** Always batch. A 10-variant round = 1 call.
- **Don't over-optimize for one dimension.** If you're hitting 95 on clarity but 45 on trust, the overall score is misleading.
- **Don't run more than 5 rounds.** If you're not hitting 80 after 3 rounds, the problem is strategic (wrong positioning), not tactical (wrong words).
- **Don't cross-breed until each element has its own winner.** Premature cross-breeding creates incoherent combinations.
