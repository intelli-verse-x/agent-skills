#!/usr/bin/env bash
# Create one Hermes Kanban board per intelli-verse-x fork.
# Idempotent: `hermes kanban board create` no-ops if the board exists.

set -euo pipefail

BOARDS=(
  "gastown"           # intelli-verse-x/gastown
  "hermes-agent"      # intelli-verse-x/hermes-agent
  "content-factory"   # intelli-verse-x/content-factory
  "kube-infra"        # intelli-verse-x/intelli-verse-kube-infra
  "games-platform"    # intelli-verse-x/intelliverse-x-games-platform-2
  "sdks"              # umbrella for all Intelli-verse-X-* SDK forks (tenant per repo)
)

if ! command -v hermes >/dev/null 2>&1; then
  echo "ERROR: hermes CLI not on PATH. Install with:" >&2
  echo "  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash" >&2
  exit 1
fi

for board in "${BOARDS[@]}"; do
  echo "→ board: $board"
  # Idempotent: bail if it already exists, otherwise create.
  if hermes kanban boards list 2>/dev/null | awk '{print $1}' | grep -qx "$board"; then
    echo "    already exists"
  else
    hermes kanban boards create "$board" 2>&1 | sed 's/^/    /' || true
  fi
done

echo
echo "Existing boards:"
hermes kanban boards list 2>&1 | sed 's/^/    /'

echo
echo "Next: ./scripts/create-profiles.sh"
