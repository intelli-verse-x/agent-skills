---
name: ivx-qv-ux-psychology
description: >
  Expert in UX psychology, motion design, and microinteraction patterns for QuizVerse.
  Grounds every design decision in peer-reviewed research: Laws of UX, Apple HIG,
  NNGroup, and 60fps best-in-class mobile patterns. Use when "UX, feel, delight,
  polish, feedback, animation timing, microinteraction, psychology, engagement,
  reward, streak, confetti, transition, splash, loading, button feel" is mentioned.
version: "1.0"
research_sources:
  - lawsofux.com (Jon Yablonski)
  - Apple Human Interface Guidelines – Motion & Feedback (2025)
  - Nielsen Norman Group – Animation Purpose & Microinteractions
  - 60fps.design – best-in-class mobile motion patterns
  - Kahneman Peak-End Rule (1993)
  - Doherty Threshold – IBM Systems Journal (1982)
---

## When to Use

**Primary keywords:** UX, feel, delight, polish, feedback, animation timing, microinteraction,
psychology, engagement, reward, streak, confetti, confetti burst, transition, splash, loading,
button feel, haptic, bounce, ease, flow state, retention

**Common combos:**
- "Make the correct-answer feel more satisfying" → this skill + `animation/SKILL.md`
- "Why does the streak screen feel flat?" → this skill + `ui-design/SKILL.md`
- "Add delight to the loading screen" → this skill + `animation/SKILL.md`

---

## Core Principle (memorize this)

> **Motion serves cognition, not decoration.**
> Every animation must do at least one of: communicate state, reinforce meaning,
> reduce cognitive load, or build emotional connection. If it does none of these, cut it.
> — NNGroup, Apple HIG, Laws of UX (combined consensus)

---

## Psychology Laws Applied to QuizVerse

### 1 · Doherty Threshold — "Under 400ms or users disengage"
- **Rule:** Feedback must arrive within **400ms** of user action.
- **QuizVerse application:**
  - Button tap → visual response ≤ 100ms (scale punch or highlight)
  - Answer submit → result reveal ≤ 300ms
  - Screen transition → begin within 150ms of gesture/tap
- **Pattern:** If real processing takes >400ms, start a skeleton/shimmer immediately; never show a blank screen.

### 2 · Peak-End Rule — "Only the peak and ending are remembered"
- **Rule:** Users judge the entire experience by its most intense moment and how it ended.
- **QuizVerse application:**
  - **Peak:** Correct streak milestone (3, 5, 7…) → must have a premium animation burst
  - **Peak:** Wrong answer on a long streak → shake + audio cue, but recover fast
  - **End:** Session recap screen is the most important screen for retention — invest here
  - **End:** Never end on an error. Always end on an encouraging forward hook.

### 3 · Zeigarnik Effect — "Uncompleted tasks stay top-of-mind"
- **Rule:** Interrupted or incomplete tasks are remembered 2× better than completed ones.
- **QuizVerse application:**
  - Show partial progress bars on the home screen (not 0%, not 100%)
  - "You're on question 4 of 10" during quiz keeps users in the loop
  - Daily streak badge showing "2 of 3 days complete" is more motivating than "Start"

### 4 · Goal-Gradient Effect — "Effort accelerates near the finish line"
- **Rule:** People speed up and engage more as they approach a goal.
- **QuizVerse application:**
  - Progress bar should visually accelerate (ease-in-back) near 100%
  - At 80% completion, increase positive reinforcement frequency
  - Final question of a quiz: more dramatic reveal animation

### 5 · Aesthetic-Usability Effect — "Beautiful = perceived as easier"
- **Rule:** Aesthetically polished UI is perceived as more usable, even if function is identical.
- **QuizVerse application:**
  - Polish the 3 highest-traffic screens first: Home, Quiz, Recap
  - Consistent shadow depth, corner radius (16dp), and color palette builds trust
  - Small details (smooth easing, micro-bounce) reduce perceived difficulty of hard questions

### 6 · Von Restorff Effect — "The different thing is remembered"
- **Rule:** The item that stands out from a group is most memorable.
- **QuizVerse application:**
  - Correct answer highlight: different color + scale, not just color alone
  - Streak milestone: unique animation that doesn't repeat for lower combos
  - Wrong answer: distinct shake — never reuse the correct-answer style

### 7 · Miller's Law — "7 ± 2 items in working memory"
- **Rule:** Cognitive overload above ~7 simultaneous elements.
- **QuizVerse application:**
  - Quiz screen: max 4 answer choices, never 6+
  - Recap screen: max 3 primary stats visible without scroll
  - Settings: chunk into max 5 groups

### 8 · Hick's Law — "More choices = longer decisions"
- **Rule:** Decision time grows logarithmically with number of options.
- **QuizVerse application:**
  - Mode selection: default pre-selected, not equal options
  - Category grid: 6 visible tiles max without scroll
  - Paywall: single highlighted "Best Value" tier, not 5 equal tiers

---

## Motion Principles (Apple HIG + NNGroup synthesis)

### The 5 Legitimate Uses of Animation

