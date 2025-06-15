#!/usr/bin/env bash

# mod from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-12990688
source "$HOME/.config/sketchybar/vars.sh"

SOUNDS_PATH="/System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds"
COUNTDOWN_PID_FILE="$HOME/.config/sketchybar/items/pomodoro/timer-pid"
DEFAULT_DURATION=600 # 10 mins
NAME="timer"  # Static item name in sketchybar

stop_timer() {
  local mode="$1"  # "forced" or "natural"

  if [[ "$mode" == "forced" ]]; then
    afplay "$SOUNDS_PATH/TrackingOff.aiff"
  else
    sketchybar --set "$NAME" \
      label="Done" \
      label.color="$COLOR_GREEN" \
      icon.color="$COLOR_GREEN"
    afplay "$SOUNDS_PATH/TrackingOff.aiff"
    afplay "$SOUNDS_PATH/TrackingOff.aiff"
    afplay "$SOUNDS_PATH/TrackingOff.aiff"
  fi
  sketchybar --set "$NAME" \
    label="" \
    label.color="$SKBAR_COLOR_LABEL_ACTIVE" \
    icon.color="$SKBAR_COLOR_ICON"

  if [[ -f "$COUNTDOWN_PID_FILE" ]]; then
    local PID
    PID=$(<"$COUNTDOWN_PID_FILE")
    if [[ -n "$PID" && "$mode" == "forced" ]]; then
      if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID" 2>/dev/null
      fi
    fi
    rm -f "$COUNTDOWN_PID_FILE"
  fi
}

start_timer() {
  local duration="$1"

  (
    local time_left="$duration"
    while [ "$time_left" -gt 0 ]; do
      local minutes=$((time_left / 60))
      local seconds=$((time_left % 60))
      sketchybar --set "$NAME" \
        label="$(printf "%02d:%02d" "$minutes" "$seconds")" \
        icon.color="$COLOR_YELLOW"
      sleep 1
      time_left=$((time_left - 1))
    done
    stop_timer "natural"
    # Ensure cleanup even if something went wrong above
    rm -f "$COUNTDOWN_PID_FILE"
  ) &
  
  echo "$!" > "$COUNTDOWN_PID_FILE"
  afplay "$SOUNDS_PATH/TrackingOn.aiff"
}

toggle_timer() {
  if [[ -f "$COUNTDOWN_PID_FILE" ]]; then
    local PID
    PID=$(<"$COUNTDOWN_PID_FILE")
    if [[ -n "$PID" && $(ps -p "$PID" -o comm=) == "bash" ]]; then
      stop_timer "forced"
      sketchybar --set "$NAME" label=""
      return
    fi
  fi
  start_timer "$DEFAULT_DURATION"
}

# External call with numeric argument (popup)
if [[ "$1" =~ ^[0-9]+$ ]]; then
  stop_timer "forced"
  start_timer "$1"
  exit 0
fi

# Sketchybar event handling
case "$SENDER" in
  "mouse.clicked")
    toggle_timer
    ;;
  "mouse.entered")
    sketchybar --set "$NAME" popup.drawing=on
    ;;
  "mouse.exited"|"mouse.exited.global")
    sketchybar --set "$NAME" popup.drawing=off
    ;;
esac

