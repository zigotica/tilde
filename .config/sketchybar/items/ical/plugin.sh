#!/usr/bin/env bash

# Data from the compiled swift script that reads the calendars
# See https://github.com/zigotica/macos-calendar-events
# This avoids TCC (Transparency, Consent, and Control) permission issues
# sketchybar does not have access to PATH, so you need to pass the full path to binary
# Update list of events, for up to end of current day (no args passed):
EVENTS_FILE="$HOME/.config/sketchybar/items/ical/events.txt"
~/.config/bin/utils/calendar-events 5 > "$EVENTS_FILE"

source "$HOME/.config/sketchybar/vars.sh"

update() {
    args=()
    COUNTER=0

    # Remove previous popup events
    for i in $(seq 1 200); do
      args+=(--remove "ical.event.$i")
    done

    EVENTS=$(cat "$EVENTS_FILE")

    # Get current time in minutes since midnight
    today=$(date +%F)
    now_hour=$(date +%H)
    now_min=$(date +%M)
    now_total_minutes=$((10#$now_hour * 60 + 10#$now_min))

    # Process each event line
    while IFS= read -r line; do
      [ -z "$line" ] && continue

      if [[ "$line" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]([0-9]{2}:[0-9]{2})[-–]([0-9]{2}:[0-9]{2})[[:space:]]\|[[:space:]](.+)$ ]]; then
        event_date="${BASH_REMATCH[1]}"
        start_time="${BASH_REMATCH[2]}"
        end_time="${BASH_REMATCH[3]}"
        title_part="${BASH_REMATCH[4]}"

        COUNTER=$((COUNTER + 1))
        time_part="${start_time}–${end_time}"

        start_hour=${start_time%%:*}
        start_min=${start_time##*:}
        end_hour=${end_time%%:*}
        end_min=${end_time##*:}

        start_total_minutes=$((10#$start_hour * 60 + 10#$start_min))
        end_total_minutes=$((10#$end_hour * 60 + 10#$end_min))

        # Default color
        LABEL_COLOR="$SKBAR_COLOR_LABEL_ACTIVE"

        # If event is today and current time is within event range
        if [ "$event_date" = "$today" ] && (( now_total_minutes >= start_total_minutes && now_total_minutes < end_total_minutes )); then
          LABEL_COLOR="$COLOR_YELLOW"
        fi

        args+=(
          --add item "ical.event.$COUNTER" popup.ical
          --set "ical.event.$COUNTER" \
            label="${time_part}: ${title_part}" \
            label.color="$LABEL_COLOR" \
            background.height=20 \
            background.drawing=on
        )
      fi
    done <<< "$EVENTS"

    # Apply popup update
    sketchybar "${args[@]}" > /dev/null

    # Update calendar icon color based on number of events
    if (( COUNTER > 5 )); then
      COLOR="$COLOR_RED"
    elif (( COUNTER > 2 )); then
      COLOR="$COLOR_ORANGE"
    elif (( COUNTER > 0 )); then
      COLOR="$COLOR_YELLOW"
    else
      COLOR="$COLOR_GREEN"
    fi

    sketchybar -m --set ical icon.color="$COLOR"
}

popup() {
    sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
    "routine"|"forced") update ;;
    "mouse.entered") popup on ;;
    "mouse.exited"|"mouse.exited.global") popup off ;;
    "mouse.clicked") popup toggle ;;
esac
