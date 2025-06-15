#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"
brewLIST=""

info() {
  # specify the package managers you want the program to use
  # valid manager names "brew" "mas" ...
  USE='brew mas'

  # Checks to see if the brew command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v brew)" ]] && [[ $USE == *"brew"* ]]; then

    brew update &> /dev/null

    # runs the outdated command and stores the output as a list variable.
    brewLIST=$(brew outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $brewLIST == "" ]]; then
      BREW='0'
      brewLIST=""
      BREW_COLOR="$COLOR_GREEN"
    else
      BREW=$(echo "$brewLIST" | wc -l)
      BREW_COLOR="$COLOR_YELLOW"
    fi

  fi

  # Checks to see if the mas command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v mas)" ]] && [[ $USE == *"mas"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    masLIST=$(mas outdated)

    # checks to see if the returned list is empty. If so, it sets the outdated packages list to zero, if not, sets it to the line count of the list.
    if [[ $masLIST == "" ]]; then
      MAS='0'
      masLIST=""
      MAS_COLOR="$COLOR_GREEN"
    else
      MAS=$(echo "$masLIST" | wc -l)
      MAS_COLOR="$COLOR_YELLOW"
    fi

  fi

  DEFAULT="0"

  # sum of all outdated packages
  SUM=$(( ${BREW:-DEFAULT} + ${MAS:-DEFAULT} ))

  # icon to be displayed if no packages are outdated. Change to `ZERO=""` if you want the widget to be invisible when no packages are out of date. Default: ‚úîÔ∏é
  ZERO=""

  if [[ $SUM -gt 100 ]]; then
    FINAL="$SUM"
    COLOR="$COLOR_RED"
  elif [[ $SUM -gt 50 ]]; then
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
    --set packages.total \
      icon.color="$COLOR" \
      label="$FINAL" \
    --set packages.brew \
      icon="" \
      icon.color="$BREW_COLOR" \
      label="$(echo ${BREW:-DEFAULT} | awk '{$1=$1};1')" \
    --set packages.mas \
      icon="" \
      icon.color="$MAS_COLOR" \
      label="$(echo ${MAS:-DEFAULT} | awk '{$1=$1};1')"
}

mouse_entered() {
  sketchybar -m --set packages.total popup.drawing=on
}

mouse_exited() {
  sketchybar -m --set packages.total popup.drawing=off
}

update_brew() {
  osascript <<EOF
    tell application "Terminal"
      activate
      do script "brew update && brew upgrade && sketchybar -m --trigger pkg_upgrade"
    end tell
EOF
}

update_mas() {
  osascript <<EOF
    tell application "App Store" to activate
    delay 1
    tell application "System Events"
        keystroke "8" using command down
    end tell
EOF
}


mouse_clicked () {
  case "$NAME" in
    "packages.brew")
      update_brew
      sketchybar -m --set packages.total popup.drawing=off
      ;;
    "packages.mas")
      update_mas
      sketchybar -m --set packages.total popup.drawing=off
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

