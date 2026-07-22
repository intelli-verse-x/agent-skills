---
name: ivx-cf-image-generation
description: Design and execute image generation pipelines using diffusion models. Use when generating images, optimizing image quality, or building image production workflows.
---
# Image Generation Skill

## Purpose

Generate high-quality images through structured, reproducible pipelines.

## Pipeline Stages

1. **Concept**: Purpose, style, composition, subject
2. **Prompt Engineering**: Detailed text prompt + negative prompt
3. **Structure Control**: ControlNet, depth, pose, canny
4. **Generation**: Base model + sampler + steps + CFG
5. **Selection**: Generate multiple, pick best
6. **Post-Processing**: Upscale, inpaint, color correct
7. **Export**: Format, resolution, color space

## Generation Config

| Parameter | Typical Value | Notes |
|-----------|--------------|-------|
| Model | FLUX.1-dev / SDXL | Quality vs speed tradeoff |
| Resolution | 1024x1024 | Native resolution for most models |
| Sampler | DPM++ 2M Karras | Good balance quality/speed |
| Steps | 20-50 | More steps = better quality, slower |
| CFG | 7-12 | Higher = stricter adherence |
| Seed | Random / fixed | Fixed for reproducibility |

## Control Methods

| Method | Use Case | Strength |
|--------|----------|----------|
| ControlNet (canny) | Edge structure | 0.8-1.0 |
| ControlNet (depth) | Spatial depth | 0.8-1.0 |
| ControlNet (pose) | Human pose | 0.8-1.2 |
| IP-Adapter | Style transfer | 0.6-0.8 |
| Reference-only | Character consistency | 0.5-0.7 |

## CF-Specific

```python
# 1. Generate with style consistency
image = await generate_image(
    prompt="A cinematic shot of...",
    negative_prompt="blurry, low quality, watermark",
    width=1024, height=1024,
    seed=42,  # Fixed for reproducibility
    controlnet={"type": "canny", "image": reference, "strength": 0.9},
)

# 2. Upscale
image = await upscale(image, scale=4, model="Real-ESRGAN")

# 3. Save to output_path
output_path.write_image(image, filename="scene_01.png")
```

## Quality Checklist

- [ ] Prompt adherence (subject matches request)
- [ ] No artifacts (extra limbs, distorted faces)
- [ ] Style consistency (matches references)
- [ ] Resolution meets target
- [ ] Color accuracy (if brand colors specified)
- [ ] No unintended text/watermarks

## Batch Processing

- Group by style/model for efficiency
- Use same seed + prompt variations for consistency
- Parallel generation (GPU memory permitting)
- Post-process batch with same settings
