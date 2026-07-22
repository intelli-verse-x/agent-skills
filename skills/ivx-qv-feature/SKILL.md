---
name: ivx-qv-feature
description: Plan and implement new features, screens, managers, and systems in QuizVerse.
version: "1.0"
---

## When to Use
"add", "create", "implement", "build", "new feature", "design"

## Implementation Flow
```
1. Check non-goals in AGENTS.md → abort if out of scope
2. Plan: identify layer (UI/Manager/Service), namespace, dependencies
3. Create script using naming convention:
   - Manager → *Manager.cs (PersistentSingleton<T>)
   - Screen  → *Screen.cs (MonoBehaviour + CanvasGroup)
   - Service → *Service.cs (pure C#)
   - Data    → *Data.cs (ScriptableObject)
4. Wire in scene → attach to appropriate canvas/manager GO
5. Test → console clean, UI interactable
6. Update registry → `docs/context/registry.md`
```

## Script Templates
| Role | Template | Size |
|------|----------|------|
| Manager | `.cursor/examples/MANAGER_TEMPLATE.cs` | 3.6 KB |
| UI Controller | `.cursor/examples/UI_CONTROLLER_TEMPLATE.cs` | 4.7 KB |
| Service | `.cursor/examples/SERVICE_TEMPLATE.cs` | 8.9 KB |
| Editor Tool | `.cursor/examples/EDITOR_TOOL_TEMPLATE.cs` | 14 KB |

## Required Patterns
- `[SerializeField] private` for Inspector fields
- XML docs on all public members
- `OnEnable +=` / `OnDisable -=` for events
- Null-safe: `Instance?.Method()`, `TryGetComponent`
- No allocations in hot paths

## Context Files (load only if needed)
- Planning workflow: `.agents/workflows/plan.md`
- Implementation steps: `.agents/workflows/implement.md`
- Registry (grep only!): `docs/context/registry.md` (52 KB)
