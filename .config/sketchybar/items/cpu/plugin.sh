#!/usr/bin/env bash

source "$HOME/.config/sketchybar/vars.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")

PERCENTAGE="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

case ${PERCENTAGE} in
  9[0-9]|100) COLOR="$COLOR_RED" ;;
  [6-8][0-9]) COLOR="$COLOR_ORANGE" ;;
  [3-5][0-9]) COLOR="$COLOR_YELLOW" ;;
  [1-2][0-9]) COLOR="$COLOR_GREEN" ;;
  *) COLOR="$COLOR_GREEN" ;;
esac

sketchybar --set $NAME label="$PERCENTAGE%" label.color="$COLOR"
