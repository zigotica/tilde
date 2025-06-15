#!/usr/bin/env bash

# --add item name q (position left of the notch)
sketchybar \
  --add item timer q \
  --set timer \
    label="" \
    icon=􀐱   \
    background.drawing=off \
    script="$ITEMS/pomodoro/plugin.sh" \
    click_script="$ITEMS/pomodoro/plugin.sh" \
    popup.y_offset="$POPUP_OFFSET" \
    popup.align=center                  \
  --subscribe timer mouse.clicked mouse.entered mouse.exited mouse.exited.global 

for timer in "5" "10" "25" "60"; do
sketchybar \
  --add item "timer.${timer}" popup.timer \
  --set "timer.${timer}" label="${timer} Minutes" \
    click_script="$ITEMS/pomodoro/plugin.sh $((timer * 60)); sketchybar -m --set timer popup.drawing=off"
done
