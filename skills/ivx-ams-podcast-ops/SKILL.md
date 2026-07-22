---
name: ivx-ams-podcast-ops
description: >-
  Podcast-to-everything: one episode into clips, threads, LinkedIn, newsletter, quotes,
  SEO blogs, Shorts scripts with viral scoring. Use to repurpose podcasts or build podcast
  content calendars.
metadata:
  source: https://github.com/ericosiu/ai-marketing-skills
  upstream_dir: podcast-ops
  install: cursor-personal
---


## Working directory

```bash
cd ~/.cursor/skills/ams-podcast-ops
# Windows: cd $env:USERPROFILE\.cursor\skills\ams-podcast-ops
```
## Cursor install notes

- Skill root: this folder (scripts + references live here).
- Vendor source: `~/.cursor/skills/_vendor/ai-marketing-skills/` (git pull to update).
- Telemetry is optional; skip `telemetry/*.py` unless you opt in.
- Run Python from this skill directory so relative paths resolve.
- Prefer `python` on Windows if `python3` is missing.

## Step 1: Ingest — Get the Transcript

Determine the input source and obtain a clean transcript.

### Option A: RSS Feed (`--rss <url>`)
1. Fetch the RSS feed XML
2. Extract the latest episode's audio URL (or use `--episodes N` for batch)
3. Download the audio file
4. Transcribe via OpenAI Whisper API (with timestamps)
5. Store transcript with episode metadata (title, date, description, duration)

### Option B: Raw Transcript (`--transcript <file>`)
1. Read the transcript file (plain text, SRT, or VTT)
2. Parse timestamps if present
3. Extract episode metadata from filename or prompt user

### Option C: Batch Mode (`--batch <rss_url> --episodes N`)
1. Fetch RSS feed
2. Extract the last N episodes
3. Process each through the full pipeline
4. Deduplicate across all episodes in the batch

### Transcript cleanup
- Remove filler words (um, uh, like, you know) for written content
- Preserve original with timestamps for video clip suggestions
- Split into logical segments by topic shift

## Step 3: Content Generation — One Episode, Many Pieces

For each episode, generate ALL of these from the extracted atoms:

### 3a. Short-Form Video Clips (3-5 per episode)
```
- Hook: [First 3 seconds — pattern interrupt or bold claim]
- Clip segment: [Timestamp range from transcript]
- Caption overlay: [Text for the screen]
- Platform: [YouTube Shorts / TikTok / Instagram Reels]
- Why it works: [What makes this clippable]
```
Prioritize: controversial takes > stories with payoffs > surprising data points

### 3b. Twitter/X Threads (2-3 per episode)
```
- Thread hook (tweet 1): [Curiosity gap or bold opener]
- Thread body (5-10 tweets): [Each tweet is one complete thought]
- Thread closer: [CTA — follow, reply, retweet trigger]
- Source atoms: [Which content atoms feed this thread]
```
Rules: No tweet over 280 chars. Each tweet must stand alone. Use data points as proof.

### 3c. LinkedIn Article Draft (1 per episode)
```
- Headline: [Specific, benefit-driven]
- Hook paragraph: [Before the "see more" fold — must earn the click]
- Body: [3-5 sections with headers, 800-1200 words]
- CTA: [Engagement driver — question, not link]
- Hashtags: [3-5 relevant, not spammy]
```
Voice: Professional but not corporate. First-person. Story-driven.

### 3d. Newsletter Section (1 per episode)
```
- Section headline: [Scannable, specific]
- TL;DR: [One sentence, the core insight]
- Body: [3-5 bullet points, each with a takeaway]
- Pull quote: [The most shareable line from the episode]
- Link: [Back to full episode]
```

### 3e. Quote Cards (3-5 per episode)
```
- Quote text: [Max 20 words — must work as text overlay]
- Attribution: [Speaker name]
- Background suggestion: [Color/mood that matches the tone]
- Platform sizing: [1080x1080 for IG, 1200x675 for Twitter, 1080x1920 for Stories]
```

### 3f. Blog Post Outline (1 per episode)
```
- Title: [SEO-optimized, includes primary keyword]
- Primary keyword: [Search volume + difficulty estimate]
- Secondary keywords: [3-5 related terms]
- Meta description: [155 chars max]
- H2 sections: [5-7, each maps to a content atom]
- Internal linking opportunities: [Topics that connect to existing content]
- Estimated word count: [1500-2500]
```

### 3g. YouTube Shorts / TikTok Script (1 per episode)
```
- HOOK (0-3s): [Pattern interrupt — question, bold claim, or visual]
- SETUP (3-15s): [Context — why should they care]
- PAYOFF (15-45s): [The insight, data, or story resolution]
- CTA (45-60s): [Follow, comment prompt, or part 2 tease]
- On-screen text: [Key phrases to overlay]
- B-roll suggestions: [Visual ideas if not talking-head]
```

## Step 5: Dedup Engine

Before finalizing, check all generated content against:
1. **This batch** — No two pieces should cover the same angle
2. **Recent history** — Compare against last N days of output (default: 30)
3. **Similarity threshold** — Flag any pair with >70% semantic overlap

### Dedup rules:
- If two pieces overlap >70%: keep the higher-scored one, cut the other
- If a piece overlaps with recently published content: flag with ⚠️ and suggest a differentiation angle
- Track all published content hashes in `output/content_history.json`

## Step 7: Output

All output goes to `output/` directory:

```
output/
├── episodes/
│   ├── YYYY-MM-DD-episode-slug/
│   │   ├── transcript.txt
│   │   ├── atoms.json          # Extracted content atoms
│   │   ├── content_pieces.json # All generated content
│   │   └── calendar.json       # Scheduled calendar
│   └── ...
├── calendar/
│   └── week-YYYY-WNN.json     # Aggregated weekly calendar
├── content_history.json        # Dedup tracking
└── pipeline_log.json           # Run history and stats
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes (for Whisper) | OpenAI API key for audio transcription |
| `ANTHROPIC_API_KEY` | Yes (for generation) | Anthropic API key for content generation |
| `OPENAI_LLM_KEY` | Optional | Separate OpenAI key if using GPT for generation instead |

## Reference Files

| File | Purpose |
|------|---------|
| `podcast_pipeline.py` | Main pipeline script |
| `requirements.txt` | Python dependencies |
| `README.md` | Setup and usage guide |
