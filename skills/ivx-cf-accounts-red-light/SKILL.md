---
name: ivx-cf-accounts-red-light
description: Content Factory account guide for Redlight Space Crew (social deception survival game). Use when the user mentions Red Light, red-light, Redlight Space Crew, space crew game, deceive survive win, or content for the Red Light Instagram account.
when_to_use: Any content-factory work for Redlight Space Crew — Instagram posts, stories, reels covers, game promos, mission hype, or player acquisition. Load before ideate/rewrite/generate steps.
---

# Redlight Space Crew — Content Factory Account

**Brand slug:** `red-light`  
**Game title:** REDLIGHT SPACE CREW  
**Tagline:** DECEIVE • SURVIVE • WIN  
**Subtitle:** A space crew game of lies, missions & survival  
**Powered by:** IntelliVerse X

## Account type

Mobile social-deception game (Among Us–style space crew). Player acquisition and community hype via Instagram-first content.

## Key config paths

- `services/memory/brands/red-light/manifest.yaml` — _create via onboard_
- `configs/companies/red-light.json` — _create when store URLs confirmed_

---

## Brand identity

### Color palette

| Token | Hex |
|-------|-----|
| Red (primary) | `#FF1E1E` |
| Black | `#0B0B0B` |
| White | `#FFFFFF` |
| Yellow (accent / crew) | `#FFB800` |

Crew suit colors in visuals: **red**, **blue**, **yellow**, **green** astronauts against space/planet/red-nebula backgrounds.

### Typography

| Role | Font |
|------|------|
| Header / Title | Bebas Neue or Ex-O Bold |
| Sub-heading | Raleway or Montserrat Semi-Bold |
| Body / Small | Raleway or Montserrat Regular |

### Icon style

Red line-art icons on dark backgrounds: skull, crosshair, mask, warning triangle, rocket, trophy, megaphone.

---

## Social profile

### Suggested bio lines

- 🎮 Space Crew Game
- 🎯 Missions & Strategy
- 🎭 Deceive, Survive, Win
- 🔔 New Updates Weekly
- **CTA button:** JOIN THE CREW >

### Story highlights

| Highlight | Icon |
|-----------|------|
| How to Play | Skull |
| Missions | Rocket |
| Crew Tips | Mask |
| Winners | Trophy |
| Updates | Megaphone |

### Profile header (cover)

Title + tagline over red/blue/yellow astronauts in space suits, planets, red nebula backdrop.

---

## Post layout rules

| Element | Position |
|---------|----------|
| Logo / Title | Top left or center |
| Main visual | Center focus |
| Key message | Bottom center |
| CTA / Tagline | Bottom |

**Visual style:** Dark, futuristic, high-contrast. Deep red, black, white. Dramatic space lighting.

---

## Content templates (9 post types)

Use one core message per post. Rotate across the feed grid:

| # | Type | Headline pattern | Visual |
|---|------|------------------|--------|
| 1 | New Mission | TRUST NO ONE. A crewmate is lying… STAY ALERT. STAY ALIVE. | Red astronaut, silence gesture |
| 2 | Game Mode | COMPLETE MISSIONS. Complete tasks. Uncover the truth. | Blue astronaut at console |
| 3 | Crew Tip | OBSERVE BEFORE YOU DECIDE. Smart players always watch first. | Red astronaut peeking |
| 4 | Who's the Imposter? | Can you spot the liar? | Crew group, ? on visor |
| 5 | Survival Rule | STAY QUIET. STAY ALIVE. One mistake, and you're out. | Yellow astronaut, silence |
| 6 | Crew Victory | ONLY THE BEST SURVIVE. Are you ready to be the last one? | Golden trophy |
| 7 | Are You Ready? | ENTER THE ARENA. The arena is calling. | Futuristic space station |
| 8 | Upcoming | SOMETHING BIG IS COMING… COMING SOON | Silhouette in red glow |
| 9 | Crew Life | TEAM UP. TRUST LESS. WIN MORE. The crew is waiting. Join now! | Red/blue/green crew group |

### Copy tone

- Short, punchy, ALL CAPS headlines
- Paranoia, strategy, crew dynamics
- Never spoil solutions; tease mystery and social deduction

---

## Preferred pipelines

| Format | Pipeline |
|--------|----------|
| Instagram static / carousel | `ad_banners`, `ad` |
| Reels / Shorts | `viral_shorts`, `short_video` |
| Game trailer | `app_preview_video`, `short_movie` |
| Install ads | `ad`, `app_ad_campaigns` |
| Event / update hype | `event_promo` |

## DO

- Use red/black/white palette consistently
- Feature astronaut crew in red, blue, yellow suits
- Headlines in Bebas Neue / Ex-O Bold, ALL CAPS
- End with JOIN THE CREW or equivalent install CTA
- Tie posts to missions, imposter suspicion, survival rules

## DON'T

- Use bright playful pastels — brand is dark and intense
- Reveal imposter mechanics in a way that ruins the game loop
- Copy Among Us branding or assets — use Redlight Space Crew identity only
- Long body copy — one punchy message per frame

## Workflow

```bash
# 1. Onboard (first time)
/brand onboard --slug red-light --name "Redlight Space Crew" --app-kind game

# 2. Load context
/whatdoweknow --subject brand --id red-light

# 3. Ideate mission/survival angles
/ideate --brand red-light --kind viral_shorts --n 8

# 4. Generate Instagram post
trigger_pipeline(
  pipeline_type="ad_banners",
  topic="Who's the Imposter? Can you spot the liar?",
  style="Redlight Space Crew: #FF1E1E red on #0B0B0B black, astronauts, Bebas Neue headline",
  extra_params={"brand": "red-light", "template": "whos_the_imposter", "canvas": "1080x1350"}
)
```

## Onboarding note

Run `/brand onboard` and add store URLs + Postiz channel IDs when available. Ingest brand guide image via `--documents` if saved to disk.
