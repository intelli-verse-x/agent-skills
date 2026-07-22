# QuizVerse UX Patterns
> Research-backed screen-by-screen UX decisions for the QuizVerse Unity app.
> Source: synthesized from UX psychology research + QuizVerse codebase context.
> Last updated: 2026-06

---

## Design Constraints (always apply)

| Constraint | Rule |
|-----------|------|
| Platform | Android + iOS + WebGL — touch-first, mouse-compatible |
| Min touch target | 44×44pt (Apple HIG), 48×48dp (Material) |
| Orientation | Portrait-only (quiz context) |
| Safe area | All root panels apply `Screen.safeArea` insets |
| Text | TMP Auto Size, min 12, max 36, 1.5× line height |
| Spacing grid | 8dp base unit |
| Corner radius | 16dp cards, 8dp small chips, 24dp bottom sheets |

---

## Screen: Splash / Loading

### Psychology: Doherty Threshold + Aesthetic-Usability Effect
Users judge app quality in the first 3 seconds. A blank screen for even 500ms
creates a negative impression that aesthetics cannot fully recover.

### Pattern
1. App icon scale-in (300ms, `OutBack`) begins at frame 1 — never blank
2. Background fades in (200ms) simultaneously
3. If load < 1s: brief logo hold then auto-transition
4. If load 1–3s: progress bar appears after 800ms (Doherty: "progress bars make waits tolerable")
5. If load > 3s: skeleton screens for the first real content load

### Anti-patterns to avoid
- Spinning progress indicator as the only element → signals unpredictable wait
- "Loading…" text with no progress indicator → users check if the app is frozen

---

## Screen: Home

### Psychology: Zeigarnik Effect + Goal-Gradient Effect + Peak-End Rule

### Pattern
1. **Hero area:** Daily streak counter, prominently above fold
   - Streak number with fire icon (scale-bounce on first appear, `OutElastic`, 300ms)
   - "Day X" label — always partially "incomplete" framing until goal met
2. **Progress ring:** Partially filled daily goal ring — NEVER show at 0%
   - Even a new user starts at "artifically" 10% (endowed progress)
