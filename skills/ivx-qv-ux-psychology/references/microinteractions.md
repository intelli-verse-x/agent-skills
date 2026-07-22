# Microinteraction Catalog
> Source: NNGroup "Microinteractions in User Experience" (Kendrick, 2018)
>         Saffer, D. (2014). Microinteractions. O'Reilly Media.
>         60fps.design best-in-class mobile patterns
> Scraped: 2026-06

---

## Definition

> **Microinteraction** = a trigger–feedback pair where:
> 1. The trigger is a user action OR a change in system state
> 2. The feedback is a narrowly targeted, contextual response communicated through small UI changes

**Not a microinteraction:**
- A GIF that plays on page load (no trigger)
- A complex multi-step flow (too broad)
- A static element always visible on screen (no trigger)

---

## The 3 Jobs of Microinteractions

### Job 1: Show System Status
Communicate what the system is currently doing, waiting for, or what just happened.

**Sub-types:**

| Sub-type | Description | Example |
|----------|-------------|---------|
| Progress indicator | System is working | Circular spinner, skeleton shimmer |
| Standby signal | System waiting for further input | iOS "jiggling app icons" on press-hold |
| Completion confirmation | Task successfully completed | Checkmark morph, toast message |
| Count/quantity update | A number changed | Badge count animating to new value |

**QuizVerse must-haves:**
- Loading state: skeleton shimmer (NOT a spinner — spinners suggest waiting, skeletons suggest near-readiness)
- Answer submitted: immediate visual lock on the choice (before server response)
- Score update on recap: animated count-up from 0→final (OutExpo, 900ms)

---

### Job 2: Error Prevention
Help users avoid mistakes or easily correct them.

**Sub-types:**

| Sub-type | Description | Example |
|----------|-------------|---------|
| Input validation | Real-time correctness signal | Password strength meter |
| Undo support | Communicate reversibility | "Undo" toast after delete |
| Destructive action guard | Confirm before irreversible action | Hold-to-confirm pattern |
| State preview | Show outcome before committing | Drag-to-reorder ghost |

**QuizVerse must-haves:**
- If user taps an answer, lock the UI immediately so double-taps don't submit twice
- Wrong answer: show the correct answer with a distinct but non-humiliating animation
- Session delete/reset: hold-to-confirm (500ms hold) rather than instant action

---

### Job 3: Communicate Brand
Reinforce the product's personality through the texture of small interactions.

**Sub-types:**

| Sub-type | Description | Example |
|----------|-------------|---------|
| Celebration | Delight at a meaningful moment | Asana unicorn, iMessage balloons |
| Sound signature | Auditory brand identity | Xbox boot sound, macOS startup chime |
| Visual character | Mascot/personality presence | Duolingo Duo, Asana unicorn |
| Tone of motion | Brand energy reflected in easing | Playful = OutElastic vs. Professional = OutCubic |

**QuizVerse brand character:**
- Smart + playful (not childish, not sterile)
- Celebration moments: confetti (not unicorns) — fits quiz/knowledge context
- Sound design: satisfying chime for correct, low "thud" for wrong — not buzzer (harsh/punishing)
- Easing default: OutBack for positive moments, OutCubic for neutral, OutQuad for errors

---

## Microinteraction Design Rules (NNGroup + Saffer)

### Rule 1: Proximity
Feedback appears at or near the trigger element.
- Tapping an answer button → visual feedback ON that button, not in a corner
- Score update → adjacent to the score display, not elsewhere

### Rule 2: Duration Proportionality
Duration matches the significance of the event.
- Routine action (button tap) → 80–120ms
- Completion of task (daily goal) → 500–800ms
- Once-a-week milestone → up to 1500ms

### Rule 3: Single Purpose
Each microinteraction does exactly ONE thing.
- Correct answer: communicate "right" (not also "you're amazing" + "next question" + "streak update" simultaneously)
- Separate the "correct" flash from the "streak update" by 200ms minimum

### Rule 4: Non-Intrusive
The microinteraction should not interrupt the user's primary task.
- Quiz timer: passive color change, not a modal
- Achievement unlock: slide-in toast, not a full-screen interruption
- Score: updates in-place, not with a celebration that requires dismissal

### Rule 5: Interruptible
User can proceed without waiting for the animation to finish.
- Answer reveal animation: auto-advance to next question at animation end, OR tap to skip
- Confetti: continues in background while recap content is visible and tappable

---

## Microinteraction Anti-Patterns

### Anti-Pattern: The Non-Interactable Button
A button with no visual feedback on tap.
- Users tap twice → double submission
- Users think it didn't register → frustration
- **Fix:** Scale-punch (0.95→1.0, 80ms) is minimum acceptable feedback on every button

### Anti-Pattern: The Intrusive Celebration
Full-screen modal animation blocking interaction after every quiz question.
- Breaks flow state (Csikszentmihalyi)
- Trains users to see each question as an interruption
- **Fix:** In-place animation for per-question feedback; full-screen only at session end

### Anti-Pattern: Uniform Feedback
Using the same animation/sound for correct AND wrong answers.
- Violates Von Restorff Effect — users stop distinguishing the states
- **Fix:** Two clearly different animations, different sounds, different colors

