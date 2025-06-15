#!/usr/bin/env bash
#
# git-backup
# Push local commits to lab remote for all git repos under a given directory
#
# Usage: git-backup [-l <lab remote>] [-d <maxdepth>] [path]
#
# Defaults:
#   LAB_REMOTE="lab"
#   MAXDEPTH=1
#

echo "BACKUP AHEAD LOCAL REPOS TO LAB SERVER" > ~/.config/sketchybar/items/git/helpers/_backup.log

LAB_REMOTE="lab"
MAXDEPTH=1

# Parse options
while getopts "l:d:" opt; do
  case $opt in
    l) LAB_REMOTE=$OPTARG ;;
    d) MAXDEPTH=$OPTARG ;;
  esac
done

# Directory positional arg after options
shift $((OPTIND -1))
DIR="${1:-$(pwd)}"

# Ensure DIR ends with /
[[ $DIR != */ ]] && DIR="$DIR/"

# Find subdirectories to maxdepth
IFS=$'\n' read -d '' -r -a FOLDERS < <(find "$DIR" -maxdepth "$MAXDEPTH" -type d && printf '\0')

# Helper functions
function get_branch() {
  git symbolic-ref --short HEAD 2>/dev/null || echo "detached"
}

function count_commits_diff() {
  git rev-list "$1".."$2" --count 2>/dev/null || echo 0
}

# Main loop
for repo in "${FOLDERS[@]}"; do
  if [[ -d "$repo/.git" ]]; then
    cd "$repo" || continue
    branch=$(get_branch)
    lab_remote_branch="$LAB_REMOTE/$branch"

    # Skip if branch is detached or remote branch doesn't exist
    if [[ "$branch" == "detached" ]]; then
      echo "[SKIP] $repo (detached HEAD)"
      continue
    fi

    # Check if lab remote exists and branch exists on lab remote
    if git remote | grep -q "^$LAB_REMOTE$"; then
      if git show-ref --verify --quiet "refs/remotes/$lab_remote_branch"; then
        ahead=$(count_commits_diff "$lab_remote_branch" "$branch")
      else
        # Remote branch doesn't exist, so push is needed
        ahead=1
      fi
    else
      echo "[SKIP] $repo (no remote $LAB_REMOTE)"
      continue
    fi

    if [[ $ahead -gt 0 ]]; then
      echo "[PUSH] $repo on branch $branch (ahead by $ahead commits)" >> ~/.config/sketchybar/items/git/helpers/_backup.log
      # Push with no-verify to skip hooks, per original script
      git push --no-verify "$LAB_REMOTE" "$branch" --quiet >> ~/.config/sketchybar/items/git/helpers/_backup.log
      if [[ $? -eq 0 ]]; then
        echo "  Pushed successfully."
      else
        echo "  Push failed."
      fi
    else
      echo "[UP-TO-DATE] $repo on branch $branch"
    fi
  fi
done

