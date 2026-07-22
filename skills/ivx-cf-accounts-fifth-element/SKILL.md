---
name: ivx-cf-accounts-fifth-element
description: Content Factory account guide for Fifth Element (premium Indian nightlife & party events brand). Use when the user mentions Fifth Element, fifth-element, fifth element party, 5th element nightclub, FE event, 5-spike logo, Mumbai party, Delhi nightlife, 19 July, or content for the Fifth Element social/ad accounts.
when_to_use: Any content-factory work scoped to the Fifth Element account — event promos, party reels, teasers, Instagram posts, cinematic ads, or campaign assets. Load before ideate/rewrite/generate steps.
---

# Fifth Element — Content Factory Account

**Brand slug:** `fifth-element`  
**Brand ID:** `fifth-element`  
**Type:** Premium nightlife & events — India  
**Tagline:** The night you'll regret missing  
**Powered by:** IntelliVerse X Content Factory

## Account type

Live events / nightlife brand. Not a product or app. Content goal is hype, FOMO generation, and audience acquisition for events — primarily Instagram Reels and Stories.

## Key config paths

- `configs/companies/fifth-element.json` — full brand entity (colors, identity, recurring leads, pipeline defaults)
- `.assets/fifth_element/` — logo, keyframes, existing reels, previews
- `.assets/fifth_element/brand_logo_official.png` — **canonical logo** (5-spike white on black)
- `.assets/fifth_element/brand_logo.png` — alternate logo
- `channels.json` → `fifth_element` — channel config with pipeline defaults

---

## Brand logo (canonical)

**File:** `.assets/fifth_element/brand_logo_official.png`

The logo is the primary brand asset for all content. Always embed it on end cards and wherever the brand name appears.

**Visual description of logo:**
- Pure black background (`#000000`)
- 5 vertical spike/pillar shapes in bright white-blue luminescence, narrowing to sharp points, rising from a shared horizontal glowing baseline
- Spikes have a "crown" / equalizer silhouette — tallest in center, flanked by shorter pairs
- Each spike has a soft blue-white glow/halation (`#B8D4FF` → pure white)
- `F I F T H   E L E M E N T` in wide-tracked white minimal sans-serif below the spikes
- Entire image is a study in restraint: pure black, pure light — nothing else

**Color extract from logo:**
| Token | Hex |
|-------|-----|
| Background | `#000000` |
| Spike white core | `#FFFFFF` |
| Spike glow halo | `#B8D4FF` |
| Base line glow | `#7AB8FF` |

Use these as the canonical black-and-white-with-blue-glow palette whenever generating logo-adjacent content.

---

## Brand identity

### Full color palette (content)

| Token | Hex | Use |
|-------|-----|-----|
| True black | `#000000` | Primary canvas |
| Deep purple | `#2D0050` | Dark backgrounds |
| Electric teal | `#00C9C8` | Neon accent |
| Neon magenta | `#FF2D8A` | Energy accent |
| Warm amber | `#D4750A` | Bar/club warmth |
| Gold accent | `#C9A84C` | Jewelry, luxury |
| Pure white | `#FFFFFF` | Logo text, titles |

### Typography feel

Minimal luxury — clean tracked sans-serif, high contrast on black. The logo sets the standard: spaced capitals, no weight, no decoration.

### Visual style

- **Aesthetic:** Cinematic 35mm nightlife — moody neon palette, shallow depth of field, 35mm grain, halation around practicals, anamorphic-style flares
- **Texture:** Humidity sheen on skin, natural imperfections, asymmetric smiles, candid reactions — NOT plastic-smooth AI skin
- **Camera:** Handheld energy for hype reels, controlled still frames for teasers
- **Lighting:** Hard neon (magenta + teal) on faces, warm amber bar glow, strobe accents
- **NOT:** Generic western club aesthetic, Bollywood costume, stereotypical Indian party visuals

### Brand motif

The **5-spike glowing emblem** from the logo appears hidden across all content — in jewelry, lighting rigs, neon reflections, cocktail glass shapes, and architectural elements. Plant it at least once per reel as an Easter egg.

### Sound identity

Premium electronic/deep-house energy: warm sub-bass, club kick, tension builds and decisive drops. For the current Udaipur reel, use the supplied licensed local file `C:\Users\msi\Downloads\Yeah Yeah Yeahs - Heads Will Roll (A-Trak Remix).mp3`.

### Cultural markers (must appear)

- Oxidised-gold ear stacks, kajal-lined eyes
- Contemporary Indian street-luxury silhouettes (NOT sari dance, NOT Bollywood)
- No spoken dialogue or Hinglish overlays in the current Udaipur campaign
- Mumbai rooftop city skyline hints
- Chili-salt cocktail rims
- Signet rings + statement watches
- Candid laughter, sweat texture, real crowd compression