### Anti-Pattern: The Permanent Celebration
Looping confetti/particle effect that never stops.
- Peripheral motion = distraction (NNGroup rod-cell research)
- After 2–3 seconds, any looping animation reads as "stuck" not "joyful"
- **Fix:** Burst (700ms) → dissipate over 1.5s → gone. Never loop.

### Anti-Pattern: No Feedback Delay Between Questions
Instantly advancing to next question with no pause.
- Correct answer flash is missed (100ms isn't enough to register)
- Users feel like they're in a click-spam sequence, not a quiz
- **Fix:** 800ms minimum hold after correct/wrong reveal before advancing

---

## Microinteraction Catalog for QuizVerse

### P0 — Must ship with every build

| ID | Trigger | Feedback | Duration | Easing | Notes |
|----|---------|----------|----------|--------|-------|
| MI-01 | Answer button pressed | Scale 1.0→0.92→1.05 + ring highlight | 80ms down, 40ms up | OutQuad | Optimistic — before server |
| MI-02 | Correct answer confirmed | Green overlay fade in + checkmark scale-in | 200ms | OutBack | Lock other choices to grey |
| MI-03 | Wrong answer confirmed | Red overlay + horizontal shake (6px, 3 cycles, 250ms) | 250ms | OutQuad | Show correct in green simultaneously |
| MI-04 | Timer < 5 seconds | Color transition yellow→orange→red | 500ms cross-fade | InOutSine | Pulse at <3s |
| MI-05 | Streak increments | Streak badge scale bounce + number morph | 300ms | OutElastic | Only on increment, not on every question |

### P1 — Ship in next sprint

| ID | Trigger | Feedback | Duration | Easing | Notes |
|----|---------|----------|----------|--------|-------|
| MI-06 | Session complete | Full-screen confetti burst | 700ms burst, 1.5s dissipate | OutQuint | Non-blocking |
| MI-07 | Score updated on recap | Count-up from 0 to final | 900ms | OutExpo | Starts 300ms after screen appears |
| MI-08 | Loading state | Skeleton shimmer on content placeholders | 1200ms loop | InOutSine | Replace spinner |
| MI-09 | Achievement unlock | Slide-up toast (bottom) + icon scale-in | 300ms enter | OutBack | Auto-dismiss 3s |
| MI-10 | Daily goal completed | Full-screen overlay with streak fire + confetti | 600ms | OutElastic + OutQuint | Then auto-dismiss |

### P2 — Backlog

| ID | Trigger | Feedback | Duration | Easing | Notes |
|----|---------|----------|----------|--------|-------|
| MI-11 | Paywall dismiss | Gentle slide-down | 250ms | OutCubic | Not abrupt pop |
| MI-12 | Streak broken | Sad shake on streak badge | 300ms | OutQuad | Don't over-dramatize |
| MI-13 | New personal record | Gold flash on score + "New Record" badge scales in | 400ms | OutBack | |
| MI-14 | Category 100% complete | Ring fills + pulse + check | 500ms | OutElastic | |
| MI-15 | Sound toggle ON | Speaker icon morphs + brief sound preview | 200ms | OutCubic | Accessibility signal |

---

## DOTween Implementation Snippets

### MI-01: Button Press Scale-Punch
```csharp
public static void PunchButton(Transform btn) {
    btn.DOKill();
    btn.DOScale(0.92f, 0.08f)
       .SetEase(Ease.OutQuad)
       .OnComplete(() => btn.DOScale(1.05f, 0.04f)
           .SetEase(Ease.OutQuad)
           .OnComplete(() => btn.DOScale(1f, 0.04f)));
}
```

### MI-02: Correct Answer Flash
```csharp
public static void ShowCorrect(CanvasGroup overlay, Transform icon) {
    overlay.DOKill(); icon.DOKill();
    overlay.alpha = 0;
    overlay.DOFade(0.7f, 0.2f).SetEase(Ease.OutBack);
    icon.DOScale(1f, 0.2f).From(0f).SetEase(Ease.OutBack);
}
```

### MI-03: Wrong Answer Shake
```csharp
public static void ShakeWrong(Transform target) {
    target.DOKill();
    target.DOShakePosition(0.25f, new Vector3(6f, 0f, 0f), 3, 0f, false, true);
}
```

### MI-05: Streak Badge Bounce
```csharp
public static void BounceStreak(Transform badge) {
    badge.DOKill();
    badge.DOScale(1f, 0.3f).From(0.7f).SetEase(Ease.OutElastic);
}
```

### MI-07: Score Count-Up
```csharp
public static IEnumerator CountUp(TMP_Text label, int from, int to, float duration) {
    float elapsed = 0f;
    while (elapsed < duration) {
        elapsed += Time.deltaTime;
        float t = Mathf.Clamp01(elapsed / duration);
        // OutExpo: 1 - pow(2, -10*t)
        float eased = t >= 1f ? 1f : 1f - Mathf.Pow(2f, -10f * t);
        label.text = Mathf.RoundToInt(Mathf.Lerp(from, to, eased)).ToString();
        yield return null;
    }
    label.text = to.ToString();
}
```

---

## Sources
- NNGroup: nngroup.com/articles/microinteractions (Kendrick, 2018)
- Saffer, D. (2014). Microinteractions. O'Reilly Media.
- 60fps.design (2024–2026)
- Apple HIG Feedback: developer.apple.com/design/human-interface-guidelines/feedback (2025)
