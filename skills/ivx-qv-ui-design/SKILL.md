---
name: ivx-qv-ui-design
description: Build and modify UI screens, panels, popups, responsive layouts, and UI Toolkit documents in QuizVerse.
version: "1.0"
---

## When to Use
"UI", "canvas", "screen", "button", "panel", "responsive", "anchor", "layout", "UI Toolkit", "UXML", "USS"

## Canvas Architecture
| Canvas | Purpose | Controller |
|--------|---------|------------|
| Screen_Canvas | 23 fullscreen panels (1 active) | `UIFlowController` |
| Popup_Canvas | 14 modal dialogs | Stack-based push/pop |
| HUD_Canvas | Onboarding overlay | `OnboardingManagerV2` |
| Toast_Canvas | Notifications | `ToastController` |

## Navigation
- `UIFlowController.NavigateTo(ScreenType)` → show target, push current
- `ScreenType` enum: 87+ types in `UIScreen.cs`
- Show/Hide via CanvasGroup alpha + interactable + blocksRaycasts

## Responsive Rules
- **Anchors:** Stretch-to-fill for backgrounds, center-pivot for content
- **Safe Area:** Apply `Screen.safeArea` to root panels
- **Auto-size text:** TMP Auto Size (min=12, max=36)
- **Touch targets:** Minimum 44×44 pt
- **Interactive elements:** 2x sizing rule for mobile
- **Spacing:** 1.5x vertical rhythm for readability

## UI Toolkit (Onboarding V2)
- UXML + USS files in `Assets/_QuizVerse/UI/`
- `OnboardingManagerV2` uses `UIDocument` component
- Always use `<ui:Style>` prefix (not bare `<Style>`)
- USS: use `--custom-properties` for theme tokens

## Validation Checklist
- [ ] Button interactable + raycast target
- [ ] CanvasGroup wired (alpha, interactable, blocksRaycasts)
- [ ] Safe area handler on root
- [ ] No overlapping invisible raycast blockers
- [ ] Text auto-sizes within bounds

## Context Files (load only if needed)
- Full UI rules: `docs/context/ui-rules.md` (9 KB)
- UI Manager API: `docs/context/micro/UI_MANAGER_INTERFACE.md` (3.8 KB)
- UI Toolkit guide: `.agents/context/ui-toolkit-guidelines.md` (5.9 KB)
- Template: `.cursor/examples/UI_CONTROLLER_TEMPLATE.cs` (4.7 KB)
