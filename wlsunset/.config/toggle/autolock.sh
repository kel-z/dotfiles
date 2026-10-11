#!/bin/bash
# status: exit 0 = idle auto-lock (swayidle -> swaylock) enabled
# Flag absence = on, so a fresh session starts unlocked-toggleable with no seeding.
# swayidle itself is spawned by sway's exec; this only gates its lock commands.
F="$HOME/.cache/no-autolock"
case "${1:?on|off|status}" in
  on)     rm -f "$F" ;;
  off)    touch "$F" ;;
  status) [[ ! -e $F ]] ;;
  toggle) if [[ -e $F ]]; then rm -f "$F"; notify-send -t 1500 'autolock on'
          else touch "$F"; notify-send -t 1500 'autolock off'; fi ;;
esac
