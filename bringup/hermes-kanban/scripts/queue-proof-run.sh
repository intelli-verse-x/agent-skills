#!/usr/bin/env bash
# Proof-of-life: queue a Content Factory learning_series.yaml run through
# Hermes Kanban end-to-end so we can verify the wiring:
#
#   curriculum-planner   -> plans 3 episodes (parent task)
#   screenwriter         -> writes script per episode (3 child tasks)
#   media-producer       -> renders visuals per episode (3 grand-child tasks)
#   audio-director       -> tts + bg music per episode (3 grand-child tasks)
#   reviewer             -> QC gate, blocks on failure (3 grand-child tasks)
#
# If anything dies mid-run (Veo timeout, Beatoven 503, pipeline-worker pod
# restart), the dispatcher reclaims and retries from the failure point —
# this is the whole point of using Kanban over `python -m pipelines.cli`.

set -euo pipefail

BOARD="content-factory"
TOPIC="${1:-Newton's three laws of motion}"
EPISODE_COUNT="${2:-3}"
LOCALE="${3:-en-US}"

if ! command -v hermes >/dev/null 2>&1; then
  echo "ERROR: hermes CLI not on PATH" >&2
  exit 1
fi

if ! hermes kanban board list 2>/dev/null | grep -q "^${BOARD}\b"; then
  echo "ERROR: board '$BOARD' does not exist. Run ./scripts/create-boards.sh first." >&2
  exit 1
fi

CF_DIR="${IVX_CONTENT_FACTORY_DIR:-${HOME}/dev/content-factory}"
if [[ ! -f "${CF_DIR}/configs/pipelines/learning_series.yaml" ]]; then
  echo "ERROR: learning_series.yaml not found at ${CF_DIR}/configs/pipelines/" >&2
  echo "Set IVX_CONTENT_FACTORY_DIR to the content-factory checkout." >&2
  exit 1
fi

echo "Queueing learning_series proof run:"
echo "  board:         $BOARD"
echo "  topic:         $TOPIC"
echo "  episode_count: $EPISODE_COUNT"
echo "  locale:        $LOCALE"
echo "  CF dir:        $CF_DIR"
echo

PARENT_ID="$(hermes kanban add \
  --board "$BOARD" \
  --assignee curriculum-planner \
  --workspace "dir:${CF_DIR}" \
  --title "Learning Series: ${TOPIC} (${EPISODE_COUNT} eps, ${LOCALE})" \
  --body "$(cat <<EOF
PROOF-OF-LIFE RUN for the Hermes Kanban wiring.

Pipeline:    configs/pipelines/learning_series.yaml
Topic:       ${TOPIC}
Episodes:    ${EPISODE_COUNT}
Locale:      ${LOCALE}
Brand:       QuizVerse
Audience:    ages 10-14

Workflow:
1. Plan the ${EPISODE_COUNT} episodes (learning objectives + outline per episode).
2. For each episode, create child task assigned to 'screenwriter' to write script.
3. Each script child links a media-producer task (visuals) AND an
   audio-director task (TTS + music).
4. Each media task and audio task links a reviewer QC gate.
5. On all complete, post the final episode URLs + cost breakdown in a
   comment on this parent task.

Use the ivx-content-factory-pipeline skill for the trigger_learning_series
call shape.

DO NOT consume more than \$10 in model + media spend on this proof run.
If exceeded, kanban_block and wait for human review.
EOF
)" \
  --output-format json | python3 -c 'import sys,json; print(json.load(sys.stdin)["id"])')"

echo "Created parent kanban task: $PARENT_ID"
echo
echo "Watch live:"
echo "  hermes kanban tail --board $BOARD"
echo
echo "Inspect:"
echo "  hermes kanban show $PARENT_ID"
echo
echo "Cancel (if needed):"
echo "  hermes kanban block $PARENT_ID --reason 'aborting proof run'"
