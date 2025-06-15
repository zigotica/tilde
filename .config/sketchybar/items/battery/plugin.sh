#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

BATT=$(pmset -g batt)
PERCENTAGE="$(echo "${BATT}" | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(echo "${BATT}" | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

# 󱊡 󱊢 󱊣 - 󰁻 󰁼 󰁿 󰂂
case ${PERCENTAGE} in
  [7-9][0-9]|100) 
    ICON="󱊣" COLOR="$COLOR_GREEN" ;;
  [3-6][0-9]) 
    ICON="󱊢" COLOR="$COLOR_YELLOW" ;;
  [1-2][0-9]) 
    ICON="󱊡" COLOR="$COLOR_ORANGE" ;;
  *) 
    ICON="󰂎" COLOR="$COLOR_RED" ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
