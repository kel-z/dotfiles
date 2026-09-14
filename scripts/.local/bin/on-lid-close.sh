#!/bin/bash
# Lid closed: blank the internal panel when an external display is driving the
# session, so sway stops rendering to a shut lid.
#
# Suspending is NOT this script's job -- logind owns the lid, see
# /etc/systemd/logind.conf.d/90-lid-clamshell.conf. Keeping power policy out of
# here means a missed or spurious bindswitch event only mistoggles a display
# instead of stranding the machine awake in a bag.
EXTERNAL=$(swaymsg -t get_outputs -r | jq '[.[] | select(.name != "eDP-1" and .active)] | length')

if [ "$EXTERNAL" -gt 0 ]; then
    swaymsg output eDP-1 disable
fi
