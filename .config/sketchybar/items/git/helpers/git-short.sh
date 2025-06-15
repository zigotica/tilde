#!/usr/bin/env bash

# Simplified from https://github.com/zigotica/git-summary-and-backup/

MAIN_REMOTE="origin"
LAB_REMOTE="lab"
MAXDEPTH=1

script_args=()
while [ $OPTIND -le "$#" ]; do
  if getopts "bm:l:d:" option; then
    case $option in
      b) BACKUPABLE=1;;
      m) MAIN_REMOTE=${OPTARG};;
      l) LAB_REMOTE=${OPTARG};;
      d) MAXDEPTH=${OPTARG};;
    esac
  else
    script_args+=("${!OPTIND}")
    ((OPTIND++))
  fi
done

DIR="${script_args[@]}"
[[ -z "$DIR" ]] && DIR="$(pwd)"
[[ $DIR != */ ]] && DIR="$DIR/"

IFS=$'\n' read -d '' -r -a FOLDERS < <(find "$DIR" -maxdepth "$MAXDEPTH" -type d 2>/dev/null)

function count-commits-diff () {
  echo $(git rev-list $1..$2 --count 2>/dev/null) | xargs
}

function count-remote-branch () {
  echo $(git rev-parse --branches=refs/remotes --symbolic-full-name --all 2>/dev/null | grep "$1" | wc -l) | xargs
}

function get-branch () {
  echo $(git symbolic-ref --short HEAD 2>/dev/null)
}

repos_behind_main=0
repos_ahead_lab=0

repos_behind_main_names=()
repos_ahead_lab_names=()

for SUBDIR in "${FOLDERS[@]}"; do
  if [[ -d "$SUBDIR/.git" ]]; then
    cd "$SUBDIR"

    BRANCH="$(get-branch)"
    [[ -z "$BRANCH" ]] && continue

    HAS_MAIN_REMOTE="$(git remote | grep "$MAIN_REMOTE")"
    HAS_LAB_REMOTE="$(git remote | grep "$LAB_REMOTE")"

    REPO_NAME="$(basename "$SUBDIR")"

    # Behind main?
    if [[ -n "$HAS_MAIN_REMOTE" ]] && [[ $(count-remote-branch "$MAIN_REMOTE/$BRANCH") -gt 0 ]]; then
      BEHIND_MAIN=$(count-commits-diff "$BRANCH" "$MAIN_REMOTE/$BRANCH")
      if [[ "$BEHIND_MAIN" -gt 0 ]]; then
        repos_behind_main=$((repos_behind_main + 1))
        repos_behind_main_names+=("\"$REPO_NAME\"")
      fi
    fi

    # Ahead of lab?
    if [[ -n "$HAS_LAB_REMOTE" ]]; then
      if git show-ref --verify --quiet "refs/remotes/$LAB_REMOTE/$BRANCH"; then
        AHEAD_LAB=$(count-commits-diff "$LAB_REMOTE/$BRANCH" "$BRANCH")
      else
        AHEAD_LAB=1  # Remote branch missing → needs push
      fi

      if [[ "$AHEAD_LAB" -gt 0 ]]; then
        repos_ahead_lab=$((repos_ahead_lab + 1))
        repos_ahead_lab_names+=("\"$REPO_NAME\"")
      fi
    fi

  fi
done

# Output JSON
printf '{\n'
printf '  "behind_main": %d,\n' "$repos_behind_main"
printf '  "ahead_lab": %d,\n' "$repos_ahead_lab"
printf '  "behind_main_repos": [%s],\n' "$(IFS=,; echo "${repos_behind_main_names[*]}")"
printf '  "ahead_lab_repos": [%s]\n' "$(IFS=,; echo "${repos_ahead_lab_names[*]}")"
printf '}\n'

