#!/usr/bin/env bash

APP_DIR="/usr/share/applications"

parse_desktop() {
    local file="$1"
    local name=""
    local exec=""
    local icon=""

    while IFS='=' read -r key val; do
        case "$key" in
            Name)
                name="$val"
                ;;
            Exec)
                exec="$val"
                exec="${exec//\%[A-Za-z]/}"  # remove %U %F %f etc.
                ;;
            Icon)
                icon="$val"
                ;;
        esac
    done < <(grep -E "^(Name|Exec|Icon)=" "$file")

    local icon_file=""
    icon_file=$(find /usr/share/icons -type f -name "$icon.*" 2>/dev/null | head -n1)

    # Output format:
    # icon_file <space> name | exec
    echo "$icon_file $name | $exec"
}

list_apps() {
    for desktop in "$APP_DIR"/*.desktop; do
        parse_desktop "$desktop"
    done
}

launch_with_tofi() {
    local choice
    choice=$(list_apps | tofi --prompt-text="Apps: " --image-size 48 --image-style center)
    local app_exec
    app_exec=$(echo "$choice" | awk -F'|' '{print $2}')
    eval "$app_exec" &
}

launch_with_fzf() {
    local choice
    choice=$(list_apps | awk -F'|' '{print $1}' | sed 's|^[^ ]* ||' | fzf --prompt="Apps: ")
    local app_exec
    app_exec=$(list_apps | grep "^.*$choice" | awk -F'|' '{print $2}' | head -n1)
    eval "$app_exec" &
}

main() {
    case "$1" in
        fzf)
            launch_with_fzf
            ;;
        *)
            launch_with_tofi
            ;;
    esac
}

main "$@"
