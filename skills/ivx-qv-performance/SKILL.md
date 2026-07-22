---
name: ivx-qv-performance
description: Profile and optimize CPU, memory, GC, and rendering performance for mobile QuizVerse.
version: "1.0"
---

## When to Use
"slow", "lag", "fps", "memory", "optimize", "profile", "GC", "allocation"

## Protocol
```
1. Measure baseline (FPS, draw calls, GC) → MCP profiler or Unity Profiler
2. Identify hotspot → CPU spike? GC alloc? Draw calls?
3. Fix at source → apply pattern below
4. Measure after → confirm improvement
5. Never optimize without measured issue
```

## Forbidden in Hot Paths (Update/FixedUpdate/LateUpdate)
- ❌ `Find()`, `GetComponent()`, `Camera.main`
- ❌ LINQ, closures, boxing, `string +` concat
- ❌ `new WaitForSeconds()` every frame → cache it
- ❌ `CompareTag()` via `== "string"` → use `CompareTag()`

## Fix Patterns
| Problem | Solution |
|---------|----------|
| GC spikes | Cache references in `Awake()`, use `StringBuilder` |
| Draw calls | Enable dynamic/static batching, use atlases |
| Texture memory | Max 2048 UI, 1024 sprites, compress ASTC |
| Coroutine alloc | Cache `WaitForSeconds`, pool coroutines |
| String alloc | `StringBuilder`, cached `ToString()` |
| Event overhead | `OnEnable +=` / `OnDisable -=` (prevent leaks) |

## MCP Profiler Commands
```
manage_profiler(action="profiler_start")
manage_profiler(action="get_frame_timing")
manage_profiler(action="get_counters", category="Render")
manage_profiler(action="stats_get")
```

## Context Files (load only if needed)
- Workflow: `.agents/workflows/perf.md`
- Persona: `.agents/personas/perf-engineer.md`
