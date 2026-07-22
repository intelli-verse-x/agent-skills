# Psychology Laws Reference
> Source: lawsofux.com (Jon Yablonski) + Kahneman et al. + NNGroup
> Scraped: 2026-06

---

## Doherty Threshold
**Law:** Productivity soars when computer and user interact at a pace < 400ms.
**Origin:** Doherty & Thadani, IBM Systems Journal (1982) — replaced the prior 2-second standard.

**Design rules:**
1. Feedback within 400ms to keep attention; under 100ms to feel "instant"
2. Use optimistic UI (show result before server confirms) when safe
3. If real processing > 400ms → start a skeleton/shimmer immediately
4. Progress bars make wait times tolerable regardless of accuracy
5. Strategically adding a short artificial delay (e.g. 300ms) can *increase* perceived quality and trust (the "effort heuristic")

**QuizVerse specifics:**
- Answer button: visual response ≤ 100ms (scale-punch before server round-trip)
- Result reveal: ≤ 300ms after server response
- Screen transitions: ≤ 150ms to begin

---

## Peak-End Rule
**Law:** People judge an experience by how they felt at the most intense point and at the end — not the average.
**Origin:** Kahneman, Fredrickson, Schreiber, Redelmeier (1993) — cold-water immersion study.

**Design rules:**
1. Identify your peak moments and design them to delight
2. Identify your ending moments (recap, session complete) — these anchor memory
3. Negative peaks are remembered more vividly than positive → protect against bad endings
4. Recovery from a negative peak matters: bounce back fast

**QuizVerse specifics:**
- Peak (positive): streak milestone hit, perfect score, daily goal reached
- Peak (negative): losing a streak, time running out on last question
- End: Recap screen is the single most important screen for next-day retention
- Never end on an error state — always offer a forward hook ("Try again", "Share score")

---

## Zeigarnik Effect
**Law:** People remember uncompleted or interrupted tasks 2× better than completed ones.
**Origin:** Bluma Zeigarnik (1920s) — Berlin School of experimental psychology.

**Design rules:**
1. Show partial progress on home screen — never 0%, never 100% unless celebrating
2. Artificial progress (endowed progress) motivates completion
3. "2 away from a record" > "You need 2 more" — frame as closeness to goal

**QuizVerse specifics:**
- Daily streak badge: "2 of 3 days complete" always visible
- Category progress rings: partially filled, not empty
- Question counter during quiz: "Question 4 of 10" — not hidden
- Achievement tease: show locked achievements with progress bar

---

## Goal-Gradient Effect
**Law:** Effort and motivation increase as people approach a goal.
**Origin:** Clark L. Hull (1932) — rat maze experiments; extended to consumer behavior by Nunes & Drèze (2006).

**Design rules:**
1. Accelerate animation/feedback near goal completion
2. Increase reinforcement frequency near finish line (last 20% of progress)
3. Use endowed progress — start users at 10–20% rather than 0%

**QuizVerse specifics:**
- Progress bar: ease-in near 100% (visually speeds up)
- Final question in quiz: more dramatic reveal than middle questions
- Streak near a milestone (e.g. 9/10): show "One away!" callout

---

## Aesthetic-Usability Effect
**Law:** Aesthetically pleasing design is perceived as more usable, even when functionality is identical.
**Origin:** Kurosu & Kashimura, Hitachi Design Center (1995) — 26 ATM UI variants, 252 participants.

**Design rules:**
1. Polish the top 3 highest-traffic screens first
2. Visual consistency (shadow depth, corner radius, spacing) signals reliability
3. Small motion details reduce perceived task difficulty
4. Caution: aesthetic appeal can mask usability problems during testing

**QuizVerse specifics:**
- Quiz, Home, Recap are the priority polish screens
- Consistent 16dp corner radius, 8dp spacing grid
- Micro-bounce on correct answer makes questions feel "easier to answer correctly"

---

## Von Restorff Effect (Isolation Effect)
**Law:** When multiple similar objects are present, the one that differs most is remembered.
**Origin:** Hedwig von Restorff (1933) — memory study on isolated items.

**Design rules:**
1. Use distinct visual treatment for the most important element on each screen
2. Never reuse the "correct" animation style for "wrong" — they must be clearly different
3. Milestone animations must be escalating and distinct — same animation every time = invisible

