#!/usr/bin/env bash

TARGET_PC="192.168.0.11"
TIMEOUT=1

# Ping once, fast timeout
if /usr/bin/ping -c 1 -W "$TIMEOUT" "$TARGET_PC" >/dev/null 2>&1; then
    CLASS="online"
    ICON="󰖩"
    TEXT="Mom Online"
    ALT="PC reachable"
else
    CLASS="offline"
    ICON="󰖪"
    TEXT="Mom Offline"
    ALT="PC unreachable"
fi

printf '{"text":"%s %s","class":"%s","alt":"%s"}\n' "$ICON" "$TEXT" "$CLASS" "$ALT"
exit 0
