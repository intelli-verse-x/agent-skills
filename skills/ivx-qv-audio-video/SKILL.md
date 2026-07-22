---
name: ivx-qv-audio-video
description: Work with AudioSource, VideoPlayer, audio quiz playback, AI voice, and media streaming in QuizVerse.
version: "1.0"
---

## When to Use
"audio", "sound", "music", "AudioSource", "video", "VideoPlayer", "voice", "mic", "media playback"

## Audio Architecture
```
AudioManager (root GO) → Background music, SFX
Manager GO → AudioSource + VideoPlayer (quiz media)
AIHostManager → AIHostAudioPlayer (AI voice synthesis)
AIFortuneTellerManager → AIFortuneTellerAudioPlayer
SubjectiveQuiz → AudioSource (voice recording)
```

## AudioSource GameObjects (4 in scene)
| GO | Component | Purpose |
|----|-----------|---------|
| Manager | AudioSource | Quiz media playback |
| Subjective Quiz | AudioSource | Voice recording/playback |
| Ai Host New | AudioSource | AI host voice |
| BadgePopupUI | AudioSource | Badge earned SFX |

## VideoPlayer (1 in scene)
| GO | Purpose |
|----|---------|
| Manager | Quiz media video playback |

## Key Scripts
| Script | Purpose |
|--------|---------|
| `QuizMediaService` | Fetches audio/video from S3/CDN |
| `MediaQuizMode` | Audio quiz gameplay controller |
| `AIHostAudioPlayer` | AI-generated voice playback |
| `AIHostMicCapture` | Microphone input for voice quiz |
| `MicrophoneUsagePopup` | Mic permission request |

## Common Errors
| Error | Cause | Fix |
|-------|-------|-----|
| Audio not playing | AudioSource not enabled or clip null | Check `audioSource.clip != null && audioSource.enabled` |
| Video black screen | VideoPlayer not prepared | `videoPlayer.Prepare(); yield return new WaitUntil(() => videoPlayer.isPrepared);` |
| Mic permission denied | Missing usage description | iOS: add Microphone description to Info.plist |
| Audio stutter on mobile | Large uncompressed clips | Use compressed format (Vorbis), stream from disk |

## Patterns
```csharp
// Safe audio play
if (audioSource != null && clip != null) {
    audioSource.clip = clip;
    audioSource.Play();
}

// Safe video prepare + play
videoPlayer.source = VideoSource.Url;
videoPlayer.url = mediaUrl;
videoPlayer.Prepare();
yield return new WaitUntil(() => videoPlayer.isPrepared);
videoPlayer.Play();
```

## Cleanup
- `audioSource.Stop()` in OnDisable
- `videoPlayer.Stop(); videoPlayer.targetTexture?.Release();` in OnDisable
- Release microphone: `Microphone.End(deviceName);`
