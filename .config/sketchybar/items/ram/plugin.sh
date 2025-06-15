#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

PERCENTAGE="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}')"

case ${PERCENTAGE} in
  9[0-9]|100) COLOR="$COLOR_RED" ;;
  [6-8][0-9]) COLOR="$COLOR_ORANGE" ;;
  [3-5][0-9]) COLOR="$COLOR_YELLOW" ;;
  [1-2][0-9]) COLOR="$COLOR_GREEN" ;;
  *) COLOR="$COLOR_GREEN" ;;
esac

sketchybar -m --set ram label="$PERCENTAGE%" label.color="$COLOR"
