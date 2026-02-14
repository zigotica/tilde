#!/usr/bin/env bash

# Add Colume item
sketchybar \
  --add item volume right \
  --set volume \
        label.font="$FONT:$LABEL_SUB_SIZE"      \
    script="$ITEMS/volume/plugin.sh" \
  --subscribe volume volume_change
