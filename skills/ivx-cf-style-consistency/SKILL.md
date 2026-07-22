---
name: ivx-cf-style-consistency
description: Maintain visual and audio style consistency across AI-generated content. Use when ensuring brand consistency, character identity preservation, or cross-scene coherence.
---
# Style Consistency Skill

## Purpose

Ensure generated content maintains consistent style, characters, and quality across scenes and episodes.

## Consistency Dimensions

### Visual
- Character appearance (face, clothing, proportions)
- Color palette and grading
- Lighting style (soft, dramatic, natural)
- Composition rules (framing, depth)
- Visual effects style (bloom, grain, lens)

### Audio
- Voice identity (pitch, timbre, accent)
- Speaking style (pace, emotion, energy)
- Music genre and mood
- Sound design vocabulary

### Narrative
- Character personality consistency
- Story tone and pacing
- World-building rules
- Canon compliance

## Techniques

### Character Identity
```python
from utils.pipeline.character_identity import inject_character_context

prompt = inject_character_context(
    base_prompt="Generate scene with...",
    brand_id=brand_id,
    character_id=character_id,
)
```

### Visual Anchoring
- Generate reference images first (Midjourney/FLUX)
- Use IP-Adapter or reference-only in generation
- Seed management: fixed seeds for character shots
- Style LoRA for consistent aesthetic

### Voice Consistency
```python
from utils.pipeline.voice_consistency import assign_voice

voice_id = assign_voice(
    character_id=character_id,
    brand_id=brand_id,
    emotion="neutral",
)
```

### Brand Memory
```python
from utils.pipeline.brand_memory import get_brand_assets

assets = get_brand_assets(brand_id)
# Returns: color palette, logo, fonts, style guide
```

## Verification

- [ ] Character matches reference images
- [ ] Colors match brand palette
- [ ] Voice matches previous episodes
- [ ] Tone matches series style
- [ ] No visual/audio artifacts

## Character design sheet (optional deliverable)

Use a design sheet as a consistency anchor when identity must hold across many shots:

- **Reference sheet** / **turnaround** / **expression sheet** / **color palette** — lock look before batch generation
- Prefer existing CF anchors first: `inject_character_context`, brand assets (`brand_memory`), `visual_memory`, fixed seeds, IP-Adapter / ref-only
- Do **not** require FLUX LoRA training by default; treat LoRA as an advanced optional when identity drifts across many shots
- Operator cast tools: `/character` (list / add / recast / audit); brand guides: `accounts-*` skills

## CF Systems

- `utils.pipeline.character_identity`: Canonical character bank
- `utils.pipeline.voice_consistency`: Voice assignment and routing
- `utils.pipeline.voice_memory`: Cross-episode voice persistence
- `utils.pipeline.brand_memory`: Brand asset registry
- `utils.pipeline.visual_memory`: Visual reference store
