#!/usr/bin/env bash

# Add CPU item
sketchybar \
  --add item disk_label right \
  --set disk_label \
    label=DISK \
    label.font="$FONT:$LABEL_SUP_SIZE" \
    y_offset="$LABEL_SUP_OFFSET" \
    width=0 \
  --add item disk right \
  --set disk \
    update_freq="$POLL_UPDATES_LONG" \
    label.font="$FONT:$LABEL_SUB_SIZE" \
    y_offset="$LABEL_OFFSET" \
    script="$ITEMS/disk/plugin.sh"
