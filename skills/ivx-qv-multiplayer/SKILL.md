---
name: ivx-qv-multiplayer
description: Work with Photon PUN2 real-time multiplayer and Nakama async challenges in QuizVerse.
version: "1.0"
---

## When to Use
"multiplayer", "Photon", "Nakama", "room", "sync", "network", "PvP", "RPC"

## Architecture
```
UnifiedMultiplayerManager (hub)
├── SyncMultiplayerProvider  → Photon PUN2 (real-time rooms)
└── AsyncMultiplayerProvider → Nakama (async challenges)
```

## Photon Quick-Ref
- **Callbacks:** Extend `MonoBehaviourPunCallbacks`, call `base.OnEnable()`
- **RPCs:** `[PunRPC] void Method()` — guard with `PhotonNetwork.InRoom`
- **Room props:** Use `SetCustomProperties` with CAS for sync
- **Scene GO:** `Manager/check` has `PhotonView` + both providers
- **Read-only:** `Assets/Photon/` — NEVER modify

## Nakama Quick-Ref
- **RPCs:** 100+ across 18 domains, registered in `data/modules/index.js`
- **Backend:** `c:\Office\Backend\nakama\data\modules\`
- **Auth:** Device, Custom, AWS Cognito
- **Wallet:** `QVNWalletManager` → Nakama wallet (server-authoritative)

## Common Errors
| Error | Cause | Fix |
|-------|-------|-----|
| Photon disconnect on answer | RPC after room left | Guard `PhotonNetwork.InRoom` |
| Score desync | Race condition | Use CAS in `SetCustomProperties` |
| Room join fails | Max players or closed | Handle `OnJoinRoomFailed` callback |
| Nakama 401 | Token expired | Check `AuthTokenManager` refresh |

## Context Files (load only if needed)
- Multiplayer API: `docs/context/micro/MULTIPLAYER_INTERFACE.md` (3.8 KB)
- Full architecture (grep only!): `docs/context/multiplayer-flow-architecture.md` (45 KB)
