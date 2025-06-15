#!/usr/bin/env bash

# 󰥔 󱑎
sketchybar \
  --add item time right \
  --set time update_freq="$POLL_UPDATES_MID" \
    icon="󱑎" \
    script="$ITEMS/time/plugin.sh"
