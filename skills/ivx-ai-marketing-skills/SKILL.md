---
name: ivx-ai-marketing-skills
description: >
  Router for ericosiu/ai-marketing-skills installed as personal Cursor skills
  (ams-*). Use when the user says AI marketing skills, ams skills, growth
  engine, outbound engine, content ops expert panel, SEO ops, sales pipeline,
  podcast-to-everything, short-form clip pipeline, X longform, YouTube
  competitive analysis, CRO audit, or asks which Single Grain / Single Brain
  marketing skill to load.
---

# AI Marketing Skills (router)

**Source:** [ericosiu/ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills)  
**Installed as:** personal Cursor skills under `~/.cursor/skills/ams-*/`  
**Vendor clone (update with git pull):** `~/.cursor/skills/_vendor/ai-marketing-skills/`

## Mandatory agent behavior

1. Pick the best `ams-*` skill from the table (or ask once if ambiguous).
2. **Immediately Read** that skill’s `SKILL.md` (and any linked references it names).
3. Run commands from that skill’s folder so relative scripts resolve.
4. Tell the user in one line: `Loaded: ams-<name>`.
5. Do **not** invent a parallel marketing workflow when an `ams-*` skill covers it.

## Disambiguation (Content Factory)

| User likely means | Load instead |
|-------------------|--------------|
| CF creative marketing / cite gate / brand calendar | `@cf-creative-marketing` + Firecrawl |
| CF video loop / Wan / Veo / plan→APPROVE→generate | `@video-skills` / `@cf-video-loop` |
| Growth Calendar / ops HTML week | `@cf-growth-calendar` |
| This open-source marketing pack | **this router** → matching `ams-*` |

CF product path truth still wins for CF pipelines (LiteLLM, Postiz, no phantom `src/`).

## Pack map (say → load)

| Say / job | Read |
|-----------|------|
| **growth experiments / A/B / scorecard** | `~/.cursor/skills/ams-growth-engine/SKILL.md` |
| **visitor → pipeline / deal resurrect / ICP** | `~/.cursor/skills/ams-sales-pipeline/SKILL.md` |
| **expert panel / score to 90+ / content QA** | `~/.cursor/skills/ams-content-ops/SKILL.md` |
| **cold outbound / Instantly sequences** | `~/.cursor/skills/ams-outbound-engine/SKILL.md` |
| **SEO / GSC / keyword gaps** | `~/.cursor/skills/ams-seo-ops/SKILL.md` |
| **CFO / runway / build cost** | `~/.cursor/skills/ams-finance-ops/SKILL.md` |
| **Gong / attribution / client report** | `~/.cursor/skills/ams-revenue-intelligence/SKILL.md` |
| **CRO / landing page / lead magnet** | `~/.cursor/skills/ams-conversion-ops/SKILL.md` |
| **podcast → multi-platform** | `~/.cursor/skills/ams-podcast-ops/SKILL.md` |
| **team audit / meeting actions** | `~/.cursor/skills/ams-team-ops/SKILL.md` |
| **value pricing / deal upsell** | `~/.cursor/skills/ams-sales-playbook/SKILL.md` |
| **autoresearch / 50+ variants** | `~/.cursor/skills/ams-autoresearch/SKILL.md` |
| **deck / pitch slides** | `~/.cursor/skills/ams-deck-generator/SKILL.md` |
| **YouTube outliers / packaging** | `~/.cursor/skills/ams-yt-competitive-analysis/SKILL.md` |
| **X long-form / humanizer** | `~/.cursor/skills/ams-x-longform-post/SKILL.md` |
| **short-form clips from YouTube** | `~/.cursor/skills/ams-short-form-pipeline/SKILL.md` |
| **long-form highlight clips** | `~/.cursor/skills/ams-video-clip-pipeline/SKILL.md` |
| **captions / titles for clips** | `~/.cursor/skills/ams-video-caption-generator/SKILL.md` |
| **lead dossier / account research** | `~/.cursor/skills/ams-lead-dossier/SKILL.md` |
| **clone a website** | `~/.cursor/skills/ams-clone-site/SKILL.md` |
| **content idea scoring menu** | `~/.cursor/skills/ams-content-eval/SKILL.md` |
| **closed-loop analytics upgrade** | `~/.cursor/skills/ams-closed-loop-analytics-upgrade/SKILL.md` |

## Update / reinstall

```powershell
cd $env:USERPROFILE\.cursor\skills\_vendor\ai-marketing-skills
git pull
python ..\install_ams_skills.py
```

## Secrets & safety

- Never commit `.env`, API keys, or customer PII.
- Upstream includes optional PII sanitizer under vendor `security/` — use before sharing dumps.
- Prefer CF LiteLLM / Firecrawl / Postiz when the task is Content Factory production work.

## Related CF skills

- `@cf-creative-marketing` — CF marketing rules + cite gate
- `@cf-growth-calendar` — week calendar ops HTML
- `@contentx-firecrawl-validation` — claim verification
- `@video-skills` — CF video generation loop
