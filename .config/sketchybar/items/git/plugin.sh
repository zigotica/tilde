#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

info() {
  DATA=$($HOME/.config/sketchybar/items/git/helpers/git-short.sh $HOME/Documents/ -d 3)
  SYNC=$(echo "$DATA" | jq '.behind_main')
  BACKUP=$(echo "$DATA" | jq '.ahead_lab')
  DEFAULT="0"

  # sum of all outdated git
  SUM=$(( ${SYNC:-DEFAULT} + ${BACKUP:-DEFAULT} ))
  ZERO=""

  if [[ $SYNC -gt 5 ]]; then
    SYNC_COLOR="$COLOR_RED"
  elif [[ $SUM -gt 2 ]]; then
    SYNC_COLOR="$COLOR_ORANGE"
  elif [[ $SUM -gt 0 ]]; then
    SYNC_COLOR="$COLOR_YELLOW"
  else
    SYNC_COLOR="$COLOR_GREEN"
  fi

  if [[ $BACKUP -gt 5 ]]; then
    BACKUP_COLOR="$COLOR_RED"
  elif [[ $SUM -gt 2 ]]; then
    BACKUP_COLOR="$COLOR_ORANGE"
  elif [[ $SUM -gt 0 ]]; then
    BACKUP_COLOR="$COLOR_YELLOW"
  else
    BACKUP_COLOR="$COLOR_GREEN"
  fi

  if [[ $SUM -gt 10 ]]; then
    FINAL="$SUM"
    COLOR="$COLOR_RED"
  elif [[ $SUM -gt 5 ]]; then
    FINAL="$SUM"
    COLOR="$COLOR_ORANGE"
  elif [[ $SUM -gt 0 ]]; then
    FINAL="$SUM"
    COLOR="$COLOR_YELLOW"
  else
    FINAL="$ZERO"
    COLOR="$COLOR_GREEN"
  fi

  sketchybar -m \
    --set git.total \
      icon.color="$COLOR" \
      label="$FINAL" \
    --set git.sync \
      icon="⇣" \
      icon.color="$SYNC_COLOR" \
      label="MAIN AHEAD: $(echo ${SYNC:-DEFAULT} | awk '{$1=$1};1')" \
    --set git.backup \
      icon="⇡" \
      icon.color="$BACKUP_COLOR" \
      label="LAB BEHIND: $(echo ${BACKUP:-DEFAULT} | awk '{$1=$1};1')"
}

mouse_entered() {
  sketchybar -m --set git.total popup.drawing=on
}

mouse_exited() {
  sketchybar -m --set git.total popup.drawing=off
}

update_sync() {
  # Pending action
  echo "Updating sync..."
  $HOME/.config/sketchybar/items/git/helpers/git-sync.sh -d 3 $HOME/Documents/
  sketchybar -m --trigger git_upgrade
  echo "Triggered git_upgrade" >> ~/.config/sketchybar/items/git/helpers/_sync.log
}

update_backup() {
  # Pending action
  echo "Updating backup..."
  $HOME/.config/sketchybar/items/git/helpers/git-backup.sh -d 3 $HOME/Documents/
  sketchybar -m --trigger git_upgrade
  echo "Triggered git_upgrade" >> ~/.config/sketchybar/items/git/helpers/_backup.log
}


mouse_clicked () {
  case "$NAME" in
    "git.sync")
      update_sync
      sketchybar -m --set git.total popup.drawing=off
      ;;
    "git.backup")
      update_backup
      sketchybar -m --set git.total popup.drawing=off
      ;;
    *)
      ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited") mouse_exited ;;
  *) info ;;
esac

