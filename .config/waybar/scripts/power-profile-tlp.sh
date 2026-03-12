#!/usr/bin/env bash

mode=$(tlp-stat -s | grep "Mode" | awk '{print $3}')

case "$mode" in
  AC)
    profile="performance"
    next="bat"
    ;;
  BAT)
    profile="power-saver"
    next="ac"
    ;;
  *)
    profile="balanced"
    next="ac"
    ;;
esac

if [[ "$1" == "toggle" ]]; then
  sudo tlp "$next" >/dev/null 2>&1
  mode=$(tlp-stat -s | grep "Mode" | awk '{print $3}')

  if [[ "$mode" == "AC" ]]; then
    profile="performance"
  else
    profile="power-saver"
  fi
fi

echo "{\"text\":\"\",\"alt\":\"$profile\",\"tooltip\":\"TLP: $mode\"}"
