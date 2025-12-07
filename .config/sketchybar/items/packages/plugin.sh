#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

# ----- DEBUG FLAG
DEBUG=0
LOG_FILE="$HOME/.config/sketchybar/items/packages/packages_debug.log"

log() {
  (( DEBUG )) && echo "$@" >> "$LOG_FILE"
}

info() {
  log "--- $(date) ---"

  # Set environment variables to prevent brew from doing hardware detection and auto-updates
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_INSTALL_CLEANUP=1
  export HOMEBREW_NO_ENV_HINTS=1

  # specify the package managers you want the program to use
  # valid manager names "brew" "mas" ...
  USE='brew mas'
  
  # Initialize variables
  BREW=0
  MAS=0
  BREW_COLOR="$COLOR_GREEN"
  MAS_COLOR="$COLOR_GREEN"

  log "Initial BREW: $BREW, MAS: $MAS"

  # Checks to see if the brew command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v brew)" ]] && [[ $USE == *"brew"* ]]; then

    # Use Ruby wrapper to properly initialize $CHILD_STATUS for Homebrew's hardware detection
    # Run the ruby wrapper within a clean `env -i` environment. This ensures that
    # brew runs in a pristine environment (fixing stale results) while also allowing
    # the ruby wrapper to prime the $CHILD_STATUS (fixing the 'success?' error).
    brewJSON=$(
      env -i \
        HOME="$HOME" \
        USER="$USER" \
        PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
        bash -c 'ruby "$HOME/.config/sketchybar/items/packages/brew_outdated_ruby.rb" 2>&1'
    )
    brew_exit_code=$?

    log "Exit Code: $brew_exit_code"
    log "Output (brewJSON):"
    log "$brewJSON"

    # clean result
    brewJSON=$(echo "$brewJSON" | awk '/^[[:space:]]*{/,0')
    log "Output cleanup:"
    log "$brewJSON"
  
    # Check if brew command failed or if output contains error messages
    if [[ $brew_exit_code -ne 0 ]] || [[ "$brewJSON" =~ ^Error: ]] || [[ "$brewJSON" =~ ^Please\ report ]] || [[ ! "$brewJSON" =~ ^\{ ]]; then
      BREW='666'
      BREW_COLOR="$COLOR_RED"
      log "BREW error: $brewJSON"
    else
      # Parse JSON output to count outdated packages
      # Count both formulae and casks
      if command -v jq &> /dev/null; then
        BREW=$(echo "$brewJSON" | jq '[.formulae[]?, .casks[]?] | length' 2>/dev/null || echo "0")
      else
        # Fallback: count "name" fields in JSON
        BREW=$(echo "$brewJSON" | grep -o '"name"' | wc -l | tr -d '[:space:]')
      fi
      
      if [[ -z "$BREW" ]] || [[ "$BREW" == "0" ]]; then
        BREW='0'
        BREW_COLOR="$COLOR_GREEN"
      else
        BREW_COLOR="$COLOR_YELLOW"
      fi
    fi
    BREW=$((BREW + 0))
  fi

  # Checks to see if the mas command is avaliable and the package manager is in the enabled list above.
  if [[ -x "$(command -v mas)" ]] && [[ $USE == *"mas"* ]]; then

    # runs the outdated command and stores the output as a list variable.
    local mas_cmd_output
    local mas_exit_code

    if command -v gtimeout &>/dev/null; then
      mas_cmd_output=$(gtimeout 10 mas outdated 2>&1)
      mas_exit_code=$?
    else
      mas_cmd_output=$(mas outdated 2>&1)
      mas_exit_code=$?
    fi

    # Check if command timed out (exit code 124 for gtimeout)
    if [[ "$mas_exit_code" -eq 124 ]]; then
      MAS=666 # Indicate timeout/error
      MAS_COLOR="$COLOR_RED"
      masLIST="output: $mas_cmd_output"
      log "MAS timeout: $masLIST"
    elif [[ "$mas_exit_code" -ne 0 ]]; then
      # Other errors from mas itself
      MAS=666
      MAS_COLOR="$COLOR_RED"
      masLIST="output: $mas_cmd_output"
      log "MAS failed: $masLIST"
    else
      # Command succeeded, process output
      masLIST=$(printf '%s\n' "$mas_cmd_output" | grep -v '^$')
      log "MAS succeeded: $masLIST"

      if [[ -z "$masLIST" ]] || [[ "$masLIST" =~ ^[[:space:]]*$ ]]; then
        MAS=0
        masLIST=""
        MAS_COLOR="$COLOR_GREEN"
      else
        MAS=$(printf '%s\n' "$masLIST" | grep -v '^[[:space:]]*$' | wc -l | tr -d '[:space:]')
        MAS=$((MAS + 0))
        MAS_COLOR="$COLOR_YELLOW"
      fi
    fi
  fi

  # sum of all outdated packages
  SUM=$(( ${BREW:-0} + ${MAS:-0} ))

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
      label="${BREW:-0}" \
    --set packages.mas \
      icon="" \
      icon.color="$MAS_COLOR" \
      label="${MAS:-0}"
}

mouse_entered() {
  sketchybar -m --set packages.total popup.drawing=on
}

mouse_exited() {
  sketchybar -m --set packages.total popup.drawing=off
}

update_brew() {
  open -a Terminal "$HOME/.config/sketchybar/items/packages/update.sh"
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

