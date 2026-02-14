#!/usr/bin/env bash

# Add battery item
sketchybar \
  --add item battery right \
  --set battery update_freq="$POLL_UPDATES_MID" \
        label.font="$FONT:$LABEL_SUB_SIZE"      \
    script="$ITEMS/battery/plugin.sh" \
  --subscribe battery system_woke power_source_change
