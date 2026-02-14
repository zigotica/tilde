#!/usr/bin/env bash

set -euo pipefail

# -------------------------
# CONFIG
# -------------------------

WORK_ROOT="$HOME/Documents/work"
PERSONAL_ROOT="$HOME/Documents/personal"
VAULT_ROOT="$PERSONAL_ROOT/obsidian"
TEMPLATE="$VAULT_ROOT/templates/calendar/day.md"
TARGET_FILE="${0%/*}/_target.txt"

today=$(date +%F)
DATE="$today"
YEAR=$(date +%Y)
NOTE_DIR="$VAULT_ROOT/pkm/calendar/daily/$YEAR"
NOTE="$NOTE_DIR/$DATE.md"

mkdir -p "$NOTE_DIR"

TOTAL_COMMITS=0
WORK_LINES=""
PERSONAL_LINES=""

# -------------------------
# Find repos modified today
# -------------------------

find_modified_repos() {
  local label="$1"
  local root="$2"
  local depth="$3"
  
  find "$root" -maxdepth "$depth" -name .git -type d 2>/dev/null | while read -r gitdir; do
    repo="${gitdir%/.git}"
    if [[ -n $(find "$gitdir/refs/heads" -type f -newermt "$today" 2>/dev/null | head -1) ]]; then
      echo "$label|$repo"
    fi
  done
}

: > "$TARGET_FILE"

[[ -d "$WORK_ROOT" ]] && find_modified_repos "Work" "$WORK_ROOT" "3" > "$TARGET_FILE"
[[ -d "$PERSONAL_ROOT" ]] && find_modified_repos "Personal" "$PERSONAL_ROOT" "2" >> "$TARGET_FILE"
# reduce the depth for personal projects for speed, then add individual modules
[[ -d "$VAULT_ROOT" ]] && find_modified_repos "Personal" "$VAULT_ROOT" "2" >> "$TARGET_FILE"

# -------------------------
# CLICK HANDLER
# -------------------------

if [[ "${1:-}" == "open" ]]; then
  osascript <<'EOF'
tell application "Obsidian" to activate
delay 1
tell application "System Events"
  keystroke "d" using {command down}
end tell
EOF
  exit 0
fi

# -------------------------
# COLLECT COMMITS
# -------------------------

if [[ -f "$TARGET_FILE" ]]; then
  while IFS='|' read -r label repo; do
    [[ -z "$label" || -z "$repo" ]] && continue
    [[ -d "$repo" ]] || continue
    
    cd "$repo"
    # work/personal have different configs
    AUTHOR="$(git config user.email 2>/dev/null || true)"
    [[ -z "$AUTHOR" ]] && continue
    
    while IFS='|' read -r hash msg; do
      [[ -z "$msg" ]] && continue
      repo_name=$(basename "$repo")
      if [[ "$label" == "Work" ]]; then
        WORK_LINES+="  - $repo_name: (${hash:0:8}) $msg"$'\n'
      else
        PERSONAL_LINES+="  - $repo_name: (${hash:0:8}) $msg"$'\n'
      fi
      TOTAL_COMMITS=$((TOTAL_COMMITS + 1))
    done < <(git log --since="midnight" --author="$AUTHOR" --pretty="%h|%s" 2>/dev/null)
  done < "$TARGET_FILE"
fi

# -------------------------
# NO COMMITS → UPDATE BAR
# -------------------------

rm -f "$TARGET_FILE"

if [[ "$TOTAL_COMMITS" -eq 0 ]]; then
  sketchybar --set "$NAME" label="0"
  exit 0
fi

# -------------------------
# UPDATE SKETCHYBAR LABEL
# -------------------------

sketchybar --set "$NAME" label="$TOTAL_COMMITS"

# -------------------------
# CREATE NOTE IF NEEDED
# -------------------------

if [[ ! -f "$NOTE" ]]; then
  cp "$TEMPLATE" "$NOTE"
  perl -pi -e "s/<%tp\.date\.now\(\"YYYY-MM-DD\"\)%>/$DATE/g" "$NOTE"
  
  replacement=""
  [[ -n "$WORK_LINES" ]] && replacement+="- Work"$'\n'"$WORK_LINES"
  [[ -n "$PERSONAL_LINES" ]] && replacement+="- Personal"$'\n'"$PERSONAL_LINES"
  
  perl -0777 -pe "s/- <% tp\.file\.cursor\(\) %>/$replacement/" -i "$NOTE"
fi

# -------------------------
# FUNCTION: insert with dedup
# -------------------------

insert_under_section() {
  local section="$1"
  local lines="$2"
  [[ -z "$lines" ]] && return
  
  local new_lines=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    grep -Fqx "$line" "$NOTE" || new_lines+="$line"$'\n'
  done <<< "$lines"
  
  [[ -z "$new_lines" ]] && return
  
  if grep -q "^- $section" "$NOTE"; then
    perl -0777 -i -pe 's/(^- '"$section"'[^\n]*\n)/$1'"$new_lines"'/m' "$NOTE"
  else
    perl -0777 -i -pe 's/(# Notes.*?\n)/$1- '"$section"'\n'"$new_lines"'/s' "$NOTE"
  fi
}

# -------------------------
# APPEND INSIDE SECTIONS
# -------------------------

insert_under_section "Work" "$WORK_LINES"
insert_under_section "Personal" "$PERSONAL_LINES"

