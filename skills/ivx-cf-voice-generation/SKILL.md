---
name: ivx-cf-voice-generation
description: Design and implement text-to-speech and voice synthesis pipelines. Use when generating voiceovers, cloning voices, or designing audio content.
---
# Voice Generation Skill

## Purpose

Generate high-quality voice audio for video and interactive content.

## Pipeline

1. **Script**: Finalized text with timing marks
2. **Voice Selection**: Match character/brand voice
3. **Generation**: TTS with emotion/style control
4. **Post-Processing**: Normalize, EQ, de-ess
5. **Sync**: Align with video timing

## Tools

| Tool | Use Case | Quality |
|------|----------|---------|
| ElevenLabs | Professional voiceovers | High |
| Kokoro | Fast, lightweight TTS | Medium |
| F5-TTS | Voice cloning | High |
| Chatterbox | Conversational | Medium |

## CF Integration

```python
from utils.pipeline.voice_consistency import assign_voice
from utils.pipeline.voice_generator import generate_speech

voice_id = assign_voice(
    character_id=character_id,
    brand_id=brand_id,
    emotion="neutral",
)

audio = generate_speech(
    text=script,
    voice_id=voice_id,
    speed=1.0,
    stability=0.5,
)
```

## Quality Gates

- [ ] Pronunciation correct
- [ ] Emotion matches scene
- [ ] Consistent with previous episodes
- [ ] No audio artifacts (clipping, noise)
- [ ] Synced to video (if applicable)

## Cost

- ElevenLabs: ~$0.30/min (high quality)
- Self-hosted Kokoro: ~$0.01/min (GPU cost)
- Batch generation for cost savings
