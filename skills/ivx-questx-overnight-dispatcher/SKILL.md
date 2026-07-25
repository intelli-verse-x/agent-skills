---
name: ivx-questx-overnight-dispatcher
description: >
  Optional: file the next QuestX overnight smoke/fraud cards on board
  questx-ops via card-intake (same as the CronJob). Use for manual
  "kick overnight now" from Cursor/Hermes.
when_to_use: >
  When a human asks to kick QuestX overnight ops now, or to backfill
  cards if the CronJob missed a window.
---

# IVX QuestX Overnight Dispatcher

One-shot: POST two cards to in-cluster card-intake (or `hermes kanban create`
if you are already on the questx-ops pod).

## Prefer (from inside cluster / with token)

```bash
INTAKE=http://hermes-questx-card-intake.aicart.svc.cluster.local:8090/cards
# CARD_INTAKE_TOKEN from secret hermes-questx-worker-secrets

curl -fsS -X POST "$INTAKE" \
  -H "Authorization: Bearer $CARD_INTAKE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"[manual] QuestX smoke","assignee":"default","priority":1,"skills":["ivx/questx-overnight-smoke"],"body":"Load ivx/questx-overnight-smoke and run it. Then complete."}'
```

If you only have kubectl:

```bash
kubectl exec -n aicart deploy/hermes-questx-worker -c hermes-questx-worker -- \
  hermes kanban --board questx-ops create "[manual] QuestX smoke" \
  --assignee default --created-by operator \
  --skill ivx/questx-overnight-smoke
```

Do not spawn unbounded cards. One smoke + one fraud pulse per kick.
