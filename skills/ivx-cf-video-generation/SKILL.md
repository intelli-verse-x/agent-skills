---
name: ivx-cf-video-generation
description: Design and execute video generation pipelines using diffusion and transformer models. Use when generating video content, optimizing video quality, or building video production workflows.
---
# Video Generation Skill

## Purpose

Generate high-quality video content through structured, reproducible pipelines.

## Pipeline Stages

1. **Concept**: Creative brief, target audience, platform
2. **Pre-visualization**: Storyboard, keyframes, style references
3. **Image Generation**: Lock first frames with consistent style
4. **Video Generation**: Animate using image-to-video
5. **Post-Processing**: Upscale, color grade, assemble
6. **Audio**: Voiceover, music, SFX, mixing
7. **Export**: Format, codec, resolution, platform specs

## Generation Strategy

| Approach | Best For | Tools |
|----------|---------|-------|
| Text-to-video | Exploration, prototyping | Kling, Runway, Sora |
| Image-to-video | Quality, consistency | Kling, Runway Gen-4 |
| Video-to-video | Style transfer, editing | Runway, Seedance |

### CF-Specific Flow

```python
# 1. Generate/Load keyframe
keyframe = await generate_keyframe(prompt, style_refs)

# 2. Generate video clip
clip = await generate_video(
    image=keyframe,
    motion_prompt="slow dolly in, gentle camera pan",
    duration=5,  # seconds
    fps=24,
)

# 3. Post-process
clip = await upscale(clip, target_resolution="1080p")
clip = await color_grade(clip, style="cinematic_warm")

# 4. Add audio
audio = await generate_voiceover(script, voice_id)
audio = await mix_audio(audio, music_track, sfx)

# 5. Assemble
video = await assemble_clips([clip1, clip2, ...], audio)
```

## Quality Checklist

- [ ] First frame matches reference
- [ ] Motion is smooth (no flicker/judder)
- [ ] Subject consistency across frames
- [ ] No artifacts or distortions
- [ ] Resolution meets target (1080p minimum)
- [ ] Frame rate consistent (24/30/60 fps)
- [ ] Audio synced to video
- [ ] Color grade consistent across clips

## Cost Optimization

- Batch similar scenes together
- Use image-to-video over text-to-video
- Generate short clips (2-6s), assemble in post
- Use self-hosted models (Wan 2.2) for volume
- Pre-warm GPU pods for batch jobs
- Cache intermediate assets (keyframes, voice)

## Consistency

- Character identity: `utils.pipeline.character_identity`
- Voice: `utils.pipeline.voice_consistency`
- Style: Seed management, reference anchoring
- Brand: `utils.pipeline.brand_memory`

## Background music mix

- Royalty-free sources OK when licensed; keep voiceover clear (duck music under VO)
- FFmpeg mix: volume, fade in/out; CF already has `mix_audio` / ACE-Step music — prefer the CF pipeline audio stage when available
- License gate before publish (confirm rights for every track)
- Acceptance: `@cf-video-loop` checklist covers audio sync
