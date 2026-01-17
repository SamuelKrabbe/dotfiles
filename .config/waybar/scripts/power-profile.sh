#!/usr/bin/env bash

current=$(powerprofilesctl get | tr -d '\n')

case "$current" in
  performance)
    next="balanced"
    ;;
  balanced)
    next="power-saver"
    ;;
  power-saver)
    next="performance"
    ;;
  *)
    next="balanced"
    ;;
esac

# If called with "toggle", change the profile
if [[ "$1" == "toggle" ]]; then
  powerprofilesctl set "$next"
  current="$next"
fi

echo "{\"alt\":\"$current\",\"tooltip\":\"$current\"}"
