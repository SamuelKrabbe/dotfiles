#!/usr/bin/env bash
# Automatically switch default sink to any USB or Bluetooth headset

# get default speakers fallback
get_speakers() {
    wpctl status | grep -i 'analog-stereo' | grep -v 'usb' | awk '{print $1}' | head -n1
}

main() {
    # monitor sinks
    wpctl subscribe | while read -r event; do
        echo "Event: $event"   # DEBUG

        if echo "$event" | grep -q "new node"; then
            HEADSET=$(wpctl status | grep -iE "usb|bluez.*analog" | awk '{print $1}' | head -n1)
            if [ -n "$HEADSET" ]; then
                echo "Switching default to headset: $HEADSET"   # DEBUG
                wpctl set-default "$HEADSET"
            fi
        fi

        if echo "$event" | grep -q "remove node"; then
            HEADSET=$(wpctl status | grep -iE "usb|bluez.*analog" | awk '{print $1}' | head -n1)
            if [ -z "$HEADSET" ]; then
                SPEAKERS=$(get_speakers)
                if [ -n "$SPEAKERS" ]; then
                    echo "Switching default to speakers: $SPEAKERS"   # DEBUG
                    wpctl set-default "$SPEAKERS"
                fi
            fi
        fi
    done
}

main
