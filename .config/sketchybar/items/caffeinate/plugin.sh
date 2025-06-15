#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

CAFFINATE_ID=$(pmset -g assertions | grep "caffeinate" | awk '{print $2}' | cut -d '(' -f1 | head -n 1)

# It was not a button click
if [ -z "$BUTTON" ]; then
  if [ -z "$CAFFINATE_ID" ]; then
    sketchybar --set "$NAME" icon= icon.color="$SKBAR_COLOR_LABEL_ACTIVE"
  else
    sketchybar --set "$NAME" icon= icon.color="$COLOR_GREEN"
  fi
  exit 0
fi

# It is a mouse click
if [ -z "$CAFFINATE_ID" ]; then
  caffeinate -idms &
  sketchybar --set "$NAME" icon= icon.color="$COLOR_GREEN"
else
  kill -9 "$CAFFINATE_ID"
  sketchybar --set "$NAME" icon= icon.color="$SKBAR_COLOR_LABEL_ACTIVE"
fi
