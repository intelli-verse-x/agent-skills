# Motion Principles Reference
> Sources: Apple HIG Motion & Feedback (2025), NNGroup "Role of Animation in UX" (2020),
> 60fps.design best-in-class mobile patterns
> Scraped: 2026-06

---

## Apple HIG: Core Motion Philosophy

**From:** developer.apple.com/design/human-interface-guidelines/motion (updated 2025, Liquid Glass)

### Principle 1 — Purposeful Motion
> "Add motion purposefully, supporting the experience without overshadowing it."
> Gratuitous or excessive animation can distract people and may make them feel
> disconnected or physically uncomfortable.

**Rule:** Every animation must have a named job. If you can't name it, cut it.

Jobs motion can do:
1. Communicate state change
2. Provide feedback for a user action
3. Orient user in spatial/navigational hierarchy
4. Teach an affordance (signifier)
5. Create an emotional peak (brand moment — rare, reserved)

### Principle 2 — Motion Must Be Optional
> "Not everyone can or wants to experience the motion in your app or game."
> Supplement visual feedback with haptics and audio — never use motion as the
> ONLY way to communicate information.

**Rule:** Every animation must have a non-motion equivalent (color, sound, text).

### Principle 3 — Brevity and Precision
> "Aim for brevity and precision in feedback animations. When animated feedback
> is brief and precise, it tends to feel lightweight and unobtrusive."

**Rule:** Feedback animations: 80–400ms. Above 400ms = perceptible wait, not feedback.

### Principle 4 — Realistic and Consistent Direction
> "Strive for realistic feedback motion that follows people's gestures and expectations."
> If you reveal a view by sliding it down, dismiss it by sliding it back up.

**Rule:** Spatial consistency. Entry direction = reverse of exit direction.

### Principle 5 — Don't Block Input
> "Let people cancel motion. Don't make people wait for an animation to complete
> before they can do anything."

**Rule:** All animations must be interruptible by new user input.

### Principle 6 — Frequency Restraint
> "In apps, generally avoid adding motion to UI interactions that occur frequently."
> Standard elements already have subtle system animations.

**Rule:** High-frequency interactions (answer tap) = minimal, fast animation.
Low-frequency interactions (session complete) = richer, longer animation.

---

## NNGroup: The 5 Legitimate Uses of UI Animation

**From:** nngroup.com/articles/animation-purpose-ux (Laubheimer, 2020)

### Use 1: Motion for Feedback
Animations confirm that an action was recognized by the system.
- Human peripheral vision (rod cells) is tuned to detect motion → short animations guarantee feedback visibility
- Example: answer button color change + scale is guaranteed to be noticed, unlike a static badge update in the corner

**Rule:** When static feedback risks change-blindness, add motion. (Example: cart badge updating with no animation = often missed)

### Use 2: Motion to Communicate State Change
Motion shows the interface switched to a different mode or state.
- Morphing an icon (pencil → disk) communicates Edit→Save transition better than an instant swap
- Skeleton screens animated by a shimmer communicate "loading" more effectively than a spinner

**Rule:** Mode transitions need spatial or morphing animations to be understood.

### Use 3: Motion for Spatial Metaphors and Navigation
Motion orients the user in the information hierarchy.
- Zoom in = going deeper; Zoom out = going up
- Slide right = moving forward; Slide left = going back
- These patterns are learnable, but only if used consistently

**Rule:** Choose one directional metaphor per hierarchy level and never reverse it.

### Use 4: Motion as a Signifier
Motion teaches the user how to interact with an element.
- A card that bounces when entering from the bottom teaches "pull down to dismiss"
- A list item that bounces on first display teaches "swipe to reveal options"

**Rule:** Use signifier motion max once per user session (tutorial context). Don't repeat it every render.

### Use 5: Attention Grabbing (Use with Extreme Caution)
Motion hijacks attention due to rod-cell peripheral vision sensitivity.
- Benign: subtle radiating halo to highlight a specific interactive element
- Dark pattern: flashing countdown timers creating artificial urgency

**Rule:** Use attention-grabbing motion only for safety-critical or peak-moment brand actions.
NEVER use it for upsells, retention manipulations, or ads.

---

## Animation Anti-Patterns (NNGroup research-backed)

### Anti-Pattern 1: Competing Simultaneous Animations
> NNGroup Hipmunk example: 5+ animations running simultaneously — the power of
> each is diminished by competition from the others.

**Rule:** Max 2–3 animated elements at any one time on screen.

### Anti-Pattern 2: Time-Filling Animation
> "Animations are less critical for UX when they are simply time-filling visual
> stimulations during moments of transition."

**Rule:** Never add animation to hide loading time. Use skeleton screens + real data instead.

### Anti-Pattern 3: Peripheral Looping Motion
> "Our peripheral vision is responsible for detecting motion… we are sensitive
> and prone to be distracted by any type of motion."

**Rule:** No looping ambient animations on screens where the user needs to focus (quiz screen).

### Anti-Pattern 4: Inconsistent Directional Metaphors
> "If someone reveals a view by sliding it down from the top, they don't expect to
> dismiss the view by sliding it to the side." — Apple HIG

