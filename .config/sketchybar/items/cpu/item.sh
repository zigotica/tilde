#!/usr/bin/env bash

# Add CPU item
sketchybar \
  --add item cpu_label right \
  --set cpu_label \
    label=CPU \
    label.font="$FONT:$LABEL_SUP_SIZE" \
    y_offset="$LABEL_SUP_OFFSET" \
    width=0 \
  --add item cpu right \
  --set cpu \
    update_freq="$POLL_UPDATES" \
    label.font="$FONT:$LABEL_SUB_SIZE" \
    y_offset="$LABEL_OFFSET" \
    script="$ITEMS/cpu/plugin.sh"
