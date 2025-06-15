#!/usr/bin/env bash

# Add current app after workspaces
# --add item name q (position left of the notch)

sketchybar \
  --add item front_app q \
  --set front_app icon.font="sketchybar-app-font:Regular:$ICON_SIZE" \
    script="$ITEMS/front_app/plugin.sh $ITEMS/front_app" \
  --subscribe front_app front_app_switched
