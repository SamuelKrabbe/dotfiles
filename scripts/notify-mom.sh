#!/usr/bin/env bash

REMOTE_HOST="moms-desktop"
REMOTE_USER="neuza"

DEFAULT_TITLE="Samuel"
DEFAULT_MESSAGE="Oi mãe, Ave Maria Puríssima"

show_help() {
    cat << EOF
Usage: notify-mom [options]

Options:
  -t, --title TITLE        Set the notification title.
  -m, --message MESSAGE    Set the notification message.
  -h, --help               Show this help message.

Examples:
  notify-mom -m "Bom dia, mãe!"
  notify-mom -t "Alerta" -m "Vou reiniciar o PC."
  notify-mom
EOF
}

check_connection() {
    ssh "$REMOTE_HOST" "exit 0" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Error: unable to connect to mom's PC ($REMOTE_HOST)."
        exit 1
    fi
}

get_remote_uid() {
    ssh "$REMOTE_HOST" id -u "$REMOTE_USER" 2>/dev/null
}

send_notification() {
    local title="$1"
    local message="$2"

    local uid
    uid=$(get_remote_uid)

    if [[ -z "$uid" ]]; then
        echo "Error: unable to get UID for remote user '$REMOTE_USER'."
        exit 1
    fi

    local remote_cmd
    remote_cmd=$(cat << EOF
DISPLAY=:0 \
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus \
notify-send "$(printf '%q' "$title")" "$(printf '%q' "$message")"
EOF
)

    ssh "$REMOTE_USER@$REMOTE_HOST" "$remote_cmd"
}

main() {
    local title="$DEFAULT_TITLE"
    local message="$DEFAULT_MESSAGE"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--title)
                title="$2"
                shift 2
                ;;
            -m|--message)
                message="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Error: unknown option '$1'"
                echo "Use '--help' to see available options."
                exit 1
                ;;
        esac
    done

    check_connection

    if send_notification "$title" "$message"; then
        echo "Notification sent."
    else
        echo "Error: failed to send notification."
        exit 1
    fi
}

main "$@"