---

## Recurring leads (hero pair)

All campaign content features the same two protagonists for visual continuity:

| ID | Role | Description |
|----|------|-------------|
| `SHE` | Female lead | Urban Indian woman, mid-20s. Metallic sari-inspired streetwear or luxury coordinate. Oxidised-gold ear stack, kajal eyes. Magnetic, confident, owns the room. |
| `HE` | Male lead | Urban Indian man, late-20s. Structured shirt / dark luxury streetwear. Signet ring + statement watch. Composed, intentional, quietly charismatic. |

**Lock rule:** Both leads must wear consistent wardrobe, jewelry, and hairstyle across all reels in the same campaign. Face and styling references must be locked before generation.

---

## Campaign architecture

### Two-reel pattern

| Reel | Role | Energy | Opens with |
|------|------|--------|------------|
| Reel 1 (Hype) | You had to be there — peak energy | Hard cuts, crowd surge, fashion + DJ payoff | SHE locking eyes with camera as bass hits |
| Reel 2 (Teaser) | Seductive anticipation — quiet before drop | Slow builds, prep rituals, controlled reveals | HE adjusting watch / SHE applying kajal |

**Loop mechanic:** Reel 2 ends exactly on the first bass hit / eye-contact shot that Reel 1 begins with. Both reels form one continuous night.

### End card (all content)

- Black frame
- 5-spike logo centered (from `.assets/fifth_element/brand_logo_official.png`)
- Event date below: `19 JULY` (or current event date)
- Optional CTA: `Save the date. Send it to your crew.`

---

## Content DO / DON'T

**DO:**
- Open every reel with a human-led hook in the first 0–1.2 seconds (face, micro-expression, locked eye contact)
- Use the 5-spike emblem as a hidden Easter egg in at least one shot per reel
- Specify city in first 2 seconds (Mumbai skyline, Delhi winter fog, Bangalore terrace) — triggers location debate in comments
- Keep all cards text-free except the opening phone notification, which shows the official logo and `GET READY`
- Close with a black end card containing only the official logo

**DON'T:**
- Use generic wide crowd shots unanchored by cultural markers
- Smooth AI skin — request realistic skin texture, humidity sheen, natural pores
- Bollywood costume or stereotypical Indian party visuals
- Bright playful colours — brand is dark, neon, cinematic
- Arrive at brand name late — introduce 5-spike motif early in the reel

---

## Preferred pipelines

| Format | Pipeline | Notes |
|--------|----------|-------|
| Event hype reel | `viral_shorts` | `use_wan22: true`, quality `high` |
| Party teaser | `viral_shorts` | Slower edit pace, mood-first |
| Event poster / static | `ad_banners` | Black canvas, logo + date + glow |
| Event promo (longer) | `event_promo` | Full narrative arc, 30–60s |
| Music-driven reel | `beat_synced` | Sync to Indian-fusion deep house |

### Trigger template

```python
trigger_pipeline(
  pipeline_type="viral_shorts",
  topic="Fifth Element — 19 July — Mumbai, the night begins. SHE arrives at the rooftop entrance, HE adjusts his watch in a neon-lit auto mirror. The 5-spike emblem glints in her earring.",
  style="Fifth Element: #000000 black canvas, electric teal + neon magenta neon, cinematic 35mm grain, Indian nightlife, Hinglish energy",
  quality="high",
  platform="reels",
  audience="urban Indian millennials and Gen Z aged 21-35",
  extra_params={
    "brand": "fifth-element",
    "use_wan22": True,
    "gpu_routing": "forced_selfhosted",
    "aspect_ratio": "9:16",
    "logo_path": ".assets/fifth_element/brand_logo_official.png",
    "visual_motif": "5-spike glowing emblem as hidden recurring element",
    "negative_prompt": "blurry, distorted, low quality, watermark, text, subtitles, traditional bollywood costume, sari dance number, stereotypical, deformed faces, extra fingers, cartoon, illustration, generic western clubbing, plastic skin, overly smooth AI face"
  },
  user_approved=True
)
```

---

## Workflow

```bash
# 1. Load brand memory
/whatdoweknow --subject brand --id fifth-element

# 2. Ideate event content angles
/ideate --brand fifth-element --kind viral_shorts --n 6

# 3. Warm GPU before generation
warm_video_stack()   # warms wan22 + comfyui

# 4. Plan and get approval
plan_generation(
  pipeline_type="viral_shorts",
  topic="Fifth Element — [event name/date] — party hype reel",
  brand_id="fifth-element"
)
# → reply APPROVE

# 5. Generate
trigger_pipeline(... user_approved=True)

# 6. Review output
get_task_status(task_id)
list_output_files(task_id)

# 7. Save lessons
/save --brand fifth-element --kind directive --text "<lesson>" --scope channel
```