| Use | Description | QuizVerse Example |
|-----|-------------|-------------------|
| **1. Feedback** | Confirm action was received | Button scale-punch on tap |
| **2. State Change** | Show mode/status transition | Timer turns red when < 5s |
| **3. Spatial Metaphor** | Orient user in hierarchy | Slide right = go deeper |
| **4. Signifier** | Teach gesture affordance | Swipe hint bounce on cards |
| **5. Emotional Peak** | Brand moment at peak/end | Confetti on 5-streak |

> **Never animate just to fill time.** Loading spinners without content skeleton = bad UX.

### Timing Standards (from Apple HIG + 60fps.design patterns)

| Animation Type | Duration | Easing |
|----------------|----------|--------|
| Button tap response | 80–120ms | `OutQuad` |
| Correct/wrong answer reveal | 200–300ms | `OutBack` (correct) / `OutQuad` (wrong) |
| Screen slide transition | 300–400ms | `OutCubic` |
| Modal sheet appear | 350–450ms | `OutBack` |
| Confetti burst | 600–900ms | `OutQuint` (particles) |
| Score count-up | 800–1200ms | `OutExpo` |
| Streak milestone | 400–600ms | `OutElastic` |
| Timer pulse (< 5s) | 500ms loop | `InOutSine` |
| Loading skeleton shimmer | 1200ms loop | `InOutSine` |

### Easing Cheat Sheet (DOTween names)

```
Ease.OutBack     → spring-into-place (rewards, confirmations)
Ease.OutElastic  → rubber-band bounce (streak, milestones)
Ease.OutCubic    → smooth, confident (screen transitions)
Ease.OutExpo     → fast-start, graceful-stop (score counter)
Ease.InOutSine   → breathing/looping motion (timers, shimmers)
Ease.OutQuad     → neutral utility (errors, dismissals)
```

### Anti-Patterns (never do these)

- **Looping ambient animations on main screens** — peripheral motion = distraction (NNGroup)
- **Animation blocking user input** — never lock UI waiting for an animation to complete
- **Same animation for correct AND wrong** — violates Von Restorff, trains users to ignore both
- **Duration > 600ms for feedback animations** — crosses from response into wait (Apple HIG)
- **Animating >3 elements simultaneously** — attentional competition (NNGroup: Hipmunk example)
- **Identical milestone animations** — kills anticipation (Goal-Gradient effect)

---

## Microinteraction Patterns (NNGroup framework)

> Every microinteraction = **Trigger → Feedback** pair.
> If there is no trigger, it is not a microinteraction (e.g. a static GIF is decoration, not UX).

### Must-Have Microinteractions for QuizVerse

| Trigger | Feedback | Priority |
|---------|----------|----------|
| Answer button tap | Scale-punch 0.92→1.05 + highlight ring | P0 |
| Correct answer | Green flash + checkmark scale-in + sound | P0 |
| Wrong answer | Red flash + horizontal shake (6px, 3 cycles) + sound | P0 |
| Timer reaching 5s | Color change (amber→red) + subtle pulse animation | P0 |
| Streak increment | Badge scale bounce + number morph tween | P0 |
| Session complete | Full-screen burst + score count-up | P1 |
| Daily goal met | Confetti + streak fire animation | P1 |
| Loading state | Skeleton shimmer (not spinner) | P1 |
| Achievement unlock | Slide-up toast + icon scale-in | P1 |
| Paywall close | Gentle slide-down (not abrupt pop) | P2 |

### Microinteraction Quality Checklist

- [ ] Feedback starts within 100ms of trigger
- [ ] Duration ≤ 400ms (unless it is a deliberate peak-moment reward)
- [ ] Sound paired with animation (not animation alone)
- [ ] Error states use distinct animation from success states
- [ ] Animation interruptible — user can tap through without waiting

---

## QuizVerse Screen-by-Screen UX Notes

### Splash / Loading
- Show app icon scale-in (300ms, `OutBack`) immediately — never blank screen
- Skeleton shimmer behind real content (not spinner)
- If load takes >1.5s: show progress bar (Doherty: "progress bars make waits tolerable")

### Home Screen
- Streak counter must be visible above fold → Zeigarnik hook
- Progress ring partially filled, not 0% → Goal-Gradient pull
- No looping ambient animations → peripheral distraction (Apple HIG)

### Quiz Screen
- 4 answer choices max (Miller's Law)
- Answer tap → immediate scale-punch before server response (optimistic UI)
- Correct: OutBack scale + green overlay (200ms)
- Wrong: shake + red overlay + correct answer revealed with fade-in (300ms)
- Timer: color-gradient transition from green → amber → red (not discrete steps)

### Recap / Results
- **This is the Peak-End screen** — highest UX investment priority
- Score count-up animation (800ms, `OutExpo`)
- Confetti burst for >70% correct (600ms, then dissipates — not looping)
- 3 stats visible (score, time, streak) — not 8 stats
- CTA must be prominent and single ("Play Again" / "Share") — Hick's Law

### Streak Screen
- Use escalating animation intensity at 3→5→7→10 (Goal-Gradient)
- Fire icon scale-bounce with `OutElastic` for milestone
- Show "2 away from a new record" — Zeigarnik incomplete-task pull

---

## Reference Files (load only if needed)

- Psychology laws deep-dive: `references/psychology-laws.md`
- Motion principles full spec: `references/motion-principles.md`
- Microinteraction catalog: `references/microinteractions.md`
- QuizVerse screen patterns: `references/quiz-patterns.md`