**QuizVerse specifics:**
- Correct: scale-up + green glow (unique to correct state)
- Wrong: lateral shake + red overlay (unique to wrong state)
- Streak 3: basic bounce; Streak 5: fire animation; Streak 7: full burst — never repeat style

---

## Miller's Law
**Law:** The average person can hold 7 (±2) items in working memory.
**Origin:** George A. Miller, "The Magical Number Seven" (1956).

**Design rules:**
1. Group information into chunks of 4–5 items max for scannability
2. Quiz answers: 4 choices optimal, never 6+
3. Settings: max 5 groups before needing a sub-section
4. Recap stats: 3 hero numbers visible; secondary stats behind a "details" toggle

**QuizVerse specifics:**
- 4 answer choices is the validated optimal for mobile quiz format
- Recap: Score, Streak, Accuracy as the 3 hero stats

---

## Hick's Law
**Law:** Decision time grows logarithmically with the number and complexity of choices.
**Origin:** William Edmund Hick (1952); extended by Ray Hyman (1953).

**Design rules:**
1. Reduce choices at decision points; highlight the recommended option
2. Progressive disclosure: reveal options only when needed
3. Paywall: "Best Value" should be pre-highlighted; don't show 5 equal tiers

**QuizVerse specifics:**
- Mode select: 2–3 visible modes max (Daily, Arcade, Multiplayer)
- Category grid: 6 tiles visible, rest behind scroll
- Subscription tiers: 2 tiers (Monthly + Annual), Annual pre-highlighted

---

## Flow State (Csikszentmihalyi)
**Law:** Flow = deep engagement achieved when challenge matches skill level.
**Origin:** Mihaly Csikszentmihalyi, "Beyond Boredom and Anxiety" (1975).

**Design rules:**
1. Difficulty curve must be gradual — not flat and not spiky
2. Interruptions (ads, modals, notifications) break flow state and increase churn
3. Clear goals + immediate feedback = prerequisites for flow

**QuizVerse specifics:**
- Never show a paywall mid-streak — wait until a natural break (end of session)
- Timer feedback must be real-time and visible (not hidden)
- Difficulty progression: questions should get moderately harder over a session

---

## Serial Position Effect
**Law:** Users best remember the first and last items in a series.
**Origin:** Ebbinghaus (1913); Murdock (1962).

**Design rules:**
1. Most important information in first and last positions
2. Forgettable middle can hold secondary info
3. Apply to answer option ordering: don't always put the correct answer in position 2

**QuizVerse specifics:**
- Recap screen: strongest stat first, improvement hook last
- Achievement list: most recent first, oldest last
- Quiz question options: rotate correct answer position

---

## Parkinson's Law
**Law:** Work expands to fill the time available for its completion.
**Origin:** C. Northcote Parkinson, "Parkinson's Law" (1955).

**Design rules:**
1. Time-boxed tasks (quiz timers) create urgency and prevent overthinking
2. Countdown timers reduce decision paralysis
3. Without a timer, users over-analyze easy questions

**QuizVerse specifics:**
- Timer per question is a core mechanic — never remove it from scored modes
- Timer visual feedback (color change, pulse) reinforces time pressure

---

## Selective Attention
**Law:** People focus on a subset of stimuli related to their current goal; everything else is filtered.
**Origin:** Cherry (1953) "cocktail party effect"; Treisman (1960).

**Design rules:**
1. Motion outside the task focus area = distraction (NNGroup: rod-cell motion detection)
2. Only animate within the user's likely attention zone
3. Peripheral animations destroy concentration — avoid on the quiz screen

**QuizVerse specifics:**
- Quiz screen: ZERO ambient/looping animations (background, decorative elements)
- Feedback animations must be centered on the tapped answer — not on a corner of the screen
- Score update: subtle, non-peripheral

---

## Sources
- lawsofux.com (Jon Yablonski)
- Nielsen Norman Group: nngroup.com
- Wikipedia (original paper citations above)
- Kahneman, D. (2011). Thinking, Fast and Slow.
- Csikszentmihalyi, M. (1990). Flow: The Psychology of Optimal Experience.
