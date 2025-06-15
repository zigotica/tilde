#!/usr/bin/env bash

# Add RAM item
sketchybar \
  --add item ram_label right \
  --set ram_label \
    label=RAM \
    label.font="$FONT:$LABEL_SUP_SIZE" \
    y_offset="$LABEL_SUP_OFFSET" \
    width=0 \
  --add item ram right \
  --set ram \
    update_freq="$POLL_UPDATES" \
    label.font="$FONT:$LABEL_SUB_SIZE" \
    y_offset="$LABEL_OFFSET" \
    script="$ITEMS/ram/plugin.sh"

