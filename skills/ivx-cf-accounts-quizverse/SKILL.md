---
name: ivx-cf-accounts-quizverse
description: Content Factory account guide for QuizVerse (AI study + trivia app). Use when the user mentions QuizVerse, quizverse, quizverse.world, @quizverse Instagram, Play Learn Level Up, Quizverse Bot mascot, player UA, study OS, or trivia shorts.
when_to_use: Any content-factory work for QuizVerse — Instagram posts, carousels, reels, viral shorts, app ads, app previews, or study content. Load before ideate/rewrite/generate steps.
---

# QuizVerse — Content Factory Account

**Brand slug:** `quizverse`  
**Taglines:** Outsmart the AI — daily quizzes, learn faster, earn more | Play. Learn. Level Up.  
**Site:** https://quizverse.world | https://quizverse.app  
**Install:** https://dl.intelli-verse-x.ai/quizverse  
**Handle:** @quizverse

## Account type

Mobile education game — player acquisition (UA) and engagement. Portfolio: IntelliVerse.

## Key config paths

- `services/memory/brands/quizverse/manifest.yaml` — full brand manifest
- `services/memory/brands/quizverse/CLAUDE.md` — rendered agent context
- `configs/apps/quizverse.yaml` — store IDs, locales, pricing
- `services/smartlink/tenants.json` — smartlink tenant `quizverse`

## Voice and positioning

- **Archetype:** Educator — witty, encouraging, competitive
- **Personality:** Premium, Playful, Smart, Addictive | Smart, Playful, Futuristic, Motivational
- **Primary emotion:** Curiosity
- **Hook pattern:** Open every Short with a question the viewer must guess
- **Relatability:** Show the AI losing at least once per video

## Owned channels

| Channel ID | Platform | Handle | Postiz ID |
|------------|----------|--------|-----------|
| `quizverse-ivx` | YouTube | @QuizVerseIVX | `cmlgmcwpt0005nvl6o2wr8tg4` |
| `quizverse-ig-main` | Instagram | @quizverse | — |
| `quizverse-tt-main` | TikTok | @quizverse | — |
| `quizverse-yt-main` | YouTube | @quizverse | PENDING |

## Economics targets

CPI ~$1.20 | D1 42% | D7 18% | D30 8% | ARPDAU $0.15 | 30d LTV $4.50

---

## Mascot: Quizverse Bot

- **Appearance:** Glossy black spherical robot, large glowing blue eyes, blue "X" on chest, blue antenna with glowing tip
- **Primary position:** Bottom-right, 25–35% of frame height
- **Rule:** Always look toward content; never cover text or CTA
- **Approved poses:** Teacher (bottom-right), Thinking (bottom-left), Celebration (bottom-center + confetti), Peeking (right edge)
- **Floating elements (max 4/post):** 3D gold coins, XP cards (+150 XP), gold stars, streak flame icons

---

## Instagram Design System — Primary (Dark / Neon)

_Use for feed posts, carousels, reels covers. "Discord Neon + Apple Clean UI" style._

### Color palette

| Token | Hex | Share |
|-------|-----|-------|
| Dark primary | `#090611`, `#1A1038` | 70% |
| Purple secondary | `#5A189A`, `#8E44FF` | 20% |
| Accent blue | `#5CC8FF` | 10% |
| Accent green | `#5BFFB4` | accents |
| Accent yellow | `#FFD84D` | coins, XP |
| White | `#FFFFFF` | text |

### Typography

| Role | Font | Size |
|------|------|------|
| Heading | Sora ExtraBold | 110–140px, max 2 lines |
| Subheading | Sora SemiBold | 42–52px |
| Body | Inter Medium | 28–34px, 140% line height |
| Small label | Inter SemiBold | 24px, UPPERCASE, 8% letter-spacing |
| CTA | Sora Bold | 44px |

### Canvas and grid

- **Feed / Carousel:** 1080 × 1350px (4:5)
- **Story:** 1080 × 1920px
- **Grid:** 12 columns
- **Margins:** 70px L/R, 80px top, 90px bottom
- **Vertical split:** Top 20% header/headline → Middle 60% visual → Bottom 20% CTA/footer
- **Spacing:** Headline→header 40px, headline→illustration 50px, content→CTA 60px, CTA→footer 80px

### Header and footer

- **Header (140px):** QV logo left (120–140px wide); series badge right (QUIZ TIP, LEVEL UP, etc.)
- **Footer (120px):** @quizverse left | divider | logo right. Alternate: @quizverse + social icons (IG, YouTube, Twitter) + mascot/logo

### UI components

- **Cards:** 30px radius, glassmorphism, 10–15% blur, soft shadow, 1px light stroke at 15% opacity
- **Primary button:** Purple gradient (`#8E44FF` → `#B56BFF`), 18px radius, 20px padding, 10% glow. Text: PLAY NOW
- **Secondary button:** White bg, thin gray border, black text
- **Badges:** QUIZ TIP (purple), LEVEL UP (blue), FACT (green), CHALLENGE (yellow), BRAIN BOOST (pink), QUIZ TIME, FUN FACT

