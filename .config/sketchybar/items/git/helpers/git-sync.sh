#!/usr/bin/env bash
#
# git-sync
# Pull updates from main remote for all git repos under a given directory
#
# Usage: git-sync [-m <main remote>] [-d <maxdepth>] [path]
#
# Defaults:
#   MAIN_REMOTE="origin"
#   MAXDEPTH=1
#

echo "CALLED SYNC" > ~/.config/sketchybar/items/git/helpers/_sync.log

MAIN_REMOTE="origin"
MAXDEPTH=1

# Parse options
while getopts "m:d:" opt; do
  case $opt in
    m) MAIN_REMOTE=$OPTARG ;;
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

function is_worktree_clean() {
  # Returns 0 if clean, 1 otherwise
  git diff --quiet && git diff --cached --quiet
}

# Main loop
for repo in "${FOLDERS[@]}"; do
  if [[ -d "$repo/.git" ]]; then
    cd "$repo" || continue
    branch=$(get_branch)
    main_remote_branch="$MAIN_REMOTE/$branch"

    # Skip if branch is detached or remote branch doesn't exist
    if [[ "$branch" == "detached" ]] || ! git show-ref --verify --quiet "refs/remotes/$main_remote_branch"; then
      echo "[SKIP] $repo (branch: $branch, no $main_remote_branch)"
      continue
    fi

    behind=$(count_commits_diff "$branch" "$main_remote_branch")
    if [[ $behind -gt 0 ]] && is_worktree_clean; then
      echo "[PULL] $repo on branch $branch (behind by $behind commits)" >> ~/.config/sketchybar/items/git/helpers/_sync.log
      git pull "$MAIN_REMOTE" "$branch" --quiet >> ~/.config/sketchybar/items/git/helpers/_sync.log
      if [[ $? -eq 0 ]]; then
        echo "  Pulled successfully."
      else
        echo "  Pull failed."
      fi
    else
      echo "[UP-TO-DATE] $repo on branch $branch"
    fi
  fi
done