---

## Udaipur event (active)

Fifth Element's active event is in **Udaipur, Rajasthan** — NOT Mumbai/Delhi/Bangalore (that was an earlier archived campaign concept). Date is TBA — use "coming soon" CTAs, never invent a date.

### Udaipur-specific visual identity

Udaipur's differentiator vs. generic metro club content: heritage-meets-neon. Always weave in:
- Lake Pichola reflections in blurred bokeh backdrops
- City Palace domes/turrets glimpsed through neon haze
- Jharokha (carved stone window) silhouettes with modern uplighting
- Haveli rooftop converted into a lounge — marble courtyard + neon bar
- Warm Rajasthani sandstone tones fused with cold club neon

Never touristy/postcard — this is heritage architecture reframed as a premium nightlife backdrop.

**Local competitive set:** Club Elrow Udaipur, Club Roadies Udaipur, The Clubhouse Udaipur. Use their pacing and visual energy as competitive references, but do not use Hinglish dialogue or on-video copy for the current campaign.

### Trending audio — "Heads Will Roll (A-Trak Remix)"

Yeah Yeah Yeahs' "Heads Will Roll (A-Trak Remix)" is an actively trending Instagram/TikTok audio (`#headswillroll`) with a classic tension→drop structure — intro chime, vocal build, the "off with your head, heads will roll" hook, then a big electro-house drop. This maps perfectly onto a "getting ready → arriving at the party" reel arc.

**Song structure (for cut timing):**
| Time | Beat |
|------|------|
| 0:00–0:03 | Intro chime — tension opens |
| 0:03–0:15 | Vocal build / pre-chorus — prep montage escalates |
| 0:15–0:17 | "Heads will roll" hook — threshold/exit moment |
| 0:17+ | **DROP** — high-energy cuts (headlights, car exit, city bokeh) |

**Audio licensing:** Do not download or rip copyrighted music. If the user provides an authorized local audio file, it may be embedded into the requested export. The current approved source is `C:\Users\msi\Downloads\Yeah Yeah Yeahs - Heads Will Roll (A-Trak Remix).mp3`. Otherwise, export beat-mapped video and attach the official track through Instagram's native audio picker. Never use it for paid/boosted ads without the appropriate synchronization license.

### Reel generation scripts

- `scripts/fifth_element_udaipur_best_reel.py` — **primary/current.** Generates corrected shots via **KIE.ai's Veo3** endpoint (`api.kie.ai`, key: `KIEAI_API_KEY`) and assembles a 9:16 1080x1920 Instagram reel. The opening phone shot is deterministic (official logo + `GET READY`), perfume visibly shows one person applying it, the watch uses one visible wrist with no extra hand, all car shots prohibit badges/logos and continuous motion is forward-only, and the end card is logo-only. The supplied authorized MP3 is mixed from its measured 58-second build section so the energy lift lands around reel 15 seconds.
- `scripts/fifth_element_udaipur_headswillroll_reel.py` — original PiAPI/Veo3.1 version. **Known issue:** PiAPI's Veo3.1 backend returned persistent `500 internal server error` across all shots during a live run (2026-07-10) — confirmed provider-side outage, not a prompt/param/credits issue (verified via direct account-info check). Has auto-retry-with-backoff built in, but if PiAPI is down, use the KIE.ai script above instead.
- `scripts/fifth_element_veo31_reel.py` — earliest generic (non-Udaipur) version, PiAPI/Veo3.1.

**Provider fallback order for this brand's video generation:** KIE.ai Veo3 (`api.kie.ai`, `KIEAI_API_KEY`) → PiAPI Veo3.1 (`api.piapi.ai`, `PIAPI_API_KEY`) → self-hosted Wan2.2 (`warm_video_stack()` MCP tool). KIE.ai has no duration parameter (fixed 8s clips, trim in post with ffmpeg `-t`) and returns clips with baked-in AI audio (strip with `-an` — we never ship AI-generated or copyrighted audio baked into the export; see audio rule above).

## Onboarding note

Brand manifest at `configs/companies/fifth-element.json`. Channel config at `channels.json → fifth_element`. Social Postiz IDs are null — fill in when Instagram/TikTok accounts are connected. Logo canonical path: `.assets/fifth_element/brand_logo_official.png`.
