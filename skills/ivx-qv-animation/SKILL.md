---
name: ivx-qv-animation
description: DOTween animation, coroutine sequences, UI transitions, and motion design in QuizVerse.
version: "1.0"
---

## When to Use
"animation", "animate", "DOTween", "tween", "transition", "fade", "slide", "bounce", "motion"

## Animation Stack in QuizVerse
```
DOTween (via Doozy) → Primary animation engine (92+ scripts)
Coroutines         → Sequencing, delays, multi-step flows
schedule.Execute() → UI Toolkit only (OnboardingManagerV2)
```
> **No Animator controllers or Timeline in this project**

## DOTween Patterns
```csharp
// Fade in
canvasGroup.DOFade(1f, 0.3f).SetEase(Ease.OutQuad);

// Slide from bottom
transform.DOLocalMoveY(0f, 0.4f).SetEase(Ease.OutBack);

// Scale bounce
transform.DOScale(1f, 0.3f).From(0.5f).SetEase(Ease.OutElastic);

// Sequence
var seq = DOTween.Sequence();
seq.Append(canvasGroup.DOFade(1f, 0.3f));
seq.Append(transform.DOLocalMoveY(0f, 0.4f));
seq.Play();
```

## Critical Rules
1. **Kill tweens on disable:** `DOTween.Kill(transform)` or `_tween?.Kill()`
2. **Cache sequences** — never allocate in Update
3. **SetUpdate(true)** for timeScale-independent UI animations
4. **Use `.SetLink(gameObject)`** to auto-kill on destroy
5. **Doozy is read-only** (`Assets/Doozy/` — NEVER modify)

## Coroutine Sequencing (when DOTween is unavailable)
```csharp
private IEnumerator AnimateSequence() {
    yield return FadeIn(canvasGroup, 0.3f);
    yield return new WaitForSeconds(0.2f);
    yield return SlideUp(transform, 0.4f);
}

// Always stop on disable:
private Coroutine _activeSequence;
void OnDisable() {
    if (_activeSequence != null) StopCoroutine(_activeSequence);
}
```

## Common Presets (from UIAnimationPresets.cs)
| Preset | Use For |
|--------|---------|
| FadeIn + SlideUp | Screen show |
| FadeOut + SlideDown | Screen hide |
| ScalePunch | Button tap feedback |
| ShakePosition | Error/wrong answer |
| CountUp (DOTween value) | Coin/score counter |

## Memory Safety
- ❌ Never: `DOTween.Sequence()` without killing on disable
- ❌ Never: `StartCoroutine()` in OnEnable without stopping in OnDisable
- ✅ Always: `_tween?.Kill(); _tween = null;` in OnDisable
- ✅ Always: Cache `WaitForSeconds` objects: `private static readonly WaitForSeconds _wait = new(0.3f);`

## Context Files (load only if needed)
- Presets: `Scripts/UI/Core/UIAnimationPresets.cs`
- Flow controller: `Scripts/UI/Core/UIFlowController.cs`
