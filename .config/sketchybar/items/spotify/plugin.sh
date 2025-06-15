#!/usr/bin/env bash

next ()
{
  osascript -e 'tell application "Spotify" to play next track'
}

back () 
{
  osascript -e 'tell application "Spotify" to play previous track'
}

play () 
{
  osascript -e 'tell application "Spotify" to playpause'
}

repeat () 
{
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else 
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}

shuffle () 
{
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else 
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

update ()
{
  PLAYING=1
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name)"
    # Remove " - " and anything after it, IF it contains "remaster" (case-insensitive)
    TRACK="$(echo "$TRACK" | sed 's/ - .*[Rr][Ee][Mm][Aa][Ss][Tt][Ee][Rr].*$//')"
    ARTIST="$(echo "$INFO" | jq -r .Artist)"
    ALBUM="$(echo "$INFO" | jq -r .Album)"
    # Remove the last occurrence of parentheses or square brackets and their contents,
    # IF they contain "Deluxe", "Edition", or "Remaster" (case-insensitive),
    # and remove everything after it until the end of the string.
    # 󰐾       
    ALBUM="$(echo "$ALBUM" | sed -E 's/ (\((.*(Deluxe|Edition|Remaster).*)\)|\[(.*(Deluxe|Edition|Remaster).*)]).*$//i')"
    SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
    REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    args+=(--set spotify.name drawing=on \
                 icon="󰓇" \
                 label="${TRACK}  ${ARTIST}  ${ALBUM}" \
           --set spotify.play icon=􀊆 \
           --set spotify.shuffle icon.highlight=$SHUFFLE \
           --set spotify.repeat icon.highlight=$REPEAT)
  else
    args+=(--set spotify.name drawing=off \
           --set spotify.name popup.drawing=off \
           --set spotify.play icon=􀊄)
  fi
  sketchybar -m "${args[@]}"
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    "spotify.play") play
    ;;
    "spotify.shuffle") shuffle
    ;;
    "spotify.repeat") repeat
    ;;
    *) exit
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "forced") exit ;;
  *) update ;;
esac
