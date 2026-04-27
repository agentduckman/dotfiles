#!/usr/bin/env bash

set -u

LOG="$HOME/.config/hypr/hypr-display.log"
LOCKDIR="$HOME/.config/hypr/.display-reconcile.lock"

EDP="eDP-1"
EXT="DP-1"
EDP_SCALE="1.07"

log() {
  mkdir -p "$HOME/.config/hypr"
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG"
}

cleanup() {
  rmdir "$LOCKDIR" 2>/dev/null || true
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Prevent overlapping runs
acquire_lock() {
  if mkdir "$LOCKDIR" 2>/dev/null; then
    trap cleanup EXIT INT TERM
    return 0
  fi

  log "Another instance is already running; exiting"
  exit 0
}

# Return 0 if the external connector is physically connected
dp_connected_once() {
  local status_file found=1
  shopt -s nullglob
  for status_file in /sys/class/drm/card*-"${EXT}"/status; do
    found=0
    if [[ -r "$status_file" ]] && grep -qx 'connected' "$status_file"; then
      return 0
    fi
  done
  shopt -u nullglob

  # If no matching DRM status file exists, treat as disconnected
  [[ $found -eq 0 ]] || log "No DRM status file found for ${EXT}; treating as disconnected"
  return 1
}

# Return 0 if lid is closed
lid_closed_once() {
  local lid_path found=1
  shopt -s nullglob
  for lid_path in /proc/acpi/button/lid/*/state; do
    found=0
    if [[ -r "$lid_path" ]] && grep -qi 'closed' "$lid_path"; then
      return 0
    fi
  done
  shopt -u nullglob

  # If no lid state exists, assume open rather than doing something destructive
  [[ $found -eq 0 ]] || log "No lid state file found; treating lid as open"
  return 1
}

# Read twice with a small delay to reduce racey hotplug/lid transitions
dp_connected() {
  local a b
  if dp_connected_once; then a=1; else a=0; fi
  sleep 0.20
  if dp_connected_once; then b=1; else b=0; fi
  [[ "$a" -eq 1 && "$b" -eq 1 ]]
}

lid_closed() {
  local a b
  if lid_closed_once; then a=1; else a=0; fi
  sleep 0.20
  if lid_closed_once; then b=1; else b=0; fi
  [[ "$a" -eq 1 && "$b" -eq 1 ]]
}

# Return 0 if Hyprland currently has the monitor active
monitor_enabled() {
  hyprctl monitors 2>/dev/null | grep -q "^Monitor ${1} "
}

move_workspaces_off_edp() {
  local ws
  local moved=0

  # Parse plain-text output to avoid jq dependency
  while IFS= read -r ws; do
    [[ -n "$ws" ]] || continue
    log "Moving workspace ${ws} from ${EDP} to ${EXT}"
    hyprctl dispatch moveworkspacetomonitor "$ws" "$EXT" >> "$LOG" 2>&1 || \
      log "Failed to move workspace ${ws} to ${EXT}"
    moved=1
  done < <(
    hyprctl workspaces 2>/dev/null | awk -v mon="$EDP" '
      /^workspace ID / { id=$3 }
      /monitor:/ && $2 == mon { print id }
    '
  )

  [[ $moved -eq 1 ]] || log "No workspaces needed moving off ${EDP}"
}

enable_edp() {
  if monitor_enabled "$EDP"; then
    log "${EDP} already enabled; no change"
    return 0
  fi

  log "Enabling ${EDP}"
  hyprctl keyword monitor "${EDP}, preferred, auto, ${EDP_SCALE}" >> "$LOG" 2>&1 || {
    log "Failed to enable ${EDP}"
    return 1
  }
}

disable_edp() {
  if ! monitor_enabled "$EDP"; then
    log "${EDP} already disabled; no change"
    return 0
  fi

  if ! monitor_enabled "$EXT"; then
    log "Refusing to disable ${EDP} because ${EXT} is not active in Hyprland"
    return 1
  fi

  move_workspaces_off_edp

  log "Disabling ${EDP}"
  hyprctl keyword monitor "${EDP}, disable" >> "$LOG" 2>&1 || {
    log "Failed to disable ${EDP}"
    return 1
  }
}

main() {
  local ext_connected=0
  local lid_is_closed=0

  mkdir -p "$HOME/.config/hypr"
  acquire_lock

  if ! have_cmd hyprctl; then
    log "hyprctl not found in PATH; exiting"
    exit 1
  fi

  if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    log "HYPRLAND_INSTANCE_SIGNATURE is not set; Hyprland may not be running in this environment"
  fi

  if dp_connected; then
    ext_connected=1
  fi

  if lid_closed; then
    lid_is_closed=1
  fi

  log "State snapshot: ${EXT}_connected=${ext_connected} lid_closed=${lid_is_closed}"

  # Policy:
  # 1) If EXT is disconnected, always enable eDP
  # 2) If EXT is connected and lid is closed, disable eDP
  # 3) If EXT is connected and lid is open, enable eDP
  if [[ "$ext_connected" -eq 0 ]]; then
    log "${EXT} is disconnected; ensuring ${EDP} is enabled"
    enable_edp
    exit $?
  fi

  if [[ "$lid_is_closed" -eq 1 ]]; then
    log "${EXT} is connected and lid is closed; ensuring ${EDP} is disabled"
    disable_edp
    exit $?
  fi

  log "${EXT} is connected and lid is open; ensuring ${EDP} is enabled"
  enable_edp
}

main "$@"
