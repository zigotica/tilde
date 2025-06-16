#!/usr/bin/env bash

# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-4715904
POPUP_CLICK_SCRIPT="sketchybar --set ical popup.drawing=toggle"

sketchybar --add       item            ical right                         \
           --set       ical            update_freq="$POLL_UPDATES_MID"   \
                                       icon="􀉉 "                          \
                                       label=""                           \
                                       popup.align=right                  \
                                       popup.height=0                     \
                                       popup.y_offset="$POPUP_OFFSET"     \
                                       script="$ITEMS/ical/plugin.sh"     \
                                       click_script="$POPUP_CLICK_SCRIPT" \
           --subscribe ical            mouse.clicked                      \
                                       mouse.entered                      \
                                       mouse.exited                       \
                                       mouse.exited.global                
