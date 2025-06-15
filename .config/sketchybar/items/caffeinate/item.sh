#!/usr/bin/env bash

# Caffeine https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-12964898
#    󰾪 󰾫
# --add item name q (position left of the notch)

sketchybar \
  --add item caffeinate q \
  --set caffeinate \
    label.padding_left=0 \
    label.padding_right=0 \
    script="$ITEMS/caffeinate/plugin.sh" \
    click_script="$ITEMS/caffeinate/plugin.sh" \
