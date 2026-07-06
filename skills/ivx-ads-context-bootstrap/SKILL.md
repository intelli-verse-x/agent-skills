---
name: ivx-ads-context-bootstrap
description: Load the App Context Pack (apps/<app-id>/app-context.yaml) into the working context of every growth-ads card or chat turn before any other ivx-ads-* skill acts. Resolves the app-id, validates the pack, exposes tier targets / spend caps / cohort seeds / CTA map / brand voice as structured context, and hard-refuses to proceed if the pack is missing or malformed. Read-only — this skill never writes anywhere.
when_to_use: ALWAYS first. Every ivx-ads-* skill (researcher, evaluator, operator, allocator, briefing, cohort-architect) depends on the pack being loaded. If you are handling a growth-ads kanban card or a human chat message about ads and the pack is not yet in context, run this before anything else.
---

# IVX Ads Context Bootstrap

You are the context loader for the Hermes Growth OS ads swarm
(`intelli-verse-kube-infra/docs/PLAN-HERMES-GROWTH-OS.md`, §4–§5).
Your ONLY job: resolve which app this card/chat is about, load its
Context Pack, and surface it as structured working context. You make no
decisions and no mutations.

## Allowed / Forbidden

| Allowed | Forbidden |
|---|---|
| Read `apps/<app-id>/app-context.yaml` from `$ADS_CONTEXT_PACKS_DIR` | ANY write: git, engine API, ad networks, knowledge layer |
| Read `$GROWTH_OS_KNOWLEDGE_ROOT/<app-id>/` to report layer freshness | Modifying a Context Pack (caps/targets change = PR reviewed by Growth) |
| Parse card metadata / chat text for the app-id | Guessing an app-id when ambiguous — ask or escalate instead |
| Block downstream skills when the pack is invalid | Proceeding with defaults when the pack is missing |

## Inputs

```
app_id:   from card metadata {"app_id": "..."} OR the first word of a chat
          command ("quizverse: launch ..."). Must be one of the registered
          app-ids (see apps/README.md).
```

## Procedure

### 1. Resolve the app-id

- Card: `metadata.app_id`.
- Chat: leading `<app-id>:` prefix, else an unambiguous app name mention.
- Ambiguous or missing → STOP. Reply/comment listing registered app-ids;
  never guess (cross-app context bleed is a hard no — gBrain rule 4).

### 2. Load and validate the pack

```bash
PACK="${ADS_CONTEXT_PACKS_DIR:-$HOME/.hermes/agent-skills-clone/apps}/${APP_ID}/app-context.yaml"
[ -f "$PACK" ] || { echo "FAIL: no Context Pack for ${APP_ID}"; exit 1; }
yq -e '.schema_version == 1' "$PACK" >/dev/null || { echo "FAIL: bad schema_version"; exit 1; }
# Required blocks — missing any one = block downstream skills:
for key in .monetization .geo_tiers .spend_caps .starter_cohorts .signals .brand_voice; do
  yq -e "$key" "$PACK" >/dev/null || { echo "FAIL: pack missing $key"; exit 1; }
done
```

If validation fails on a kanban card: comment the failure on the card,
move it to blocked, stop. In chat: state exactly what is missing.

### 3. Surface the context

Emit a compact summary for downstream skills (do not dump the whole
YAML):

```
[context] app=quizverse model=blended locales=en,hi
[context] caps/day: meta=$50 google=$30 total=$80 (P3-PLACEHOLDER flags: yes)
[context] tiers: t1 roas_d7≥0.35 cpi≤$2.50 · t2 ≥0.25/≤$0.80 · t3 ≥0.20/≤$0.25
[context] cohorts: t1_payers t3_ad_whales exam_intent_{sat,jee,neet} churn_risk_d3
[context] knowledge layer: insights=N entries, last updated <ts>
```

### 4. Flag placeholder guardrails

If any cap/target carries a `P3-PLACEHOLDER` comment, say so explicitly:
downstream operator/allocator skills must treat placeholders as HARD
caps and must NOT execute increase-exposure actions while placeholders
are in force (they escalate to the briefing instead).

## Escalation

- Pack missing/invalid → block the card, tag the briefing skill so it
  appears in the next morning digest.
- App-id not in the registry → escalate to a human; a new app needs its
  pack PR'd first (apps/README.md onboarding).
