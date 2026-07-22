---
name: ivx-cf-loops-email
description: >-
  Installs and routes to official Loops.so agent skills (API, CLI, LMX, email
  best practices) for transactional and marketing email. Use when integrating
  Loops, sending transactional mail, auditing deliverability, or when the user
  mentions Loops.so — not for Content Factory `.cursor/loops/` workflow loops.
---

# Loops Email (Loops.so)

**Disambiguation:** This skill is about **Loops.so** (email product). It is **not** Content Factory workflow loops under `.cursor/loops/` (debugging-loop, video-generation-loop, etc.).

If the user said **“loop skills”** / CF loops / video loop / debug loop → **stop** and load `@loop-skills` instead (`.cursor/skills/loop-skills/SKILL.md`).

Do **not** vendor full Loops skill bodies into this repo. Install and point agents at the official packages.

## Install (official)

Docs: https://loops.so/docs/skills

```bash
# CLI + every agent skill
curl -fsSL https://install.loops.so/wizard | sh

# Skills only (API, CLI, LMX, email best practices)
curl -fsSL https://install.loops.so/skills | sh

# Alternative
npx skills add loops-so/skills
```

After install, Cursor should see the four skills under `~/.cursor/skills/` (`loops-api`, `loops-cli`, `loops-lmx`, `loops-email-sending-best-practices`). This repo also keeps this thin router skill at `.cursor/skills/loops-email/` for discovery and disambiguation.

## What each Loops skill covers

| Skill | Use for |
|-------|---------|
| **API** | Campaigns, contacts, properties, lists, events, transactional email in-app |
| **CLI** | Real Loops calls from terminal, IDs, smoke tests |
| **LMX** | Loops markup for create/update email templates |
| **Email best practices** | Deliverability, lifecycle, consent, transactional vs marketing setup |

## When to use (CF / product)

| Scenario | Guidance |
|----------|----------|
| Transactional (receipts, magic links, alerts) | Loops transactional API/events; keep marketing tags off |
| Marketing / campaigns | Lists + consent; never mix into transactional streams casually |
| Deliverability audit | Use Loops **email best practices** skill; check SPF/DKIM/DMARC, bounce/complaint handling |
| CF pipeline notifications | Prefer existing CF observability first; use Loops only when product email is in scope |

## Secrets

- Requires a Loops account and API key
- Store keys in env / secret manager — **never commit** API keys, `.env`, or webhook secrets
- Do not print keys in logs or PR bodies

## Agent workflow

1. Confirm user wants **Loops.so** (not `.cursor/loops/`)
2. Ensure install completed (wizard or skills installer)
3. Follow the installed Loops skill for the task (API vs CLI vs LMX vs audit)
4. Keep CF path truth: app code under `api/`, `pipelines/`, etc. — no phantom `src/`

## Related

- Official docs: https://loops.so/docs/skills
- CF workflow loops (different): `.cursor/loops/`
