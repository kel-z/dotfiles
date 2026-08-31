#!/bin/bash
# Lid closed: clamshell if an external display is active, else lock +
# suspend-then-hibernate.
EXTERNAL=$(swaymsg -t get_outputs -r | jq '[.[] | select(.name != "eDP-1" and .active)] | length')

if [ "$EXTERNAL" -gt 0 ]; then
    swaymsg output eDP-1 disable
    exit 0
fi

sleep 1

# libinput re-emits a stale switch state after resume; check the live kernel
# bitmap (EVIOCGSW) instead of trusting the event.
lid_closed() {
    local node
    node="/dev/input/$(awk '/Name="Lid Switch"/{f=1} f && /H:/{match($0, /event[0-9]+/); print substr($0, RSTART, RLENGTH); exit}' /proc/bus/input/devices)"
    [ -c "$node" ] || return 0
    python3 - "$node" <<'PYEOF'
import fcntl, array, os, sys
buf = array.array("B", [0] * 8)
EVIOCGSW = (2 << 30) | (8 << 16) | (0x45 << 8) | 0x1B
fd = os.open(sys.argv[1], os.O_RDONLY)
fcntl.ioctl(fd, EVIOCGSW, buf, True)
sys.exit(0 if buf[0] & 1 else 1)
PYEOF
}

if lid_closed; then
    swaylock -f --image ~/.config/sway/backgrounds/rn_image_picker_lib_temp_2c0543b3-35e1-46eb-82b5-539a6aa1a753.jpg
    systemctl suspend-then-hibernate
fi
