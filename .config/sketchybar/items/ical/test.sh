#!/usr/bin/env bash

EVENTS_FILE="$HOME/.config/sketchybar/items/ical/events.txt"

while IFS= read -r line; do
  # Normalize line: replace EN DASH with ASCII dash and squeeze spaces
  norm_line=$(echo "$line" | tr '–' '-' | tr -s ' ')
  echo "Norm line: [$norm_line]"

  # Regex to parse date, start time, end time, and title
  if [[ "$norm_line" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})\ ([0-9]{2}:[0-9]{2})-([0-9]{2}:[0-9]{2})\ \|\ (.+)$ ]]; then
    echo "MATCH!"
    echo "Date: ${BASH_REMATCH[1]}"
    echo "Start: ${BASH_REMATCH[2]}"
    echo "End: ${BASH_REMATCH[3]}"
    echo "Title: ${BASH_REMATCH[4]}"
  else
    echo "No match for line"
  fi
done < "$EVENTS_FILE"

