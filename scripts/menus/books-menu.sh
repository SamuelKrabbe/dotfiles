#!/usr/bin/env bash

BOOKS_DIR="/home/samuel/books"

# Convert filename into a clean title
format_title() {
    local file="$1"
    local base
    base=$(basename "$file")                # remove path
    base="${base%.*}"                      # remove extension
    base="${base//[_-]/ }"                 # turn _ and - into spaces
    echo "$base" | sed 's/\b\(.\)/\u\1/g'  # title case
}

list_books() {
    # Output lines as:  Title|/path/to/file
    for file in "$BOOKS_DIR"/*; do
        [ -f "$file" ] || continue
        local title
        title=$(format_title "$file")
        printf "%s|%s\n" "$title" "$file"
    done
}

open_book() {
    xdg-open "$1" &
}

launch_with_tofi() {
    local choice
    choice=$(list_books | awk -F'|' '{print $1}' | tofi --prompt-text="Books: ")

    [ -z "$choice" ] && return

    local real_path
    real_path=$(list_books | grep "^$choice|" | awk -F'|' '{print $2}' | head -n1)

    [ -n "$real_path" ] && open_book "$real_path"
}

launch_with_fuzzel() {
    local choice
    choice=$(list_books | awk -F'|' '{print $1}' | fuzzel --dmenu --prompt="Books: " --width=35 )

    [ -z "$choice" ] && return

    local real_path
    real_path=$(list_books | grep "^$choice|" | awk -F'|' '{print $2}' | head -n1)

    [ -n "$real_path" ] && open_book "$real_path"
}

main() {
    case "$1" in
        fuzzel)
            launch_with_fuzzel
            ;;
        *)
            launch_with_tofi
            ;;
    esac
}

main "$@"
