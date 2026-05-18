#!/usr/bin/env bash
# Create named worker profiles under ~/.hermes/profiles/<name>/.
# Each profile is a SOUL.md + a toolset config. The kanban dispatcher
# spawns workers using these profiles when a task's `assignee` matches.

set -euo pipefail

HERMES_HOME_DEFAULT="${HERMES_HOME:-${HOME}/.hermes}"
PROFILES_DIR="${HERMES_HOME_DEFAULT}/profiles"
mkdir -p "$PROFILES_DIR"

# Required: the root ~/.hermes/{config.yaml,.env,auth.json} must already
# be populated with a working model provider before workers are spawned.
# The kanban dispatcher launches each worker with HERMES_HOME=<profile dir>,
# so per-profile dirs need their own copies of these files — otherwise the
# worker's credential pool is empty and every model call 401s.
ROOT_AUTH="${HERMES_HOME_DEFAULT}/auth.json"
ROOT_ENV="${HERMES_HOME_DEFAULT}/.env"
ROOT_CFG="${HERMES_HOME_DEFAULT}/config.yaml"

write_profile() {
  local name="$1"
  local toolset="$2"
  local soul="$3"
  local dir="${PROFILES_DIR}/${name}"
  mkdir -p "$dir"
  cat > "$dir/SOUL.md" <<EOF
# $name

$soul
EOF
  cat > "$dir/profile.yaml" <<EOF
name: "$name"
toolsets:
$(echo "$toolset" | tr ',' '\n' | sed 's/^/  - /')
EOF
  # Seed the profile with the root's auth + env + config so the dispatched
  # worker inherits a working credential pool. Without this, every kanban
  # worker spawns with an empty auth.json and 401s on the first model call.
  # Idempotent: we overwrite auth.json + .env (they reflect current secrets)
  # but only seed config.yaml if the profile doesn't already have one (so
  # per-profile customization survives a re-run).
  if [[ -f "$ROOT_AUTH" ]]; then
    cp "$ROOT_AUTH" "$dir/auth.json"
  fi
  if [[ -f "$ROOT_ENV" ]]; then
    cp "$ROOT_ENV" "$dir/.env"
    chmod 600 "$dir/.env"
  fi
  if [[ -f "$ROOT_CFG" && ! -f "$dir/config.yaml" ]]; then
    cp "$ROOT_CFG" "$dir/config.yaml"
  fi
  echo "  ✓ $name (toolsets: $toolset)"
}

echo "Writing profiles to $PROFILES_DIR"

write_profile "coder" \
  "terminal,file,git,content-factory,firecrawl,gastown" \
  "You are a coder polecat in the intelli-verse-x swarm. You implement bd tasks in their own worktree, run the test suite, commit with conventional-commit messages, and open PRs. You DO NOT push to main directly. You DO NOT touch secrets — secrets live in content-factory-secrets / hermes config / env vars."

write_profile "reviewer" \
  "terminal,file,content-factory,gastown" \
  "You are a reviewer polecat. You read code diffs and CF pipeline outputs and assess them against the quality.py rubrics. You comment on the kanban task with PASS/FAIL plus reasoning. On FAIL you kanban_block with specific actionable notes; on PASS you kanban_complete."

write_profile "researcher" \
  "web,firecrawl,content-factory" \
  "You are a researcher polecat. You use firecrawl (NEVER the built-in web tools) to scrape, search, map, and crawl. You return structured summaries with citations. You DO NOT make changes to code or trigger pipelines without an explicit task instruction."

write_profile "screenwriter" \
  "content-factory,firecrawl" \
  "You are a screenwriter polecat. You write scripts for Content Factory series and trailer pipelines. You pull research via firecrawl when asked for fact-grounded content. Output JSON conforming to the pipeline's expected script schema."

write_profile "media-producer" \
  "content-factory-media,content-factory" \
  "You are a media-producer polecat. You call generate_image / generate_video / generate_tts / generate_music / generate_motion to render the artefacts the parent task needs. You monitor task status and re-render slot-by-slot when QC fails individual shots."

write_profile "audio-director" \
  "content-factory-media,content-factory" \
  "You are an audio-director polecat. You compose music + voiceover direction for trailers and series. You consult the brand_context for voice + tone consistency across episodes."

write_profile "trailer-director" \
  "content-factory,firecrawl,content-factory-media" \
  "You are a trailer-director polecat. You orchestrate the multi-stage trailer factory: research → storyboard → animatic → audio → final → QC. You create the child kanban tasks (one per stage) and link them. You DO NOT do the work yourself — you decompose and dispatch."

write_profile "curriculum-planner" \
  "content-factory,firecrawl" \
  "You are a curriculum-planner polecat. You plan learning series: episode breakdown, learning objectives per episode, prerequisite chain. You use firecrawl to pull source material from textbooks, papers, Wikipedia, MDN, when needed. Output a child task per episode linked to the parent series task."

echo
echo "Profiles written."
echo "Next: ./scripts/queue-proof-run.sh"
