#!/usr/bin/env bash

if [ "$1" = "date" ]; then
  FORMAT="%b-%d" # date format
else
  FORMAT="%H:%M" # time format
fi

sketchybar --set "$NAME" label="$(date +"$FORMAT")"
