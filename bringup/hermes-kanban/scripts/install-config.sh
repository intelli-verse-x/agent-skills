#!/usr/bin/env bash
# Merge bringup/hermes-kanban/config-fragment.yaml into ~/.hermes/config.yaml
# (or create it if absent). Idempotent: re-running is safe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAGMENT="${SCRIPT_DIR}/../config-fragment.yaml"
TARGET="${HERMES_HOME:-${HOME}/.hermes}/config.yaml"

if [[ ! -f "$FRAGMENT" ]]; then
  echo "ERROR: fragment not found at $FRAGMENT" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if [[ ! -f "$TARGET" ]]; then
  echo "Creating new $TARGET from fragment..."
  cp "$FRAGMENT" "$TARGET"
  echo "Done. Review $TARGET and run 'hermes setup' to add your model provider."
  exit 0
fi

BACKUP="${TARGET}.bak.$(date +%Y%m%d-%H%M%S)"
cp "$TARGET" "$BACKUP"
echo "Backed up existing config to $BACKUP"

# Use yq if available (clean merge); otherwise just append with a
# clear marker so the user can resolve by hand.
if command -v yq >/dev/null 2>&1; then
  yq eval-all 'select(fi==0) * select(fi==1)' "$TARGET" "$FRAGMENT" > "${TARGET}.merged"
  mv "${TARGET}.merged" "$TARGET"
  echo "Merged via yq."
else
  cat >> "$TARGET" <<'EOF'

# ─── intelli-verse-x bringup fragment (appended by install-config.sh) ───
# yq isn't installed — appended fragment verbatim. Resolve any duplicate
# top-level keys (mcp_servers, delegation, kanban) by hand.
EOF
  cat "$FRAGMENT" >> "$TARGET"
  echo "yq not found — appended fragment with a marker. Resolve duplicate top-level keys by hand."
fi

echo
echo "Next: ./scripts/create-boards.sh"
