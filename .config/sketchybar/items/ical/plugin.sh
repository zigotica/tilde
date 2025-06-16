#!/usr/bin/env bash

# Data from the compiled swift script that reads the calendars
# See https://github.com/zigotica/macos-calendar-events
# This avoids TCC (Transparency, Consent, and Control) permission issues
# sketchybar does not have access to PATH, so you need to pass the full path to binary
# Update list of events, for up to end of current day (no args passed):
EVENTS_FILE="$HOME/.config/sketchybar/items/ical/events.txt"
~/.config/bin/utils/calendar-events > "$EVENTS_FILE"

source "$HOME/.config/sketchybar/vars.sh"

update() {
    args=()
    COUNTER=0

    # Remove events from previous updates
    for i in $(seq 1 200); do
      args+=(--remove "ical.event.$i")
    done

    # Read all lines, trim spaces
    EVENTS=$(cat "$EVENTS_FILE")

    # Get current time in minutes since midnight
    now_hour=$(date +%H)
    now_min=$(date +%M)
    now_total_minutes=$((10#$now_hour * 60 + 10#$now_min))

    # Process each event line
    while IFS= read -r line; do
      [ -z "$line" ] && continue

      if [[ "$line" =~ ^[0-9]{2}:[0-9]{2}–[0-9]{2}:[0-9]{2}\ \|\ .+ ]]; then
        COUNTER=$((COUNTER + 1))

        # Extract time and title
        time_part="${line%%|*}"
        time_part="$(echo "$time_part" | xargs)"
        title_part="${line#*|}"
        title_part="$(echo "$title_part" | xargs)"

        # Extract start and end time
        start_time="${time_part%%–*}"
        end_time="${time_part##*–}"

        start_hour=${start_time%%:*}
        start_min=${start_time##*:}
        end_hour=${end_time%%:*}
        end_min=${end_time##*:}

        start_total_minutes=$((10#$start_hour * 60 + 10#$start_min))
        end_total_minutes=$((10#$end_hour * 60 + 10#$end_min))

        # Default color
        LABEL_COLOR="$SKBAR_COLOR_LABEL_ACTIVE"

        # If current time is within event range
        if [[ $now_total_minutes -ge $start_total_minutes && $now_total_minutes -lt $end_total_minutes ]]; then
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

    # Create popup items
    sketchybar "${args[@]}" > /dev/null

    if [[ $COUNTER -gt 5 ]]; then
      COLOR="$COLOR_RED"
    elif [[ $COUNTER -gt 2 ]]; then
      COLOR="$COLOR_ORANGE"
    elif [[ $COUNTER -gt 0 ]]; then
      COLOR="$COLOR_YELLOW"
    else
      COLOR="$COLOR_GREEN"
    fi

    # update calendar icon color based on the number of events
    sketchybar -m \
      --set ical \
        icon.color="$COLOR"
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