**Rule:** Build a direction grid and stick to it. See QuizVerse Navigation Directions below.

---

## Timing Reference Tables

### By Animation Category

| Category | Min | Target | Max | Easing |
|----------|-----|--------|-----|--------|
| Button tap micro-response | 60ms | 80ms | 120ms | OutQuad |
| Answer correct reveal | 150ms | 200ms | 300ms | OutBack |
| Answer wrong reveal | 150ms | 250ms | 300ms | OutQuad (shake) |
| Icon morph (state change) | 200ms | 250ms | 350ms | OutCubic |
| Screen slide forward | 250ms | 300ms | 400ms | OutCubic |
| Screen slide back | 200ms | 250ms | 350ms | OutCubic |
| Modal sheet enter | 300ms | 350ms | 450ms | OutBack |
| Modal sheet dismiss | 200ms | 250ms | 300ms | OutCubic |
| Toast notification enter | 200ms | 250ms | 300ms | OutBack |
| Toast notification exit | 150ms | 200ms | 250ms | OutCubic |
| Streak badge bounce | 250ms | 300ms | 400ms | OutElastic |
| Confetti burst | 500ms | 700ms | 900ms | OutQuint |
| Score count-up | 600ms | 900ms | 1200ms | OutExpo |
| Skeleton shimmer (loop) | 1000ms | 1200ms | 1500ms | InOutSine |
| Timer warning pulse (loop) | 400ms | 500ms | 600ms | InOutSine |

### By User Action Frequency

| Frequency | Max Duration | Notes |
|-----------|-------------|-------|
| Every tap (buttons) | 120ms | Must feel instant |
| Every answer (quiz) | 300ms | Feedback, not celebration |
| Per session milestone | 600ms | Moderate celebration |
| Session complete | 1200ms | Full peak moment |
| Daily/weekly achievement | 2000ms | Maximum investment |

---

## DOTween Easing Guide (QuizVerse implementation)

```
OutBack     — Spring into place. Use for: appear, confirm, celebrate
              Scale 0.8→1.0, or position snapping into final place
              
OutElastic  — Rubber-band. Use for: badges, streaks, high energy moments
              Never use for error states (too playful)
              
OutCubic    — Smooth confidence. Use for: screen transitions, dismissals
              The default easing when nothing special is needed
              
OutExpo     — Accelerate fast, decelerate gracefully. Use for: counters, numbers
              Score count-up, XP gain, coin earned
              
InOutSine   — Breathing. Use for: loops, pulses, shimmers
              Timer warning, skeleton loading, idle states
              
OutQuad     — Neutral utility. Use for: error states, routine feedback
              Wrong answer overlay, form validation
              
Linear      — Never use for user-facing animations. Only for debug/dev indicators.
```

---

## QuizVerse Navigation Direction Grid

Consistent spatial metaphors (Jakob's Law + NNGroup spatial navigation):

```
Forward/deeper:     Slide LEFT  (new content comes from right)
Back/up:            Slide RIGHT (returning content from left)
Modal/overlay:      Slide UP from bottom
Dismiss modal:      Slide DOWN to bottom
Alert/popup:        Scale up from center (0.8→1.0)
Dismiss alert:      Fade out + scale down (1.0→0.9)
```

**Do not deviate from this grid.** Users build spatial mental models after 3–4 interactions.

---

## Haptic + Audio Pairing (Apple HIG Accessibility Rule)

> "When you provide feedback using color, text, sound, and haptics, people can
> receive it whether they silence their device, look away from the screen, or use VoiceOver."

Required pairings:

| Event | Visual | Audio | Haptic |
|-------|--------|-------|--------|
| Correct answer | Green flash + scale | Chime ✓ | Light impact |
| Wrong answer | Red flash + shake | Buzz ✗ | Rigid impact |
| Streak milestone | Fire animation | Achievement sound | Medium impact |
| Session complete | Confetti | Fanfare | Success notification |
| Timer warning | Red pulse | Tick/beep | Soft tick |
| Button tap | Scale-punch | Click (subtle) | Selection |

---

## Accessibility: Reduce Motion

Apple HIG: "Make motion optional. Not everyone can or wants to experience the motion."
iOS `UIAccessibility.isReduceMotionEnabled` should disable/simplify animations.

**QuizVerse implementation:**
```csharp
bool ReducedMotion => SystemInfo.deviceType == DeviceType.Handheld
    && /* check PlayerPrefs or OS accessibility setting */;

float GetDuration(float full) => ReducedMotion ? full * 0.1f : full;
Ease GetEase(Ease full) => ReducedMotion ? Ease.Linear : full;
```

Minimum: correct/wrong feedback must still occur (color + sound) even with no animation.

---

## Sources
- Apple HIG Motion: developer.apple.com/design/human-interface-guidelines/motion (2025)
- Apple HIG Feedback: developer.apple.com/design/human-interface-guidelines/feedback (2025)
- NNGroup Animation Purpose: nngroup.com/articles/animation-purpose-ux (2020)
- 60fps.design: best-in-class mobile UI motion patterns (2024–2026)
- Head, V. (2016). Designing Interface Animation. Rosenfeld Media.
- Saffer, D. (2014). Microinteractions. O'Reilly Media.
