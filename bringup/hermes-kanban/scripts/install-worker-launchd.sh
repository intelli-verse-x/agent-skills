#!/usr/bin/env bash
# install-worker-launchd.sh — install a STANDALONE Hermes Kanban dispatch
# daemon as a launchd service.
#
# READ THIS FIRST: In recent hermes-agent (>= 0.13.x), the gateway
# already runs an embedded kanban dispatcher when `kanban.dispatch_in_gateway`
# is true in ~/.hermes/config.yaml (which is the default). If you have
# `hermes gateway install`-ed the gateway (label: ai.hermes.gateway),
# you almost certainly DO NOT need this standalone daemon — it would
# race the gateway's embedded dispatcher for card claims.
#
# This script intentionally REFUSES TO INSTALL when it detects that
# situation. Use --force only when you have a real reason (e.g. you
# disabled the embedded dispatcher, or you're running on a box without
# the gateway).
#
# Common reasons to use --force:
#   * You set `kanban.dispatch_in_gateway: false` because you want the
#     dispatcher on a separate process for resource isolation / debugging.
#   * You're running on a headless box without the GUI gateway.
#   * You want a higher per-tick spawn cap than the gateway provides.
#
# Usage:
#   ./install-worker-launchd.sh                # check + install (refuses if gateway running)
#   ./install-worker-launchd.sh --force        # install anyway
#   ./install-worker-launchd.sh --uninstall    # bootout + remove plist

set -euo pipefail

LABEL="ai.hermes.kanban-daemon"
HERMES_HOME_DEFAULT="${HERMES_HOME:-${HOME}/.hermes}"
PLIST_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${PLIST_DIR}/${LABEL}.plist"
LOG_DIR="${HERMES_HOME_DEFAULT}/logs"

INTERVAL_SECONDS="${HERMES_KANBAN_INTERVAL:-60}"
MAX_SPAWNS_PER_TICK="${HERMES_KANBAN_MAX_SPAWNS:-4}"
DEFAULT_BOARD="${HERMES_KANBAN_BOARD:-content-factory}"

FORCE=0
ACTION="install"
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --uninstall) ACTION="uninstall" ;;
        -h|--help)
            sed -n '2,30p' "$0"
            exit 0
            ;;
        *) ;;
    esac
done

log() { printf '[install-worker-launchd] %s\n' "$*"; }
die() { printf '[install-worker-launchd] FATAL: %s\n' "$*" >&2; exit 1; }

# ---------- uninstall ----------
if [[ "$ACTION" == "uninstall" ]]; then
    if [[ -f "$PLIST_PATH" ]]; then
        log "bootout ${LABEL}"
        launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
        rm -f "$PLIST_PATH"
        log "uninstalled"
    else
        log "(no plist at $PLIST_PATH — nothing to do)"
    fi
    exit 0
fi

# ---------- guardrail: gateway already dispatches ----------
# If the gateway is running (it normally is — installed via `hermes
# gateway install`), and the in-cluster config has dispatch enabled,
# then this standalone daemon would race for kanban claims. Bail out
# clearly unless --force.
guardrail_gateway_dispatch() {
    [[ "$FORCE" == "1" ]] && return 0

    local gateway_running=0
    if launchctl list ai.hermes.gateway >/dev/null 2>&1; then
        gateway_running=1
    fi

    local embedded_dispatch=0
    # Read the live config — `kanban.dispatch_in_gateway` defaults to
    # true if absent, so we treat both "true" and "missing" as enabled.
    if [[ -f "${HERMES_HOME_DEFAULT}/config.yaml" ]]; then
        local val
        val="$(awk '/^kanban:/{f=1;next} f && /^[a-z]/{f=0} f && /dispatch_in_gateway:/{print $2; exit}' \
              "${HERMES_HOME_DEFAULT}/config.yaml" 2>/dev/null)"
        if [[ -z "$val" || "$val" == "true" ]]; then
            embedded_dispatch=1
        fi
    else
        # No config = hermes defaults, which means embedded dispatcher is on.
        embedded_dispatch=1
    fi

    if [[ "$gateway_running" == "1" && "$embedded_dispatch" == "1" ]]; then
        cat >&2 <<EOF
[install-worker-launchd] REFUSING TO INSTALL.

  The Hermes gateway is already running as a launchd service
  (label: ai.hermes.gateway) AND it has the embedded kanban
  dispatcher enabled (kanban.dispatch_in_gateway = true, or
  default).

  Installing this standalone daemon would create TWO dispatchers
  racing each other for kanban card claims. That's not the gap you
  thought it was — cards posted by 'hermes cron' or webhook ARE
  picked up automatically by the gateway every
  kanban.dispatch_interval_seconds (default 30s).

  Verify with:
    tail -F ~/.hermes/logs/gateway.log | grep dispatcher

  If you're seeing 'kanban dispatcher: embedded in gateway' there,
  you're already hands-off — no further install needed.

  Real reasons to use --force:
    * You set kanban.dispatch_in_gateway: false on purpose.
    * You're on a headless box where the gateway isn't installed.
    * You want a higher --max spawn cap than the gateway's default.

  To force anyway:
    $0 --force
EOF
        exit 2
    fi
}

