---
name: ivx-qv-release
description: Pre-release checks, build preparation, and shipping readiness for QuizVerse.
version: "1.0"
---

## When to Use
"release", "ship", "launch", "deploy", "readiness", "pre-release", "build"

## Release Checklist
```
1. Console errors → ZERO (read_console types=["error"])
2. All scenes in build settings → manage_build(action="scenes")
3. Bundle ID / version correct → manage_build(action="settings")
4. Platform-specific:
   - Android: keystore, min SDK, target SDK, proguard
   - iOS: signing, usage descriptions, Xcode version
   - WebGL: no System.IO, compression settings
5. Monetization: ad SDK init, ILRD reporting, premium checks
6. Analytics: all events firing, no debug flags
7. Localization: all strings translated, no missing keys
8. Performance: FPS > 30 on target devices
```

## Context Files (load only if needed)
- Release workflow: `.agents/workflows/release.md`
- QA workflow: `.agents/workflows/qa.md`
- Persona: `.agents/personas/qa-engineer.md`
