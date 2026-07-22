---
name: ivx-cf-suggest-cursor-rules
description: >-
  Proposes small Cursor `.cursor/rules/*.mdc` drafts when the user repeats the
  same correction or hits recurring friction. Use when patterns of “always do X /
  never do Y” appear across turns, or when the user asks to capture a preference
  as a rule — show the draft first and write only after approval.
---

# Suggest Cursor Rules

Pattern from awesome-cursor-skills: turn repeated corrections into durable rules — **propose first, write only if approved**.

## When to trigger

- User corrects the same mistake **≥2 times** in a session or across recent sessions
- Recurring friction (wrong path, wrong tool, wrong tone, forbidden touch)
- User says “always…”, “never…”, “remember to…”, “add a rule for…”

Do **not** invent rules for one-off preferences or secrets.

## Workflow

```text
Detect pattern → Draft rule (.mdc) → Show user → Write only if APPROVED
```

1. **Detect** — Quote the repeated correction in one line (what went wrong → desired behavior)
2. **Draft** — Propose a minimal `.cursor/rules/<name>.mdc` (frontmatter + short body)
3. **Show** — Paste the full draft; ask: approve write? always-apply vs glob?
4. **Write** — Only after explicit approval; then create/update that single file
5. **Confirm** — Path written + when it will apply

## Rule shape (prefer small)

```markdown
---
description: Short third-person when-to-apply
globs: api/**/*.py          # omit for always-apply
alwaysApply: false          # true only if truly universal
---

# Rule title

## Do
- …

## Don't
- …
```

| Preference | Choice |
|------------|--------|
| Applies everywhere | `alwaysApply: true`, no globs |
| Path-specific | `alwaysApply: false` + tight `globs` |
| Rare / optional | Keep as skill or HOT_CONTEXT note instead |

Prefer **glob-scoped** over always-apply when possible.

## Hard constraints

- **Never** touch `.cursor/mcp.json`
- Do not rewrite large existing rules; suggest additive small files
- No secrets, tokens, or env values in rules
- Respect no-touch zones already in `core.mdc` / orchestrator rules
- If a skill already covers it, suggest skill auto-load — not a duplicate rule

## Draft template (for the user)

```markdown
Proposed rule: `.cursor/rules/<kebab-name>.mdc`

Why: <repeated correction in one sentence>

---
description: <WHAT + WHEN>
globs: <optional>
alwaysApply: false
---

# <Title>

- <1–5 concrete agent instructions>
```

## Checklist

- [ ] Pattern is real (repeated or user-requested)
- [ ] Draft shown before any file write
- [ ] User APPROVED path + always-apply/glob choice
- [ ] Did not modify `.cursor/mcp.json`
- [ ] Rule is small and non-duplicative

## Related

- Cursor create-rule skill (personal): create `.mdc` format
- `.cursor/rules/core.mdc` — foundational always-on
- `.cursor/HOT_CONTEXT.md` — short preferences that are not full rules
