#!/usr/bin/env bash

sketchybar --add item pkm right                      \
           --set pkm                                 \
           icon=""                                  \
           icon.font="$ICON_FONT_ALT:$ICON_SIZE_XL"  \
           icon.color="$COLOR_PURPLE"                \
           label="-"                                 \
           label.font="$FONT:$LABEL_SUB_SIZE"        \
           script="$ITEMS/pkm/plugin.sh"             \
           click_script="$ITEMS/pkm/plugin.sh open"  \
           update_freq="$POLL_UPDATES_DAILY"
