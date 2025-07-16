#!/usr/bin/env bash

# 󰥔 󱑎
sketchybar \
  --add item date right \
  --set date update_freq="$POLL_UPDATES_MID" \
    label.font="$FONT:$LABEL_SUB_SIZE" \
    y_offset="$LABEL_SUP_OFFSET" \
    width=0 \
    script="$ITEMS/time/plugin.sh date" \
  --add item time right \
  --set time update_freq="$POLL_UPDATES" \
    label.font="$FONT:$LABEL_SUB_SIZE" \
    label.y_offset="$LABEL_OFFSET" \
    script="$ITEMS/time/plugin.sh"
