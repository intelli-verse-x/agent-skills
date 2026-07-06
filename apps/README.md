# App Context Packs (Hermes Growth OS)

One versioned `apps/<app-id>/app-context.yaml` per portfolio app
(plan §5, `intelli-verse-kube-infra/docs/PLAN-HERMES-GROWTH-OS.md`).
Every `ivx-ads-*` skill loads the pack for the app it is working on via
`ivx-ads-context-bootstrap` — **nothing app-specific is hard-coded in a
skill**. Onboarding a new app = one YAML file here, zero code.

The schema is fixed; the values are per-app. PR-reviewed like any skill
change — spend caps and ROAS targets in these files are the enforcement
source for the in-skill guardrails, so a caps change MUST go through
review (Growth lead approves).

App-ids must match `intelli-verse-kube-infra/n8n/app-registry-for-n8n.json`:
`quizverse`, `questx`, `intelliverse`, `toba`, `contentx`, `kioskx`.

Onboarding waves (plan §5): quizverse (1) → questx, toba (2) →
intelliverse, contentx, kioskx (3).
