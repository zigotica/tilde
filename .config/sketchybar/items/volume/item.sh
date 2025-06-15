#!/usr/bin/env bash

# Add Colume item
sketchybar \
  --add item volume right \
  --set volume \
    script="$ITEMS/volume/plugin.sh" \
  --subscribe volume volume_change
