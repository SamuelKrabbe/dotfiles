#!/usr/bin/env bash

hist="$HOME/.cache/hist"
mkdir -p "$hist"

show_help() {
    cat <<EOF
Usage: $0 [OPTION]

Options:
  -a, --add        Save current clipboard PNG image into history.
  -l, --link URL   Download an image from URL and save it to history.
  -s, --sel        Select an image from history via fzf and copy it.
  -c, --copy FILE  Copy a specific file to the clipboard.
  -h, --help       Show this help message.

Description:
  A simple clipboard image history system for Wayland. Images are stored in:
    $HOME/.cache/hist
EOF
}

add() {
    if wl-paste --list-types | grep -q "image/png"; then
        file="$hist/$(date '+%Y-%m-%d_%H-%M-%S').png"
        wl-paste --type image/png > "$file"
        notify-send -i "$file" "Image added to clipboard history"
    fi
}

link() {
    url="$2"
    file="$hist/$(date '+%Y%m%d-%H%M%S').png"
    wget -q "$url" -O "$file"
    notify-send -i "$file" "Image saved from link"
}

sel() {
    # chosen=$(ls -t "$hist"/*.png | fzf --preview 'imv --stay-fullscreen {} >/dev/null 2>&1 & sleep 0.3; killall imv' --preview-window=right:50%:wrap)
    chosen=$(ls -t "$hist"/*.png | tofi --anchor=bottom --height=200 --width=1920 --prompt-text="Image clipboard history: ")
    [[ -n "$chosen" ]] && wl-copy < "$chosen" && notify-send -i "$chosen" "Image copied to clipboard"
}

copy() {
    file="$2"
    [[ -f "$file" ]] && wl-copy < "$file" && notify-send -i "$file" "Image copied"
}

main() {
    case "${1:-}" in
        -h|--help)  show_help ;;
        -a|--add)   add ;;
        -l|--link)  link "$@" ;;
        -s|--select)   sel ;;
        -c|--copy)  copy "$@" ;;
        *)          sel ;;
    esac
}

main "$@"
