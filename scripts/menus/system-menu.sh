#!/usr/bin/env bash

launcher="${1:-fuzzel}"   # default = fuzzel

menu() {
    case "$launcher" in
        fuzzel)
            fuzzel --dmenu --prompt="$1"
            ;;
        tofi)
            tofi --prompt-text="$1"
            ;;
        *)
            echo "Unknown launcher: $launcher" >&2
            exit 1
            ;;
    esac
}

# First menu
choice="$(printf "kill\nsleep\nreboot\nshutdown\n" | menu 'Action: ')"

case "$choice" in
    kill)
        # Second menu: process list
        selection="$(ps -u "$USER" -o pid,comm | menu 'Kill: ')"

        [[ -z "$selection" ]] && exit 0

        pid="$(awk '{print $1}' <<< "$selection")"
        kill "$pid"
        ;;
    sleep)
        slock && systemctl suspend -i
        ;;
    reboot)
        reboot
        ;;
    shutdown)
        shutdown now
        ;;
    *)
        exit 0
        ;;
esac