### Content hierarchy

1. Headline → 2. Visual → 3. Supporting text → 4. CTA → 5. Footer

**Content ratio:** 40% visual, 30% headline, 20% supporting, 10% CTA

### Carousel structure (6 slides)

1. **Hook:** Large headline + big visual + mascot — "Can You Beat This Quiz?" / "DAILY QUIZ, SHARPER YOU!"
2. **Problem:** One illustration, two bullet points
3. **Explanation:** Phone mockup + UI card — "Train Your Brain Daily" / "Learn Faster"
4. **Tips:** Three cards, minimal text
5. **Question:** Sample quiz — "What is the capital of Japan?"
6. **CTA:** "Correct! Great Job" or "Follow For More Quizzes!" + PLAY NOW

### Post templates

| Template | Headline | CTA |
|----------|----------|-----|
| Daily Quiz | DAILY QUIZ, SHARPER YOU! | PLAY NOW |
| Did You Know? | Single fact + lightbulb icon | — |
| Complete/Learn/Earn | Motivational | PLAY NOW |
| New Levels | Update headline | UPDATE NOW |
| Reels cover | TIME TO LEVEL UP YOUR BRAIN! | — |
| Static | Sharpen Your Mind Everyday | Play Now |

---

## Instagram Design System — Light variant

_Use for bright, off-white feed posts._

### Color palette

| Token | Hex |
|-------|-----|
| Primary purple | `#8E44FF` |
| Light purple | `#B56BFF` |
| Sky blue | `#4CC9FF` |
| Green | `#6EEB8A` |
| Golden yellow | `#FFD84D` |
| Off-white bg | `#F7F9FC` |
| Dark text | `#2D2D2D` |

### Typography

Sora ExtraBold 80px headlines | Sora SemiBold 40px subheads | Inter Medium 24px body | Sora Bold 32px CTA

### Layout

1080×1350 | Margins: 80 top, 90 bottom, 70 L/R | Header 140px | Main visual 900px | Footer 120px

---

## Instagram Design System — 2026 Playful variant

_Use for purple-gradient playful posts with 3D elements._

### Color palette

| Token | Hex |
|-------|-----|
| Light purple | `#E8D8FF` |
| Mid purple | `#C9A6FF`, `#B85CF6` |
| Deep purple | `#6D28D9` |
| Pink accent | `#F9A8D4` |
| Cyan | `#3FC7FF` |
| Yellow | `#FFC84A` |
| Off-white | `#F6F2FF` |
| Dark purple text | `#35205F` |

### Typography

Fredoka Bold 100px headlines | Poppins SemiBold 52px subheads | Poppins Medium 36px body | Poppins Bold 44px CTA

### Layout

Outer margin 80px | Content width 920px | Safe zone 60px | Gap 32px  
Order: Header → Big Headline → Illustration (55–60% height) → Supporting text → CTA → Mascot → Footer

### Header badge

"QUIZ TIME" badge in header alongside QV logo. Footer: @quizverse + slide numbers (01/06).

---

## Preferred pipelines

| Format | Pipeline |
|--------|----------|
| Instagram posts / carousels | `ad_banners`, `ad` |
| TikTok/Reels/Shorts | `viral_shorts`, `quiz_shorts`, `daily_quiz_factory` |
| App install ads | `ad`, `app_ad_campaigns`, `hyperframes_app_preview` |
| Study content | `learning_series`, `exam_prep_bundle` |
| Mascot content | `quizverse_autocurio_3d` |

## Content DO / DON'T

**DO:** Large headlines, few words, strong contrast; mascot bottom-right; PLAY NOW CTA; open with forced-guess question; show AI losing once; daily-streak in screenshots.

**DON'T:** Tiny text; more than 3 fonts; random mascot/logo positions; long paragraphs; stock illustrations; busy backgrounds; imply guaranteed winnings; bare "quiz"/"trivia" keywords; copyrighted IP in prompts.

## Workflow

```bash
# 1. Load brand context
/whatdoweknow --subject brand --id quizverse

# 2. List characters
/character list --brand quizverse

# 3. Ideate
/ideate --brand quizverse --kind ad_banners --channel quizverse-ig-main --n 10

# 4. Generate Instagram carousel slide 1
trigger_pipeline(
  pipeline_type="ad_banners",
  topic="Can You Beat This Quiz?",
  style="QuizVerse dark neon: #090611 bg, #8E44FF purple, Sora headline, Quizverse Bot bottom-right",
  extra_params={"brand": "quizverse", "template": "carousel_hook", "canvas": "1080x1350"}
)

# 5. Performance check
/last30days --brand quizverse --channel quizverse-ig-main
```

## Characters and assets

- S3: `agent-assets/brands/quizverse/Characters/`
- Personas: Mystica, Professor Sage, Rex, AutoCurio
- Brand entity: `agent-assets/brands/quizverse/brand_entity.json`
