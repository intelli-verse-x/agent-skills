---
name: ivx-questx-overnight-smoke
description: >
  Run QuestX / quests-economy live smoke checks (health + critical public
  routes) for overnight Hermes ops on board questx-ops. Report PASS/FAIL;
  never mutate money or ban users.
when_to_use: >
  Overnight CronJob cards titled "[overnight] QuestX smoke", or any
  hermes kanban task that asks for QuestX smoke / health gate.
---

# IVX QuestX Overnight Smoke

You are the overnight smoke operator for **QuestX** (`quests-economy`).

## Hard rules

- **Read-only** toward users/money: no bans, no payouts, no email blasts, no Notifuse send.
- Prefer evidence (HTTP status) over vibes.
- Binary verdict: **PASS** or **FAIL**. Soft warnings OK; never call FAIL “almost PASS”.
- Do **not** ask for human approval / clarify. YOLO overnight — just probe and complete.
- Prefer **one short curl per check**. No multi-line bash scripts, no heredocs.

## Env (already on hermes-questx-worker)

| Var | Meaning |
|-----|---------|
| `QUESTX_API` | API base (`…/api`) |
| `QUESTX_SITE` | Marketing (`quest-x.ai`) |
| `QUESTX_ORIGIN` | App origin (`quests.intelli-verse-x.ai`) |

## Checks (run each as its own single-line command)

```bash
curl -sS -o /tmp/qx1 -w "%{http_code}" --max-time 20 "$QUESTX_ORIGIN/health"
curl -sS -o /tmp/qx2 -w "%{http_code}" --max-time 20 "$QUESTX_SITE/"
curl -sS -o /tmp/qx3 -w "%{http_code}" --max-time 20 "$QUESTX_SITE/join"
curl -sS -o /tmp/qx4 -w "%{http_code}" --max-time 20 "$QUESTX_API/health"
```

Treat 2xx/3xx as OK. If `/health` under API 404s, try `$QUESTX_ORIGIN/api/health` once.

**PASS** if origin health + marketing + join are OK (API soft-warn if only API fails).
**FAIL** if origin health or marketing or join is non-OK.

## On FAIL → chain overnight coding (Mac asleep)

If **FAIL** (origin/marketing/join) and `CARD_INTAKE_TOKEN` is set:

```bash
curl -sS -X POST "${CARD_INTAKE_URL:-http://127.0.0.1:8090/cards}" \
  -H "Authorization: Bearer $CARD_INTAKE_TOKEN" -H "Content-Type: application/json" \
  -d "{\"title\":\"[overnight-code] from smoke FAIL\",\"body\":\"Load skill ivx/questx-overnight-coder.\\ntarget: <failing check>\\nFix minimally, EVALS gate, one PR, kanban_complete.\",\"assignee\":\"default\",\"priority\":1,\"idempotencyKey\":\"questx-code-from-smoke-$(date -u +%Y%m%d%H)\",\"skills\":[\"ivx/questx-overnight-coder\"]}"
```

API-only 404 is soft-warn — still may file a coding card with `target: API /health 404` once per UTC hour.

## Finish (mandatory)

1. Optionally `kanban_comment` with the verdict + HTTP codes.
2. **Last tool call must be `kanban_complete`** (the tool — not shell `hermes kanban complete`).
3. Do not ask “anything else?” — exit only after `kanban_complete` succeeds.
If probes failed hard, still call `kanban_complete` with FAIL in the summary (or `kanban_block` with reason).
