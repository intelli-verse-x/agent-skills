---
name: ivx-ams-outbound-engine
description: >-
  Design and optimize cold outbound email: ICP, sequences, expert scoring to 90+, infra
  audit, Instantly-ready campaigns. Use for cold email, outbound sequences, or Instantly
  campaign design.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: outbound-engine
  install: cursor-personal
---


## Working directory

```bash
cd ~/.cursor/skills/ams-outbound-engine
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-outbound-engine
```
## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

## Startup: Determine Mode

Ask the user:
1. Do you have an **existing Instantly account** with campaigns to audit, or are you **starting from scratch**?
2. Do you have an **Instantly API key**? (Required for audit mode.)

If API key provided → run `scripts/instantly-audit.py` to pull campaigns, account inventory, and warmup scores before proceeding.

## Phase 2: Expert Panel Recursive Scoring

**Target: 90/100. Non-negotiable. Iterate until reached.**

### Round Structure
Each round produces:
1. **Score table** — all 10 panelists, individual score (0-100), one-line rationale
2. **Aggregate score** — average of all 10
3. **Top weaknesses** — ranked list of what's holding the copy back
4. **Changes made** — specific edits addressing each weakness
5. **Updated copy** — full revised sequence after changes

### Scoring Criteria (per panelist's lens — see `references/expert-panel.md`)
- Subject line curiosity / open rate potential
- First sentence pattern interrupt
- Body clarity and brevity
- CTA softness and specificity
- Sequence flow and follow-up logic
- Deliverability risk signals (spam words, link density)
- Personalization believability

### Rules
- Scores must be brutally honest. No padding to 90 without earning it.
- If round score < 90: identify top 3 weaknesses, revise copy, run next round.
- If round score ≥ 90: finalize copy and proceed to deliverables.
- Show every round in the final doc — the iteration trail is part of the value.

## Capacity Math Formula

```
Accounts ready (score ≥80, ≥14 days warmup) × 30 emails/day = conservative daily volume
Accounts ready × 50 emails/day = aggressive daily volume
Daily volume × 22 working days = monthly send capacity
Monthly sends × expected reply rate = expected replies
Expected replies × qualification rate = pipeline opportunities
```

## Add-On Recommendations (mention but don't build)

- **LinkedIn automation:** HeyReach or similar for multi-channel sequences. Separate workflow.
- **Lead enrichment:** Clay or Apollo for personalization data before upload.
- **Lead pipeline:** Use `scripts/lead-pipeline.py` for Apollo → LeadMagic → Instantly automation.

## Reference Files

| File | Purpose |
|------|---------|
| `references/instantly-rules.md` | Variable syntax, sequence structure, deliverability rules |
| `references/expert-panel.md` | Default 10-expert roster with scoring lenses |
| `references/copy-rules.md` | Email copy rules (first sentence, CTA, stats framing) |
| `references/icp-template.md` | ICP data collection template |
| `scripts/instantly-audit.py` | Pulls campaigns, accounts, warmup scores via Instantly v2 API |
| `scripts/lead-pipeline.py` | End-to-end lead sourcing pipeline |
| `scripts/competitive-monitor.py` | Competitor tracking and intelligence |
| `scripts/cross-signal-detector.py` | Multi-source signal detection |
| `scripts/cold-outbound-sender.py` | Send approved outbound emails |
