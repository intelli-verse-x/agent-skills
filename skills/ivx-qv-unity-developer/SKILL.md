---
name: ivx-qv-unity-developer
description: Build Unity games with optimized C# scripts, efficient rendering, and proper asset management for QuizVerse (Unity 6, Built-in pipeline, mobile).
version: "5.0"
---

## Use this skill when
- Writing C# scripts for gameplay, UI, physics, or networking
- Optimizing performance for Android/iOS/WebGL
- Making architecture and design pattern decisions

## Critical Performance Rules
1. **NEVER `Find()`/`GetComponent()` in `Update()`** — cache in `Awake()`/`Start()`
2. **Object pooling** for frequently spawned/destroyed objects
3. **StringBuilder** for string concatenation in hot paths
4. **`CompareTag()`** instead of `== "tag"`
5. **Cache `WaitForSeconds`** — don't allocate every frame
6. **No LINQ in Update/FixedUpdate** — causes GC allocations
7. **`[SerializeField] private`** over `public` for Inspector fields
8. **No `Camera.main` in loops** — cache the reference

## Architecture Patterns (QuizVerse)
- **Singleton:** `QuizManager.Instance?.Method()` — always null-safe
- **Events:** C# events (`OnEnable +=`, `OnDisable -=`) for memory safety
- **Layer rule:** `UI → Manager → Service → Backend` (never skip layers)
- **ScriptableObject** for data-driven config
- **State machines** for game state and character control

## Script Role Convention
| Role | Naming | Base Class |
|------|--------|-----------|
| Manager | `*Manager` | MonoBehaviour (Singleton) |
| Controller | `*Controller` | MonoBehaviour |
| UI | `*Screen/*Panel/*Popup` | MonoBehaviour |
| Data | `*Data/*Config` | ScriptableObject/class |
| Service | `*Service` | Pure C# |
| Utility | `*Helper/*Utility` | Static class |

## Async Decision Ladder
```
1. Event-driven? → C# events/callbacks (PREFERRED)
2. Unity-bound sequence? → Coroutine (QUIZVERSE DEFAULT)
3. Need cancellation? → async/await + CancellationToken
4. Continuous simulation? → Update (last resort)
```

## Mobile Performance Checklist
- [ ] Texture sizes appropriate (max 2048 for UI, 1024 for sprites)
- [ ] Draw calls batched (check Frame Debugger)
- [ ] No string alloc in Update loops
- [ ] Safe Area handled for notches (`Screen.safeArea`)
- [ ] No reflection in hot paths (IL2CPP compatibility)

## Inspector Design
```csharp
[Header("Configuration")]
[Tooltip("Description")]
[SerializeField, Range(1, 10)] private int _value = 3;

[Header("References")]
[SerializeField] private Transform _target;
```