guardrail_gateway_dispatch

# ---------- preflight ----------
HERMES_BIN="$(command -v hermes || true)"
[[ -z "$HERMES_BIN" ]] && die "hermes CLI not on PATH — install hermes-agent first"

VENV_PY="${HERMES_HOME_DEFAULT}/hermes-agent/venv/bin/python"
if [[ ! -x "$VENV_PY" ]]; then
    VENV_PY="$(head -1 "$HERMES_BIN" | sed 's|^#!||')"
    [[ -x "$VENV_PY" ]] || die "could not resolve hermes python interpreter (looked at venv + shebang)"
    log "WARN: ${HERMES_HOME_DEFAULT}/hermes-agent/venv/bin/python missing; using $VENV_PY from hermes shebang"
fi

HERMES_AGENT_DIR="${HERMES_HOME_DEFAULT}/hermes-agent"
[[ -d "$HERMES_AGENT_DIR" ]] || die "expected hermes source at $HERMES_AGENT_DIR — re-run hermes postinstall?"

"$HERMES_BIN" kanban daemon --help >/dev/null 2>&1 \
    || die "hermes kanban daemon not available in $($HERMES_BIN --version 2>&1 | head -1) — upgrade hermes-agent"

# ---------- render plist ----------
mkdir -p "$PLIST_DIR" "$LOG_DIR"
LIVE_PATH="${PATH}"

cat > "$PLIST_PATH" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>

    <!--
      Standalone kanban dispatcher. Loops 'hermes kanban dispatch' every
      INTERVAL seconds, spawning up to MAX worker subprocesses per tick.
      Each subprocess claims one kanban card and runs the skill named
      in the card's assignee profile, then exits.

      Use ONLY when the gateway's embedded dispatcher is disabled or
      absent. See header of install-worker-launchd.sh for the rationale.
    -->
    <key>ProgramArguments</key>
    <array>
        <string>${VENV_PY}</string>
        <string>-m</string>
        <string>hermes_cli.main</string>
        <string>kanban</string>
        <string>daemon</string>
        <string>--interval</string>
        <string>${INTERVAL_SECONDS}</string>
        <string>--max</string>
        <string>${MAX_SPAWNS_PER_TICK}</string>
        <string>--verbose</string>
    </array>

    <key>WorkingDirectory</key>
    <string>${HERMES_AGENT_DIR}</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${LIVE_PATH}</string>
        <key>VIRTUAL_ENV</key>
        <string>${HERMES_HOME_DEFAULT}/hermes-agent/venv</string>
        <key>HERMES_HOME</key>
        <string>${HERMES_HOME_DEFAULT}</string>
        <key>HERMES_KANBAN_BOARD</key>
        <string>${DEFAULT_BOARD}</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>

    <key>ThrottleInterval</key>
    <integer>30</integer>

    <key>StandardOutPath</key>
    <string>${LOG_DIR}/kanban-daemon.log</string>

    <key>StandardErrorPath</key>
    <string>${LOG_DIR}/kanban-daemon.error.log</string>

    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
</dict>
</plist>
XML

log "wrote ${PLIST_PATH}"

# ---------- bootstrap ----------
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl enable "gui/$(id -u)/${LABEL}"

log "bootstrapped — service is registered"

sleep 1
PID="$(launchctl list "$LABEL" 2>/dev/null | awk -F'"' '/PID/ {print $2}' | head -1)"
if [[ -n "$PID" && "$PID" != "0" ]]; then
    log "RUNNING — pid=${PID}"
else
    log "WARN: not yet showing a PID. Check ${LOG_DIR}/kanban-daemon.error.log if it stays empty."
fi

cat <<EOF

──────────────────────────────────────────────────────────────────────
Installed: ${LABEL}  ${FORCE:+(FORCED — verify no double-dispatch with gateway)}
Plist:     ${PLIST_PATH}
Interval:  every ${INTERVAL_SECONDS}s, up to ${MAX_SPAWNS_PER_TICK} spawns/tick
Logs:      tail -F ${LOG_DIR}/kanban-daemon.log
Status:    launchctl list ${LABEL}
Uninstall: $(basename "$0") --uninstall
──────────────────────────────────────────────────────────────────────
EOF
