---
name: ivx-cf-browser-automation
description: >-
  Automates real browsers with Playwright / playwright-cli for navigate, click,
  fill, screenshot, extract, and multi-tab flows. Use when Cursor agents must
  interact with a live UI, run or extend Content Factory frontend E2E, debug
  visual/auth flows, or capture screenshots — not for scrape-only research
  (prefer Firecrawl).
---

# Browser Automation

Inspired by curated **Browser Automation with playwright-cli** patterns, adapted for Content Factory path truth (no phantom `src/`).

## When to use

- Live UI interaction (click, fill, assert, multi-tab)
- Frontend E2E create/extend/debug
- Auth/session UI debugging with screenshots

## When NOT to use

| Need | Prefer |
|------|--------|
| Scrape / extract page text for research | `contentx-firecrawl-validation` / Firecrawl MCP |
| Static HTML fact-check | Firecrawl |
| API contract tests | `testing` skill + pytest |

## Prefer project E2E first

Existing CF frontend Playwright setup:

- Config: `frontend/playwright.config.js`
- Specs: `frontend/e2e/specs/` (`smoke`, `login`, `pipelines`, `publish`, `audit`)
- CI: `.github/workflows/e2e.yml`

Extend those specs before inventing new harnesses. Do **not** invent `src/` or `src/contentx/`.

## Core patterns (playwright-cli / Playwright)

```text
1. Navigate → wait for load / networkidle (or role-based ready)
2. Locate → getByRole / getByLabel / getByTestId (avoid brittle CSS)
3. Act → click, fill, select, press
4. Assert → expect visible / URL / text
5. Evidence → screenshot on failure; optional trace
```

| Action | Guidance |
|--------|----------|
| Navigate | Prefer absolute app URL from config/env; wait for stable selector |
| Click / fill | Role + name; fill then blur/tab if needed |
| Screenshot | Full page on fail; store under `out/` or `.working_dir/` |
| Extract | Text/attributes only when UI interaction required; else Firecrawl |
| Multi-tab | `context.newPage()` / popup listeners; close extras when done |

## Flake control

1. Prefer auto-waiting locators over fixed `sleep`
2. Retry flaky steps **once** (max 2 attempts) with fresh navigation
3. Isolate shared state (unique user data, no order dependence)
4. Soft-timeouts: fail with screenshot + console/network snippet
5. Mark known flakes in the spec comment; do not mute asserts permanently

## Auth / session caution

- Never commit cookies, storage state, or passwords
- Prefer test accounts / env-injected secrets (K8s secret / local `.env` — never print)
- Do not automate production admin destructive actions without explicit user APPROVE
- Clear storage between tests when auth leaks cause flakes

## Agent checklist

- [ ] Confirmed UI interaction needed (not scrape-only)
- [ ] Checked `frontend/e2e/specs/` for reuse
- [ ] Locators are role/label based
- [ ] Failure path captures screenshot
- [ ] No secrets in repo or logs

## Related

- `.cursor/skills/testing/SKILL.md` — test pyramid / E2E placement
- `.cursor/skills/contentx-firecrawl-validation/SKILL.md` — scrape & fact-check
