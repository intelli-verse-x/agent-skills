---
name: ivx-qv-architecture
description: System design, architecture decisions, dependency analysis, and refactoring in QuizVerse.
version: "1.0"
---

## When to Use
"architecture", "design pattern", "system design", "singleton", "service locator", "refactor", "restructure", "dependency"

## Core Patterns
```
MVVM + Service Locator + Event-Driven
Layer Rule: UI → Manager → Service → Backend (NEVER skip)
Data Flow:  DTO → Domain → ViewModel → View
Authority:  Server authoritative for rewards/scores
Singletons: PersistentSingleton<T> pattern
Events:     OnEnable += / OnDisable -= lifecycle
```

## Key Interfaces
| System | Entry Point | Layer |
|--------|------------|-------|
| Navigation | `UIFlowController.NavigateTo()` | UI |
| Quiz lifecycle | `GameSessionManager` | Manager |
| Questions | `QuizQuestionService` → `QuestionRepository` | Service |
| Economy | `QVNWalletManager` → Nakama | Service→Backend |
| Multiplayer | `UnifiedMultiplayerManager` | Manager |
| Engagement | `EngagementSystems` (16 children) | Manager |

## Non-Goals (NEVER do without explicit request)
- Change singleton pattern or add new base classes
- Add DI container (we use Service Locator)
- Modify read-only SDKs (Photon, Doozy, Plugins)
- Add game modes without request

## Context Files (load only if needed)
- Full architecture: `docs/context/architecture.md` (14.5 KB)
- State ownership: `docs/context/micro/STATE_OWNERSHIP.md` (6.5 KB)
- Dependency workflow: `.agents/workflows/deps.md`
- Persona: `.agents/personas/unity-architect.md`
