---
name: ivx-cf-accounts-toba-tech
description: Content Factory account guide for ToBa Tech (B2B AI automation studio). Use when the user mentions ToBa, toba-tech, toba-tech.ai, B2B automation content, lead-gen ads, Instagram posts for ToBa-Tech, or content for the ToBa Tech social/ad accounts.
when_to_use: Any content-factory work scoped to the ToBa Tech account — ads, shorts, blog, Instagram carousels, landing copy, or campaign assets. Load before ideate/rewrite/generate steps.
---

# ToBa Tech — Content Factory Account

**Brand slug:** `toba-tech`  
**Company:** ToBa Tech Solutions LLP  
**Site:** https://www.toba-tech.ai  
**Instagram tagline:** Engineering Tomorrow. Automating Today.  
**Website (footer):** www.toba-tech.com

## Account type

B2B services — lead generation, not app installs. Primary conversion is a booked audit or discovery call.

## Key config paths

- `configs/companies/toba-tech.json` — legacy brand colors, contact
- `.working_dir/marketing/toba-tech/ad_campaign_keywords.json` — keyword clusters, landing URLs
- `.working_dir/marketing/toba-tech/ad_campaign_plan.md` — campaign structure and copy angles

## Voice and positioning

- **Tagline (web):** Growth infrastructure studio designing AI-powered systems
- **Tagline (social):** Engineering Tomorrow. Automating Today.
- **Hero promise:** Save hours every week with AI automation built for your business
- **Method (long-form):** Think, Optimize, Build, Accelerate (TOBA)
- **Personality:** Modern, Innovative, Trustworthy, Friendly, Professional
- **Core values:** Modern Design, Premium Quality, Consistent Branding, Easy to Scale
- **Tone:** Confident, practical, outcome-focused — premium futuristic, not hype

## CTAs and landing pages

| Goal | URL |
|------|-----|
| Primary | https://www.toba-tech.ai/book-call |
| Free audit | https://www.toba-tech.ai/free-automation-audit |
| Pricing | https://www.toba-tech.ai/pricing |
| Services | https://www.toba-tech.ai/services |
| Social CTA | LET'S TALK / Book a free automation audit |

## Audience segments

1. **Small business ops** (35%) — admin automation, Google Search + Meta
2. **Law firms** (25%) — intake, docs, follow-ups — Google + LinkedIn
3. **Schools** (20%) — admin & communications — Google + Meta
4. **Founders/startups** (20%) — product + ops automation — Google + LinkedIn

---

## Instagram Design System

### Color palette

| Token | Hex | Use |
|-------|-----|-----|
| Background / Dark Navy | `#090B16` | Primary canvas |
| Secondary Dark | `#161B2D` | Cards, surfaces |
| Accent Purple | `#7B3FF2` | Badges, highlights |
| Accent Blue | `#5B8CFF` | Primary buttons, icons, glow |
| Accent Pink | `#FF5FD2` | Announcement badges |
| White | `#FFFFFF` | Headlines, button text |
| Light Grey-Blue | `#B7BEDB` | Body, secondary text |

Use max **3 accent colors** per post. Legacy web palette (`#11252b`, `#1f7a82`, `#b08d57`) applies to website/ads only — Instagram uses the palette above.

### Typography

| Role | Font | Size |
|------|------|------|
| Headline | Sora ExtraBold | 70px / 80px line height |
| Sub heading | Sora Medium | 32px |
| Category label | Inter Medium | 24px, UPPERCASE |
| Body | Inter Regular | 28px / 38px line height |
| Button | Inter SemiBold | 26px |

### Canvas and grid

- **Size:** 1080 × 1350px (Instagram portrait)
- **Margins:** Top safe 80px, bottom safe 90px, left/right 70px, content width 940px
- **Grid:** 8px base unit
- **Vertical sections:** Header 100px → Main visual 700px → Content 380px → Footer 80px
- **Spacing:** Title→subtitle 24px, subtitle→visual 40px, visual→content 48px, content→footer 60px, card gap 24px

### Header and footer

- **Header (100px):** CATEGORY label top-left; ToBa-Tech logo top-right (max width 150px)
- **Footer (80px, fixed):** Website URL left; social icons center (Instagram, LinkedIn, Twitter/X, YouTube); logo right

### Mascot

- **Character:** Friendly 3D blue robot, large yellow eyes, ToBa logo on chest
- **Position:** Bottom-right corner, ~25% of total height
- **Direction:** Facing toward headline; eyes toward content
- **Rule:** Never block text

### UI components

- **Cards:** Dark background, subtle blue outer glow
- **Primary button:** Solid blue pill, white text
- **Secondary button:** Outlined pill, white text
- **Icons:** Thin-line, glowing blue (robot head, lightning, shield, bar chart)
- **Badges:** NEW UPDATE (blue), FEATURE (purple), TIPS (grey), ANNOUNCEMENT (pink)

### Post templates

| Template | Layout | Example headline |
|----------|--------|------------------|
| Guide | List-based | Automation Facts |
| Feature | Bulleted list | Smart Systems |
| Tips | Large centered headline | How to Build… |
| New Update | Launch headline + CTA | WE'VE LAUNCHED → EXPLORE NOW |
| Stats | Large percentage | 70% |
| Quote | Large blue quotation marks, centered | — |
| CTA | Question + button + mascot | READY TO BUILD YOUR NEXT SYSTEM? → LET'S TALK |

### Visual style

High-quality 3D renders of futuristic technology, glowing interfaces, deep blue/purple lighting. Premium, not stock.

### Design rules

**DO:** Use brand colors consistently; keep text clear; follow grid; mascot bottom-right; premium look.

**DON'T:** Overcrowd; use more than 3 accent colors; move logo position; crop mascot; use low-quality visuals.

**Principles:** Consistency is key; clarity over creativity; follow grid always; keep it premium; less is more.

---

## Preferred pipelines

| Format | Pipeline |
|--------|----------|
| Instagram posts / carousels | `ad_banners`, `ad` |
| Google/Meta/LinkedIn ads | `ad`, `ad_banners`, `app_ad_campaigns` |
| Short-form thought leadership | `viral_shorts`, `short_video` |
| Blog / SEO | `blog`, `landing_page` |

## Content DO / DON'T (copy)

**DO:** Lead with time saved; name vertical (law firm, school, SMB); use "flat monthly retainer" and "you own everything we build"; CTA to book-call or free-automation-audit.

**DON'T:** Promise ROI without case study; use negative keywords (free, jobs, salary, course, tutorial, diy, chatgpt, internship); position as generic chatbot vendor; mix app-install UA language.

## Workflow

```bash
# 1. Check what memory has (onboard first if empty)
/whatdoweknow --subject brand --id toba-tech

# 2. Ideate campaign or content angles
/ideate --brand toba-tech --kind ad --n 5

# 3. Generate Instagram post or ad (pass design system in style/extra_params)
trigger_pipeline(
  pipeline_type="ad_banners",
  topic="Automation Facts — 3 ways AI cuts admin busywork",
  style="ToBa-Tech Instagram: dark navy #090B16, blue glow, Sora headline, robot mascot bottom-right",
  extra_params={"brand": "toba-tech", "canvas": "1080x1350", "template": "guide"}
)

# 4. Save lessons learned
/save --brand toba-tech --kind directive --text "<lesson>" --scope channel
```

## Onboarding note

Brand manifest not yet in `services/memory/brands/`. Run `/brand onboard` when ready to wire memory, channels, and CLAUDE.md.
