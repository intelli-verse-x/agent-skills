---
name: ivx-ams-x-longform-post
description: >-
  Write long-form X posts/threads with founder voice and a 24-pattern AI slop humanizer.
  Use for X articles, thought leadership threads, or viral founder posts.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: x-longform-post
  install: cursor-personal
---

## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

# X Long-Form Post Writer

## Working directory

```bash
cd ~/.cursor/skills/ams-x-longform-post
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-x-longform-post
```

Write posts for X in your founder/CEO's authentic voice. Every post should feel like a real person wrote it — not a content team, not a bot.

See `references/founder-voice.md` for the founder voice template. Customize it with your founder's real patterns.

## Structure

1. **Hook** (1-2 lines) — Contrarian claim or surprising stat
2. **Setup** (2-3 lines) — Establish credibility/context fast
3. **Sections** — Each follows: problem → what actually happened → fix/lesson
4. **ASCII diagram** — At least one per post (see below)
5. **Uncomfortable truth** — The insight most people avoid
6. **Payoff** — Was it worth it? Yes, and here's why.

## Formatting for X

- X articles support markdown-like formatting in long posts
- Use code blocks (```) for ASCII art — they render in monospace on X
- Bold with asterisks where supported
- Keep paragraphs to 1-3 sentences max
- Line breaks between every thought

## Analytics Feedback Loop

If X/Twitter analytics are available, use them before drafting and after publishing.

Before drafting:
- Pull recent post performance for similar topics and formats.
- Compare impressions, engagement rate, replies, reposts, bookmarks, profile clicks, follower delta, post length, hook style, proof number, CTA type, and topic bucket.
- Prefer hooks and structures that have actually worked. Do not worship cleverness. Cleverness without distribution is theater with better fonts.

After publishing:
1. Log post URL/id, publish time, hook, title, proof number, structure, CTA, and topic bucket.
2. Pull analytics after the readback window.
3. Compare against a baseline cohort of similar posts.
4. Patch the title formulas, hook patterns, CTA rules, or section structure only if the candidate beats baseline or produces a clearly better audience signal.

Judgment metrics:
- impressions
- engagement rate
- replies
- reposts
- bookmarks
- profile clicks
- follower delta
- quality of replies

Every promoted format change should include a baseline window, candidate window, metric winner, caveats, and rollback rule.

## Output

Deliver the complete post ready to paste into X. No preamble, no "here's your post" — just the post itself.

If the post would work better as a thread (>1500 chars), split into numbered tweets with each one standalone valuable.

## Humanizer Checklist (MANDATORY — Run Before Finalizing)

Before returning any X article draft, check against ALL 24 humanizer patterns. If any pattern is detected, rewrite that section.

For the full humanizer expert scoring rubric, see: `../content-ops/experts/humanizer.md`

### CRITICAL: No "Not X, It's Y" Constructions
Never write "This is not X. This is Y." or "That is not X, that is Y." or any variant. These are the #1 AI slop tell. Say what something IS directly. Don't define by negation.

### Banned Vocabulary (never use these)
delve, tapestry, landscape (abstract), leverage, multifaceted, nuanced, pivotal, realm, robust, seamless, testament, transformative, underscore (verb), utilize, whilst, keen, embark, comprehensive, intricate, commendable, meticulous, paramount, groundbreaking, innovative, cutting-edge, synergy, holistic, paradigm, ecosystem, Additionally, crucial, enduring, enhance, fostering, garner, highlight (verb), interplay, intricacies, showcase, vibrant, valuable, profound, renowned, breathtaking, nestled, stunning

### Pattern Checklist
1. ☐ No significance inflation ("pivotal moment", "stands as", "is a testament")
2. ☐ No undue notability claims (listing media mentions without context)
3. ☐ No superficial -ing phrases ("highlighting", "showcasing", "underscoring")
4. ☐ No promotional language ("boasts", "vibrant", "profound", "commitment to")
5. ☐ No vague attributions ("Experts believe", "Industry reports suggest")
6. ☐ No formulaic "despite challenges... continues to" structures
7. ☐ No AI vocabulary clustering (multiple banned words in one paragraph)
8. ☐ No copula avoidance ("serves as", "stands as" — just use "is")
9. ☐ No negative parallelisms ("It's not just X, it's Y")
10. ☐ No rule-of-three forcing (triple adjectives, triple parallel clauses)
11. ☐ No synonym cycling (varying terms for the same thing unnecessarily)
12. ☐ No false ranges ("from X to Y" on no meaningful scale)
13. ☐ No em dash overuse (max 1 per 200 words)
14. ☐ No mechanical boldface emphasis
15. ☐ No inline-header vertical lists (bolded label + colon pattern)
16. ☐ No Title Case In Every Heading
17. ☐ No emoji decoration on headings/bullets
18. ☐ No curly quotation marks
19. ☐ No collaborative artifacts ("I hope this helps", "Let me know")
20. ☐ No knowledge-cutoff disclaimers
21. ☐ No sycophantic tone ("Great question!")
22. ☐ No filler phrases ("In order to", "It is important to note")
23. ☐ No excessive hedging ("could potentially", "might have some effect")
24. ☐ No generic positive conclusions ("The future looks bright", "Exciting times ahead")

### Humanizer Scoring

Start at 100. Deduct points per the rubric in `../content-ops/experts/humanizer.md`.

- **90-100**: Human-sounding. Clean. Ship it.
- **70-89**: Minor AI tells. Quick fixes needed.
- **50-69**: Obvious AI patterns. Significant rewrite needed.
- **0-49**: Full rewrite.