3. **Category tiles:** Max 6 visible without scroll (Hick's Law)
   - Each tile shows category progress arc (goal-gradient pull)
4. **No looping ambient animations** (NNGroup peripheral distraction)
5. **CTA hierarchy:** One primary action above fold (e.g. "Continue Daily Quiz")

### Common mistake
- Showing 8 equal-weight categories with no visual differentiation
  → Apply Von Restorff: one highlighted "Today's Featured" category

---

## Screen: Category / Mode Select

### Psychology: Hick's Law + Miller's Law

### Pattern
1. Max 3 modes visible at top level (Daily, Arcade, Multiplayer)
2. Category grid: 6 tiles max without scroll; 2-column on portrait mobile
3. Pre-selected/highlighted default: the most-recently-played or "Daily Quiz"
4. Progress indicated on each tile (Zeigarnik: partial progress creates pull)

---

## Screen: Quiz (Core Game Loop)

### Psychology: Flow State + Selective Attention + Von Restorff + Doherty

### Layout Rules
- Question text: centered, TMP Auto Size, min 18pt
- Answer choices: 4 max, full-width touch targets (min 56dp height)
- Timer: always visible top-right, NOT hidden behind progress
- Score/streak: visible but non-central (below question, above answers)

### Interaction Flow (per question)

```
User taps answer (MI-01: 80ms scale-punch — optimistic, before server)
         ↓
Server confirms OR local evaluation
         ↓
  CORRECT?                          WRONG?
  ↓                                 ↓
Green flash + checkmark (MI-02)    Red flash + shake (MI-03)
200ms hold on answer               300ms hold — show correct answer in green
Streak increments (MI-05)          Streak resets (if applicable)
800ms total before next question   1000ms total before next question (longer: recovery time)
```

### Zero ambient animation rule
- Background must be static during active quiz
- Score/XP display: update in-place, no attention-grabbing animation (Selective Attention)
- Only animate what the user just interacted with

### Timer visual states
```
> 10s  → Green (calm)
5–10s  → Amber (alert, color transition 500ms InOutSine)
< 5s   → Red + pulse (urgent, 500ms loop InOutSine)
0s     → Red flash + timeout feedback (same style as wrong answer)
```

---

## Screen: Streak Milestone (Interstitial)

### Psychology: Peak-End Rule + Von Restorff + Goal-Gradient

### When to show
- Streak reaches 3, 5, 7, 10, 15, 20… (escalating thresholds)
- Daily goal completed
- New personal record

### Animation escalation by milestone
| Milestone | Animation Style | Duration |
|-----------|----------------|----------|
| Streak 3 | Badge scale bounce | 300ms |
| Streak 5 | Streak fire animation | 400ms |
| Streak 7 | Fire + confetti burst (small) | 600ms |
| Streak 10 | Full screen confetti + fanfare | 800ms |
| New record | Gold flash + scale + "New Record" badge | 500ms |

**Rule:** Never use the same animation twice in a row. Escalating novelty maintains excitement.

### Dismiss behavior
- Auto-dismiss after 2.5s OR tap to dismiss
- Always has a forward CTA ("Keep going!" / "Epic streak!")
- Must feel fast — users want to continue playing, not watch effects

---

## Screen: Session Recap / Results

### Psychology: Peak-End Rule (HIGHEST PRIORITY SCREEN) + Aesthetic-Usability

This is the screen users remember. It determines whether they return tomorrow.

### Layout
```
[Confetti burst — begins immediately, non-blocking]

[Score hero: large, animated count-up 900ms OutExpo]

[3 stat tiles: Accuracy | Best Streak | Time]
  → Never more than 3 primary stats (Miller's Law)

[Subtle level-up or XP bar fill if applicable]

[Social share button — small, secondary]

[Primary CTA: "Play Again" (OR "Continue" to next difficulty)]
[Secondary CTA: "Home"]
```

### Animations sequence
1. Screen slide in (300ms, OutCubic)
2. Confetti burst starts at 300ms after screen appear (not blocking)
3. Score count-up at 600ms after screen appear (staggered to feel deliberate)
4. Stat tiles fade-stagger in: 800ms, 900ms, 1000ms (not all at once)
5. CTA button scale-in at 1200ms

### Common mistakes
- Showing 8 stats → cognitive overload (Miller's Law violated)
- Making confetti loop → peripheral distraction after 2s
- CTA only appearing after full animation completes → Doherty violation

---

## Screen: Paywall / Subscription

### Psychology: Hick's Law + Peak-End Rule + Aesthetic-Usability

### Pattern
1. Single hero plan highlighted (Annual) — Visual differentiation (Von Restorff)
2. 2 tiers max visible (Monthly + Annual) — Hick's Law
3. Benefits list: 3 items max in hero view — Miller's Law
4. Dismiss: gentle slide-down (OutCubic, 250ms) — never abrupt pop
5. Never show paywall mid-streak — always at a natural break (Flow State preservation)

### Never
- Countdown timer with false urgency (dark pattern — NNGroup)
- 5 equal-weight subscription options
- Showing paywall after a wrong answer (emotional exploitation)

---

## Screen: Profile / Settings

### Psychology: Chunking + Miller's Law

### Pattern
1. Group settings into ≤5 sections
2. Each section: ≤7 items before requiring a sub-screen
3. Destructive actions (reset progress, delete account): at bottom, red, with hold-to-confirm
4. Settings that affect game feel (sound, haptics): show micro-preview on toggle

---

## Notification Timing (Zeigarnik + Doherty)

| Type | Best Time | Psychology Basis |
|------|-----------|-----------------|
| Daily streak reminder | 30min before daily reset | Zeigarnik: task-incomplete tension |
| Achievement unlock | Immediately on unlock | Doherty: immediate feedback |
| Competitor beat on leaderboard | Within 60s | Doherty: immediacy of social feedback |
| Weekly recap push | Sunday 18:00 local | Peak-End: end of week = memorable moment |

---

## Dark Patterns to Never Implement

These patterns are explicitly called out in NNGroup and Laws of UX research as unethical:

| Pattern | Why It's Bad | QuizVerse Specific Risk |
|---------|-------------|------------------------|
| Flashing countdown timer | Creates artificial urgency via loss-aversion (NNGroup) | Subscription page |
| Preventing exit until animation completes | Violates user control (Apple HIG) | Celebratory overlays |
| Same animation for both correct/wrong | Users stop responding to feedback (Von Restorff) | Quiz answer reveals |
| Looping confetti after completion | Peripheral distraction disrupts next action | Recap screen |
| Paywall mid-streak | Breaks flow state (Csikszentmihalyi), associates product with frustration | Quiz interruptions |
| Hiding the dismiss button for 5s | Dark pattern — punishes user for saying no | Paywall |

---

## Accessibility Checklist (per screen)

- [ ] All feedback has a non-visual equivalent (sound OR haptic OR text)
- [ ] Color is not the only differentiator (correct/wrong: color + shape + animation)
- [ ] All animations respect system "Reduce Motion" if supported
- [ ] All interactive elements ≥ 44×44pt touch target
- [ ] Timer communicates via text ("5s") not only via color
- [ ] Achievement notifications accessible via VoiceOver/TalkBack

---

## Sources
- lawsofux.com (Jon Yablonski)
- NNGroup: nngroup.com/articles/animation-purpose-ux, nngroup.com/articles/microinteractions
- Apple HIG: developer.apple.com/design/human-interface-guidelines (2025)
- 60fps.design (2024–2026)
- QuizVerse codebase context (UIScreen.cs, UIFlowController.cs, UIAnimationPresets.cs)
