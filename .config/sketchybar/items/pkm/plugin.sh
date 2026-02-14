#!/usr/bin/env bash

set -euo pipefail

# -------------------------
# CONFIG
# -------------------------

declare -A ROOTS=(
  ["Work"]="$HOME/Documents/work"
  ["Personal"]="$HOME/Documents/personal"
)

VAULT_BASE="$HOME/Documents/personal/obsidian/pkm/calendar/daily"
TEMPLATE="$HOME/Documents/personal/obsidian/templates/calendar/day.md"

DATE="$(date +%F)"
YEAR="$(date +%Y)"
NOTE_DIR="$VAULT_BASE/$YEAR"
NOTE="$NOTE_DIR/$DATE.md"

SINCE="midnight"
mkdir -p "$NOTE_DIR"

TOTAL_COMMITS=0
WORK_LINES=""
PERSONAL_LINES=""

# -------------------------
# COLLECT COMMITS
# -------------------------

collect() {
  local label="$1"
  local root="$2"

  [[ -d "$root" ]] || return

  while IFS= read -r -d '' repo; do
    cd "$repo"

    # work/personal have different configs
    AUTHOR="$(git config user.email 2>/dev/null || true)"
    [[ -z "$AUTHOR" ]] && continue

    while IFS= read -r msg; do
      [[ -z "$msg" ]] && continue
      repo_name=$(basename "$repo")
      line="  - $repo_name: $msg"

      if [[ "$label" == "Work" ]]; then
        WORK_LINES+="$line"$'\n'
      else
        PERSONAL_LINES+="$line"$'\n'
      fi

      TOTAL_COMMITS=$((TOTAL_COMMITS + 1))
    done < <(
      git log \
        --since="$SINCE" \
        --author="$AUTHOR" \
        --pretty="%s" 2>/dev/null || true
    )

  done < <(
    find "$root" -type d -name ".git" -prune -print0 \
    | xargs -0 -I{} dirname {} \
    | tr '\n' '\0'
  )
}

for label in "${!ROOTS[@]}"; do
  collect "$label" "${ROOTS[$label]}"
done

# -------------------------
# NO COMMITS → UPDATE BAR
# -------------------------

if [[ "$TOTAL_COMMITS" -eq 0 ]]; then
  sketchybar --set "$NAME" label="0"
  exit 0
fi

# -------------------------
# CREATE NOTE IF NEEDED
# -------------------------

if [[ ! -f "$NOTE" ]]; then
  cp "$TEMPLATE" "$NOTE"

  replacement=""

  if [[ -n "$WORK_LINES" ]]; then
    replacement+="- Work"$'\n'"$WORK_LINES"
  fi

  if [[ -n "$PERSONAL_LINES" ]]; then
    replacement+="- Personal"$'\n'"$PERSONAL_LINES"
  fi

  perl -0777 -pe \
    "s/- <% tp\.file\.cursor\(\) %>/$replacement/" \
    -i "$NOTE"
fi

# -------------------------
# FUNCTION: insert with dedup
# -------------------------

insert_under_section() {
  local section="$1"
  local lines="$2"

  [[ -z "$lines" ]] && return

  new_lines=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! grep -Fqx "$line" "$NOTE"; then
      new_lines+="$line"$'\n'
    fi
  done <<< "$lines"

  [[ -z "$new_lines" ]] && return

  if grep -q "^- $section" "$NOTE"; then
    perl -0777 -pe "
      s/(^- $section[^\n]*\n)/\$1$new_lines/m
    " -i "$NOTE"
  else
    perl -0777 -pe "
      s/(# Notes.*?\n)/\$1- $section\n$new_lines/s
    " -i "$NOTE"
  fi
}

# -------------------------
# APPEND INSIDE SECTIONS
# -------------------------

insert_under_section "Work" "$WORK_LINES"
insert_under_section "Personal" "$PERSONAL_LINES"

# -------------------------
# UPDATE SKETCHYBAR LABEL
# -------------------------

sketchybar --set "$NAME" label="$TOTAL_COMMITS"

