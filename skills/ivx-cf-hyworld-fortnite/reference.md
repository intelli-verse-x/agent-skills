# HY-World Fortnite Map — Research + Aether Ring Reference

Sources (Firecrawl, 2026-07-15):

- Epic: [Level Design Best Practices in Fortnite Creative](https://dev.epicgames.com/documentation/fortnite/level-design-best-practices-in-fortnite-creative)
- Hotspawn: [Top Creative maps / genres](https://www.hotspawn.com/fortnite/guide/best-fortnite-creative-maps)

## Hot topic formats (flavor hooks)

| Hook | Why it trends | How Aether Ring uses it |
|------|----------------|-------------------------|
| Prop Hunt | High session stickiness | Optional side wing / mutator props in Souk |
| Pillars | Fast weapon-round loops | Storm Spire ring platforms as vertical pillars |
| Tycoon / XP | Grind retention | Not core — avoid XP-farm as primary |
| Steal-chaos (Brainrot-style) | Platform-scale chaos | Loot-steal objective at Echo Yard |
| Murder Mystery | Social lobbies | Night mutator on Marina |
| Red vs Blue | Aim practice TDM | Color-coded lane mutator across Rift Rail |
| The Pit | Raw gunfight warmup | **Pit Annex** POI |
| Only Up | Vertical novelty climbs | **Storm Spire** centerpiece |

## Epic principles checklist

- [x] Flow / readable routes  
- [x] Circular layout for POI contest  
- [x] Two fight axes per open area  
- [x] No dead-end POIs (≥2 connections)  
- [x] 3–5 threat spots outdoors  
- [x] Broken long sightlines  
- [x] Callout-friendly landmark names  
- [x] Advanced movement (mantle/slide) on Spire  

## Flagship map: Aether Ring

**Pitch:** Drop into a neon storm archipelago. Rotate the ring, contest named POIs, or climb Storm Spire for endgame high ground.

**Layout:** Circular BR-lite + domination.

**Centerpiece:** Storm Spire (Only Up climb + final high ground)

**POIs:**

1. Mirage Marina — loot / pier cover  
2. Sandglass Souk — mid fight / rooftops  
3. Echo Yard — objective / container lanes  
4. Cinder Courts — open mid + bleachers  
5. Glimmer Grove — rotate / bioluminescent forest  
6. Rift Rail — elevated rotate connector  
7. Pit Annex — sunk fight pit  

**Default WorldPlay trajectories per POI:** `establishing_push_in`, `flythrough`, `look_around`  
**Centerpiece:** `establishing_push_in`, `orbit_left`, `walkthrough`

## RunPod volume

- `hyworld-weights` / `8b6vk25c4i` / `US-NC-1` / `$28/mo` / 400 GB  
- S3: `https://s3api-us-nc-1.runpod.io` → `s3://8b6vk25c4i/`  
