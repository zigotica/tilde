#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on label.color="$COLOR_GREEN"
else
  sketchybar --set $NAME background.drawing=off label.color="$SKBAR_COLOR_LABEL_ACTIVE"
fi
