---
name: ivx-cf-github-pr-workflow
description: >-
  Runs GitHub PR workflow with Conventional Commits, gh PR create/edit, open-PR
  triage by priority, and post-commit PR updates. Use when the user asks to
  commit (only when asked), open or update a pull request, list open PRs, or
  refresh a PR description after new commits.
---

# GitHub PR Workflow

Golden path for Content Factory git + GitHub via `gh`. Aligns with user commit/PR rules.

## Hard rules

- **Commit only when the user asks** — never commit proactively
- No `git config` changes, no `--no-verify`, no force-push to main/master
- No interactive git (`-i`)
- Never commit secrets (`.env`, credentials, keys)
- HEREDOC for commit messages and PR bodies

## Conventional Commits

Format: `type(scope): description`

| type | When |
|------|------|
| `feat` | New capability |
| `fix` | Bug fix |
| `docs` | Docs only |
| `refactor` | No behavior change |
| `test` | Tests only |
| `chore` | Tooling / maintenance |
| `perf` | Performance |

Scope examples: `api`, `pipelines`, `frontend`, `skills`, `mcp`.

```bash
git commit -m "$(cat <<'EOF'
fix(pipelines): retry Wan job on transient 429

EOF
)"
```

On Windows PowerShell, prefer:

```powershell
git commit -m @"
fix(pipelines): retry Wan job on transient 429

"@
```

## Before commit / PR (gather in parallel)

1. `git status`
2. `git diff` (staged + unstaged)
3. `git log` (recent style)
4. For PRs: `git diff [base]...HEAD` + tracking status

## Create PR

```bash
git push -u origin HEAD
gh pr create --title "type(scope): short summary" --body "$(cat <<'EOF'
## Summary
- Why this change
- What landed (1–3 bullets)

## Test plan
- [ ] Unit / targeted tests
- [ ] Smoke the affected API or UI path
- [ ] No secrets in diff

EOF
)"
```

## Update existing PR after new commits

```bash
git push
gh pr edit --title "..." --body "$(cat <<'EOF'
## Summary
- Updated bullets reflecting latest commits

## Test plan
- [ ] ...

EOF
)"
# or refresh checks view:
gh pr view --json title,body,url,commits,statusCheckRollup
gh pr checks
```

Do **not** amend unless user rules for amend are fully met.

## List open PRs by priority

```bash
gh pr list --state open --limit 50 \
  --json number,title,author,createdAt,labels,isDraft,reviewDecision,url
```

Triage order:

1. Blocking / `critical` / release labels
2. Non-draft with failing checks
3. Review requested / changes requested
4. Oldest non-draft
5. Drafts last

Report: `# · title · priority reason · url`

## Checklist

- [ ] User explicitly asked to commit and/or open/update PR
- [ ] Diff reviewed; no secrets
- [ ] Conventional Commit message
- [ ] PR Summary + Test plan filled
- [ ] Push succeeded; `gh pr` URL returned
- [ ] After new commits: PR body/checks refreshed if needed

## Related

- `.cursor/skills/code-review/SKILL.md`
- `.cursor/loops/pr-review-loop.md`
- User rules: committing-changes-with-git, creating-pull-requests
