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
    
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    [[ "$current_branch" != "main" && "$current_branch" != "master" && "$current_branch" != "develop" ]] && continue

    while IFS='|' read -r hash msg; do
      [[ -z "$msg" ]] && continue
      repo_name=$(basename "$repo")
      if [[ "$label" == "Work" ]]; then
        WORK_LINES+="- [x] ${hash:0:8}: $repo_name - $msg"$'\n'
      else
        PERSONAL_LINES+="- [x] ${hash:0:8}: $repo_name - $msg"$'\n'
      fi
      TOTAL_COMMITS=$((TOTAL_COMMITS + 1))
    done < <(git log --first-parent --reverse --since="midnight" --author="$AUTHOR" --abbrev=8 --pretty="%h|%s" 2>/dev/null)
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

insert_under_section() {
  local section="$1"
  local lines="$2"
  [[ -z "$lines" ]] && return
  
  local new_lines=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    hash=$(echo "$line" | cut -d' ' -f3 | tr -d ':')
    [[ ${#hash} -ge 7 ]] || continue
    if grep -q "$hash:" "$NOTE"; then
      :
    else
      new_lines+=("$line")
    fi
  done <<< "$lines"
  
  [[ ${#new_lines[@]} -eq 0 ]] && return
  
  local tmp="$NOTE.tmp"
  > "$tmp"
  local in_section=0
  local section_buffer=()
  
  while IFS= read -r note_line; do
    if [[ "$note_line" == "## $section" ]]; then
      in_section=1
      echo "$note_line" >> "$tmp"
    elif [[ $in_section -eq 1 && ( "$note_line" == "##"* || "$note_line" == "<% tp.file.cursor() %>" || "$note_line" == "---" ) ]]; then
      while [[ ${#section_buffer[@]} -gt 0 && -z "${section_buffer[-1]}" ]]; do
        unset 'section_buffer[-1]'
      done
      for buf in "${section_buffer[@]}"; do
        echo "$buf" >> "$tmp"
      done
      for nl in "${new_lines[@]}"; do
        echo "$nl" >> "$tmp"
      done
      echo "" >> "$tmp"
      new_lines=()
      section_buffer=()
      in_section=0
      echo "$note_line" >> "$tmp"
    elif [[ $in_section -eq 1 ]]; then
      section_buffer+=("$note_line")
    else
      echo "$note_line" >> "$tmp"
    fi
  done < "$NOTE"
  
  if [[ ${#new_lines[@]} -gt 0 ]]; then
    while [[ ${#section_buffer[@]} -gt 0 && -z "${section_buffer[-1]}" ]]; do
      unset 'section_buffer[-1]'
    done
    for buf in "${section_buffer[@]}"; do
      echo "$buf" >> "$tmp"
    done
    for nl in "${new_lines[@]}"; do
      echo "$nl" >> "$tmp"
    done
  fi
  
  mv "$tmp" "$NOTE"
}

if [[ ! -f "$NOTE" ]]; then
  cp "$TEMPLATE" "$NOTE"
  sed -i '' "s/<%tp\.date\.now(\"YYYY-MM-DD\")%>/$DATE/g" "$NOTE"
  
  tmp="$NOTE.tmp"
  > "$tmp"
  while IFS= read -r note_line; do
    echo "$note_line" >> "$tmp"
    if [[ "$note_line" == "## Work" ]]; then
      echo -n "$WORK_LINES" >> "$tmp"
    elif [[ "$note_line" == "## Personal" ]]; then
      echo -n "$PERSONAL_LINES" >> "$tmp"
    fi
  done < "$NOTE"
  mv "$tmp" "$NOTE"
else
  insert_under_section "Work" "$WORK_LINES"
  insert_under_section "Personal" "$PERSONAL_LINES"
fi
