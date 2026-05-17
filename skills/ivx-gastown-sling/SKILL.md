---
name: ivx-gastown-sling
description: Dispatch coding work across the intelli-verse-x gastown swarm — pick the right rig (gastown, hermes-agent, content-factory, intelli-verse-kube-infra, intelliverse-x-games-platform-2, the SDKs, nakama, leantime, etc.), spawn or assign to a polecat with the right role (coder, reviewer, tester), monitor the convoy through to merge via the refinery. Use whenever the user says "have an agent fix X", "swarm on Y", "open PR for Z across all the SDK forks", "assign this work", or anything else that turns a beads task into a running async agent.
---

# Gastown swarm dispatcher

Gas Town (`gt`) is the multi-agent coding swarm runtime. This skill
turns user intent into a slung bead with the right polecat profile,
in the right rig, with the right toolset.

Requires the `gastown` MCP server (PR #7 — `gt mcp serve` via ophis).

## When to use this skill

- User wants async coding work done by a swarm agent.
- User wants the same patch shipped across multiple repos in
  parallel.
- User says "open a PR for X" but doesn't want to do it in the
  current Cursor session.
- Triage backlog and rebalance: "what's stuck? who has capacity?"

## Mental model: rigs and polecats

A **rig** wraps a git repo and manages its agents. Today's active rigs:

| Rig | Repo | Typical work |
|---|---|---|
| `gastown` | `intelli-verse-x/gastown` | Swarm runtime itself |
| `hermes-agent` | `intelli-verse-x/hermes-agent` | Persistent orchestrator |
| `content-factory` | `intelli-verse-x/content-factory` | Media pipelines |
| `kube-infra` | `intelli-verse-x/intelli-verse-kube-infra` | K8s manifests |
| `games-platform` | `intelli-verse-x/intelliverse-x-games-platform-2` | Backend |
| `sdk-unity` | `intelli-verse-x/Intelli-verse-X-Unity-SDK` | Unity SDK |
| `sdk-core` | `intelli-verse-x/Intelli-verse-X-SDK` | Core SDK |
| `sdk-multiplayer` | `intelli-verse-x/Intelli-verse-X-SDK-multiplayer-kernel` | Multiplayer kernel |
| `admin` | `intelli-verse-x/Intelliverse-Admin-Management` | Admin portal |
| `nakama` | `intelli-verse-x/nakama` | Nakama fork |

A **polecat** is a persistent named agent identity with an ephemeral
session. Roles: `coder`, `reviewer`, `tester`, `triager`, `mayor`,
`witness`, `refinery`, `deacon`, `dog`, `boot`.

## The workflow

### Single-repo coding job

1. **Make sure there's a bead.** If the user described work but
   there's no bead, create one:

   ```
   gt_bead_create(
     repo="<rig>",
     title="<concise title>",
     type="task|bug|feature",
     priority=2,
     body="<context the polecat needs>"
   )
   ```

2. **Sling it.** `gt_sling` is THE dispatch command:

   ```
   gt_sling(
     bead="bd-abc12",
     rig="content-factory",
     role="coder",
     agent="claude"   # or "codex", "gemini" — see `gt config default-agent`
   )
   ```

   This spawns a polecat session in a fresh worktree, primes them
   with the bead, and starts work.

3. **Monitor.** `gt_show bd-abc12` shows status, comments, linked
   PR. `gt_trail` shows the full session log.

4. **On `gt done`** (polecat signals work ready), the **Refinery**
   batches the MR, runs verification gates, and merges to main via
   Bors-style bisecting queue. Failed MRs are isolated and
   re-dispatched.

### Multi-repo parallel swarm

For the "ship the same patch to N forks" pattern:

1. **Create a convoy** to track the batch:

   ```
   gt_convoy_create(
     name="oidc-migration-2026",
     bead_titles=[
       "Port auth to OIDC in <rig>" for rig in target_rigs
     ]
   )
   ```

2. **`gt mountain`** activates the convoy with autonomous stall
   detection and smart skip — for epic-scale execution across 5+
   rigs:

   ```
   gt_mountain(convoy="oidc-migration-2026")
   ```

3. **Each rig gets its own coder polecat** in its own worktree, all
   running in parallel.

4. **Surface progress** with `gt_convoy_status` — shows per-rig
   state, blockers, PRs opened.

### Triage / capacity check

Before slinging more work:

```
gt_ready                  # what's unblocked across town
gt_agents                 # who's active + what they're on
gt_costs                  # spend by polecat
gt_mq                     # merge queue depth per rig
```

If something's stuck:

```
gt_release bd-xyz99       # release a stuck in_progress bead back to pending
gt_escalate bd-xyz99 --severity=high  # route through Deacon
```

## Communication patterns

- `gt_mail_send <target> --subject "..." --bead bd-xxx` — persistent
  message routed by bead. Body is built from the bead's current
  state; never re-encode prose state.
- `gt_nudge <target> --bead bd-xxx -m "blocker — auth 500"` —
  immediate wake. Note ≤ 280 chars; if longer, update the bead
  instead.

## Surfacing results

When dispatching, always tell the user:
- The bead ID (so they can `gt_show` later).
- The rig and polecat name (so they can `gt_peek` the session if
  needed).
- The convoy ID if multi-rig.
- An ETA if known (steady-state coding bead ~10-30 min, refactor
  multi-file ~1-3 hr).

## Safety guardrails

- **Never sling work that requires secrets** without confirming the
  polecat's rig has the right env vars wired. Most secrets live in
  per-rig `.env` or hooks-injected.
- **For destructive work** (force-pushes, history rewrites, mass
  deletes) prefer Cursor (you) over a polecat — the swarm is for
  reversible PR-based changes.
- **Cost-aware** — Mountain convoys spawn N polecats simultaneously.
  For a 10-rig swarm running an hour each, expect $20-100 in model
  spend. Check `gt_costs` first.

## Common failures

| Error | Fix |
|---|---|
| `no polecat available for role=coder in rig=X` | The rig may not have polecats configured. `gt polecat create` first. |
| Bead `in_progress` for > 24h with no commits | Polecat may be wedged. `gt show <bead>` → if heartbeat stale, `gt_release <bead>` then re-sling. |
| Convoy stuck on rig N of M | One rig's CI is red. `gt_mq` shows which; fix CI then `gt convoy launch --resume`. |
| Refinery rejects merge | Tests failing on `main`. Refinery isolates the MR — `gt_mq` shows the failure log. |
