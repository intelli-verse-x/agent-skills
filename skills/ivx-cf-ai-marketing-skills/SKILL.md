---
name: ivx-cf-ai-marketing-skills
description: >
  Bridge to personal Cursor skills from ericosiu/ai-marketing-skills (ams-*).
  Use when the user says AI marketing skills, ams skills, Single Grain marketing
  skills, growth engine, outbound engine, expert panel content ops, SEO ops,
  sales pipeline pack, podcast-to-everything, or asks to load the open-source
  marketing skill pack — not for CF-only creative marketing (use
  @cf-creative-marketing).
---

# AI Marketing Skills (CF bridge)

**Do not vendor the full Python pack into this repo.** Skills live in personal Cursor:

`~/.cursor/skills/ams-*/SKILL.md`  
Router: `~/.cursor/skills/ai-marketing-skills/SKILL.md`  
Vendor: `~/.cursor/skills/_vendor/ai-marketing-skills/`

## Agent workflow

1. **Read** the personal router: `~/.cursor/skills/ai-marketing-skills/SKILL.md`
2. Follow its pack map → **Read** the matching `ams-*` skill
3. Run scripts from that `ams-*` folder
4. For CF production content (calendars, Firecrawl cites, Postiz, video loop) also load CF skills below

## Disambiguation

| Ask | Load |
|-----|------|
| CF marketing rules / research / cite / calendar | `@cf-creative-marketing` (+ brand `accounts-*`) |
| Open-source Single Grain / ams pack | **this bridge** → personal `ai-marketing-skills` router |
| CF video generate | `@video-skills` |
| CF growth week HTML | `@cf-growth-calendar` |

## Install / update (personal machine)

```powershell
# First install (if missing)
git clone --depth 1 https://github.com/ericosiu/ai-marketing-skills.git `
  $env:USERPROFILE\.cursor\skills\_vendor\ai-marketing-skills
python $env:USERPROFILE\.cursor\skills\_vendor\install_ams_skills.py

# Update later
cd $env:USERPROFILE\.cursor\skills\_vendor\ai-marketing-skills
git pull
python ..\install_ams_skills.py
```

## Related

- Personal router: `~/.cursor/skills/ai-marketing-skills/SKILL.md`
- CF creative marketing: `.cursor/skills/cf-creative-marketing/SKILL.md`
- CF skill router pack table: `.cursor/skills/cf-skill-router/SKILL.md`
