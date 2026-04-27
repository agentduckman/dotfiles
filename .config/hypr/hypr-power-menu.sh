#!/usr/bin/env bash
set -euo pipefail

entries="Shutdown
Reboot
Sleep
Suspend
Logout"

choice="$(printf '%s\n' $entries | fuzzel --dmenu \
    --prompt='Power: ' \
    --width=20 \
    --lines=5 \
)"

[ -z "${choice:-}" ] && exit 0

case "$choice" in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Sleep)
        systemctl suspend-then-hibernate || systemctl suspend
        ;;
    Suspend)
        systemctl suspend
        ;;
    Logout)
        hyprctl dispatch exit 0
        ;;
esac
