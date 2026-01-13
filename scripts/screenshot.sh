#!/usr/bin/env bash

set -uo pipefail

# Dependencies
REQUIRED_CMDS="grim slurp wl-copy notify-send"
COLORPICKER_CMD="magick"

# Check core dependencies
for cmd in $REQUIRED_CMDS; do
    command -v "$cmd" >/dev/null || { echo "ERROR: Core dependency missing: **$cmd**"; exit 1; }
done

# Check optional colorpicker dependency only if running colorpicker, 
# or check it here but make the error non-fatal if colorpicker isn't run.
if [[ "$1" == "-c" || "$1" == "--color"* ]]; then
    command -v "$COLORPICKER_CMD" >/dev/null || { echo "ERROR: Colorpicker dependency missing: **$COLORPICKER_CMD**"; exit 1; }
fi

OUTDIR="${2:-$HOME/Pictures/Screenshots}"
mkdir -p "$OUTDIR"

FILE="$OUTDIR/screenshot-$(date +'%d-%m-%Y_%H-%M-%S').png"

show_help() {
    cat <<EOF
Usage: $0 [OPTION] [OUTPUT_DIR]

Options:
  **-f**, **--full** Capture the entire screen.
  **-w**, **--window** Capture a single window (via slurp -r).
  **-c**, **--color** Use the color picker (requires **magick**).
  **-s**, **--select** Capture a selected region (**Default action**).
  **-h**, **--help** Show this help message.
EOF
}

post() {
    # Ensure the file exists before copying/notifying
    if [[ ! -f "$FILE" ]] || [[ ! -s "$FILE" ]]; then
        echo "ERROR: Screenshot failed or file is empty: $FILE"
        return 1
    fi

    # Copy to clipboard
    wl-copy < "$FILE"

    # Notification
    notify-send -i "$FILE" "Screenshot Saved and Copied" "$(basename "$FILE")"

    local hist_script="/home/samuel/scripts/shell_scripts/imgcliphist.sh"

    if [[ -x "$hist_script" ]]; then
        "$hist_script" --add
    fi
}

safe_slurp() {
    local region
    region="$(slurp 2>/dev/null)"

    # User pressed Esc or selection failed
    if [[ -z "$region" ]]; then
        notify-send "Screenshot Cancelled" "No region selected."
        return 1
    fi

    # Sanity check: format "x,y WxH"
    if ! [[ "$region" =~ ^[0-9]+,[0-9]+\ [0-9]+x[0-9]+$ ]]; then
        notify-send "Screenshot Error" "Invalid selection region."
        return 1
    fi

    echo "$region"
}

capture_full() {
    grim "$FILE" || return 1
    post
}

capture_selection() {
    region="$(safe_slurp)" || return 1
    grim -g "$region" "$FILE" || return 1
    post
}

capture_window() {
    if command -v hyprctl >/dev/null 2>&1; then
        # Hyprland window capture
        WININFO=$(hyprctl activewindow -j 2>/dev/null) || return 1

        X=$(jq -r '.at[0]' <<< "$WININFO")
        Y=$(jq -r '.at[1]' <<< "$WININFO")
        W=$(jq -r '.size[0]' <<< "$WININFO")
        H=$(jq -r '.size[1]' <<< "$WININFO")

        if [[ -z "$X" || -z "$Y" || -z "$W" || -z "$H" ]]; then
            notify-send "Screenshot Error" "Failed to get active window geometry."
            return 1
        fi

        grim -g "${X},${Y} ${W}x${H}" "$FILE" || return 1
        post
        return 0
    fi

    # --- Fallback capture method (slurp -r) ---
    region="$(slurp -r 2>/dev/null)"

    if [[ -z "$region" ]]; then
        notify-send "Screenshot Cancelled" "No window selected."
        return 1
    fi

    if ! [[ "$region" =~ ^[0-9]+,[0-9]+\ [0-9]+x[0-9]+$ ]]; then
        notify-send "Screenshot Error" "Invalid window geometry."
        return 1
    fi

    grim -g "$region" "$FILE" || return 1
    post
}

colorpicker() {
    command -v convert >/dev/null || { echo "ERROR: ImageMagick is required for color picker"; exit 1; }

    POINT=$(slurp -p) || exit 1

    HEX=$(grim -g "$POINT" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-)

    echo -n "$HEX" | wl-copy
    notify-send "Color picked" "$HEX"
}

main() {
    case "${1:-}" in
        -h|--help)   show_help ;;
        -f|--full)   capture_full ;;
        -w|--window) capture_window ;;
        -c|--color*) colorpicker ;;
        -s|--select) capture_selection ;;
        *)           capture_selection ;;
    esac
}

main "$@"
