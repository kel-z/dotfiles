#!/bin/bash

# --- CONFIGURATION ---
DISPLAY_OUTPUT="eDP-1"
TOUCHSCREEN_IDENTIFIER="1386:21126:Wacom_HID_5286_Finger"
STYLUS_IDENTIFIER="1386:21126:Wacom_HID_5286_Pen"
WAYBAR_MODE_FILE="$HOME/.waybar_mode"

# --- DO NOT EDIT BELOW THIS LINE ---

# Single instance: sway reload re-runs every `exec` line without killing the old
# process, so stacked copies race each other's pkill waybar.
if [ $# -eq 0 ]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    exec 9>"$XDG_RUNTIME_DIR/sway-rotate-screen.lock"
    if ! flock -n 9; then
        echo "Another rotation monitor is already running, exiting"
        exit 0
    fi
fi

switch_waybar() {
    local mode="$1"  # "portrait" or "landscape"
    local current_mode
    current_mode=$(cat "$WAYBAR_MODE_FILE" 2>/dev/null)
    [ "$mode" = "$current_mode" ] && return 0
    echo "$mode" > "$WAYBAR_MODE_FILE"
    pkill waybar
    sleep 0.3
    if [ "$mode" = "portrait" ]; then
        waybar -c "$HOME/.config/waybar/config.portrait" &
    else
        waybar &
    fi
}

rotate_screen() {
    local orientation="$1"
    local sway_transform="normal"

    if [ -f "$HOME/.rotation_lock" ]; then
        echo "Rotation locked, skipping auto-rotate"
        return 0
    fi

    case "$orientation" in
        "normal")
            sway_transform="normal"
            ;;
        "bottom-up")
            sway_transform="180"
            ;;
        "right-up")
            sway_transform="90"
            ;;
        "left-up")
            sway_transform="270"
            ;;
        *)
            echo "Unknown orientation: $orientation"
            return 1
            ;;
    esac

    echo "Setting orientation to: $orientation (Sway transform: $sway_transform)"

    # Rotate the display output
    swaymsg output "$DISPLAY_OUTPUT" transform "$sway_transform" >/dev/null

    # Adjust input devices
    # Sway typically handles input device mapping relative to the output,
    # so often just mapping to the output is sufficient.
    # We use map_to_output and sometimes a specific transform if needed.
    swaymsg input "$TOUCHSCREEN_IDENTIFIER" map_to_output "$DISPLAY_OUTPUT" >/dev/null
    swaymsg input "$STYLUS_IDENTIFIER" map_to_output "$DISPLAY_OUTPUT" >/dev/null

    # Switch waybar to portrait or landscape config
    case "$sway_transform" in
        "90"|"270") switch_waybar "portrait" ;;
        *)          switch_waybar "landscape" ;;
    esac

    # For some input devices, a specific matrix transform might be needed,
    # but map_to_output usually aligns them correctly.
    # If rotation is still off for input, you might need to uncomment and adjust these:
    # case "$orientation" in
    #     "normal")
    #     swaymsg input "$TOUCHSCREEN_IDENTIFIER" calibration_matrix 1 0 0 0 1 0
    #     swaymsg input "$STYLUS_IDENTIFIER" calibration_matrix 1 0 0 0 1 0
    #     ;;
    #     "bottom-up")
    #     swaymsg input "$TOUCHSCREEN_IDENTIFIER" calibration_matrix -1 0 1 0 -1 1
    #     swaymsg input "$STYLUS_IDENTIFIER" calibration_matrix -1 0 1 0 -1 1
    #     ;;
    #     "right-up")
    #     swaymsg input "$TOUCHSCREEN_IDENTIFIER" calibration_matrix 0 1 0 -1 0 1
    #     swaymsg input "$STYLUS_IDENTIFIER" calibration_matrix 0 1 0 -1 0 1
    #     ;;
    #     "left-up")
    #     swaymsg input "$TOUCHSCREEN_IDENTIFIER" calibration_matrix 0 -1 1 1 0 0
    #     swaymsg input "$STYLUS_IDENTIFIER" calibration_matrix 0 -1 1 1 0 0
    #     ;;
    # esac
}

# With an orientation argument: apply it once and exit (used by toggle-rotation-lock on unlock)
if [ $# -ge 1 ]; then
    rotate_screen "$1"
    exit $?
fi

# On startup, apply correct waybar config based on current display transform
_startup_transform=$(swaymsg -t get_outputs 2>/dev/null | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o.get('name') == '${DISPLAY_OUTPUT}':
        print(o.get('transform', 'normal')); break
" 2>/dev/null || echo "normal")
if [ "$_startup_transform" = "90" ] || [ "$_startup_transform" = "270" ]; then
    switch_waybar "portrait"
else
    switch_waybar "landscape"
fi

echo "Starting Sway screen rotation monitor..."
monitor-sensor --accel \
| while read -r line; do
    # Parse the orientation from lines indicating a change
    if [[ "$line" == *"Accelerometer orientation changed: "* ]]; then
        new_orientation=$(echo "$line" | sed 's/^.*Accelerometer orientation changed: //')
        # Only rotate if a valid orientation was extracted
        if [ -n "$new_orientation" ]; then
            rotate_screen "$new_orientation"
        fi
    fi
done
