#!/bin/bash

# --- CONFIGURATION ---
DISPLAY_OUTPUT="eDP-1"
TOUCHSCREEN_IDENTIFIER="1386:20656:Wacom_Pen_and_multitouch_sensor_Finger"
STYLUS_IDENTIFIER="1386:20656:Wacom_Pen_and_multitouch_sensor_Pen"
WAYBAR_MODE_FILE="$HOME/.waybar_mode"

# --- DO NOT EDIT BELOW THIS LINE ---

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
    swaymsg output "$DISPLAY_OUTPUT" transform "$sway_transform"

    # Adjust input devices
    # Sway typically handles input device mapping relative to the output,
    # so often just mapping to the output is sufficient.
    # We use map_to_output and sometimes a specific transform if needed.
    swaymsg input "$TOUCHSCREEN_IDENTIFIER" map_to_output "$DISPLAY_OUTPUT"
    swaymsg input "$STYLUS_IDENTIFIER" map_to_output "$DISPLAY_OUTPUT"

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
