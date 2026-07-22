---
name: ivx-qv-monetization
description: Work with IAP, ad waterfall, rewarded ads, and economy systems in QuizVerse.
version: "1.0"
---

## When to Use
"IAP", "ads", "revenue", "purchase", "subscription", "ad", "monetization", "coins", "gems"

## Economy Stack
```
QVNWalletManager → Nakama wallet (server-authoritative)
├── Currencies: Coins, Gems, Energy, XP
├── ShopScreen → IAP purchases
├── IVXAdsBootstrap → Ad SDK init
├── AdVisibilityController → Banner visibility
└── NotEnoughPopup → upsell flow
```

## Key GameObjects
- `WalletManager` GO → `QVNWalletManager`
- `AdsBootstrap` GO → `IVXAdsBootstrap`
- `AdVisibilityController` GO → banner toggle
- `Popup_Canvas/NoadsPop` → `NoAdsPopupUI` (premium upsell)

## Rules
- All reward grants must be server-authoritative (Nakama)
- Premium users: skip all ads (`NoAdsPopupUI` check)
- Rewarded ads: always have fallback if ad not loaded
- ILRD (Impression Level Revenue Data) must report to analytics

## Context Files (load only if needed)
- Economy API: `docs/context/micro/ECONOMY_INTERFACE.md` (1.5 KB)
- Persona: `.agents/personas/monetization-specialist.md`
