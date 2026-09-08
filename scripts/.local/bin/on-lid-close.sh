#!/bin/bash
# Lid closed: clamshell if an external display is active, else suspend-then-hibernate.
# Locking is swayidle's before-sleep hook; don't duplicate it here.

# Seconds the lid must stay shut before we commit. logind needs ~4s to clear its
# delay inhibitors, and nothing can cancel a suspend once the request is out, so
# the whole abort window has to live on this side of the systemctl call.
GRACE_SEC=5

# A lid bounce fires bindswitch twice; only the first instance should proceed.
exec 9>"${XDG_RUNTIME_DIR:-/run/user/$UID}/on-lid-close.lock"
flock -n 9 || exit 0

EXTERNAL=$(swaymsg -t get_outputs -r | jq '[.[] | select(.name != "eDP-1" and .active)] | length')

if [ "$EXTERNAL" -gt 0 ]; then
    swaymsg output eDP-1 disable
    exit 0
fi

# libinput re-emits a stale switch state after resume; check the live kernel
# bitmap (EVIOCGSW) instead of trusting the event.
NODE="/dev/input/$(awk '/Name="Lid Switch"/{f=1} f && /^H: /{match($0, /event[0-9]+/); print substr($0, RSTART, RLENGTH); exit}' /proc/bus/input/devices)"

lid_closed() {
    [ -c "$NODE" ] || return 0
    python3 - "$NODE" <<'PYEOF'
import fcntl, array, os, sys
buf = array.array("B", [0] * 8)
EVIOCGSW = (2 << 30) | (8 << 16) | (0x45 << 8) | 0x1B
fd = os.open(sys.argv[1], os.O_RDONLY)
fcntl.ioctl(fd, EVIOCGSW, buf, True)
sys.exit(0 if buf[0] & 1 else 1)
PYEOF
}

for _ in $(seq $((GRACE_SEC * 4))); do
    lid_closed || exit 0
    sleep 0.25
done

lid_closed || exit 0
systemctl suspend-then-hibernate
