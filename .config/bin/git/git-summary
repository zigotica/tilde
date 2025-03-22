#!/usr/bin/env bash

# git-summary-and-backup
# 
# Summarize git repos status at given path respect two remotes:
#   MAIN_REMOTE: default origin (normally github)
#   LAB_REMOTE: default lab (normaly self-hosted server)
# Allows to search repos in subfolders, using optional maxdepth
# Optionally allows to batch push/pull to/from main/lab remotes.
# Shows sync progress in same line as each repo summary
#
# Requirements: xargs, wc, grep
#
# usage: git-summary [-b] [-m <main remote>] [-l <lab remote>] [-d <maxdepth>] [parent to repos' subfolders]
#        git-summary [parent to repos' subfolders] [-b] [-m <main remote>] [-l <lab remote>] [-d <maxdepth>]
#        (or any order combination, https://stackoverflow.com/a/63421397)
#
# Created by zigotica, inspired from:
# https://github.com/MirkoLedda/git-summary/blob/master/git-summary
# and https://gist.github.com/mzabriskie/6631607


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

# No directory has been provided, use current
[[ -z "$DIR" ]] && DIR="$(pwd)"

# Make sure directory/ies end with "/"
[[ $DIR != */ ]] && DIR="$DIR/"

# Build array of directories using find and default/specified maxdepth
IFS=$'\n' read -d '' -r -a FOLDERS < <(find "$DIR" -maxdepth "$MAXDEPTH" -type d)

# Spinner icon positions (will be animated)
spinner=( '|' '/' '-' '\' );

# Colors
RED="$(tput setaf 1)"
GRN="$(tput setaf 2)"
YEL="$(tput setaf 3)"
PRL="$(tput setaf 5)"
CYN="$(tput setaf 6)"
RST="$(tput sgr0)"

# Utility to return parent folder and project name
function folder_project () {
  BN=$(basename $1)
  PT=$(basename ${1%/*})
  echo "[${PT}] ${BN}"
}

# git helpers
function count-commits-diff () {
  echo $(git rev-list $1..$2 --count) | xargs
}

function count-remote-branch () {
  echo $(git rev-parse --branches=refs/remotes --symbolic-full-name --all | grep $1 | wc -l) | xargs
}

function count-staged () {
  echo $(git diff --cached --name-only | wc -l) | xargs
}

function count-unstaged () {
  echo $(git diff --name-status | wc -l) | xargs
}

function get-branch () {
echo $(git symbolic-ref --short HEAD)
}

# Variables to track logic for each repo in the loop
function reset_vars () {
  WT_CLEAN=""
  MAIN_PULL_PENDING=""
  MAIN_PUSH_PENDING=""
  BACKUP_PENDING=""
}
reset_vars

function updater () {
  upd="$1"
  PROJECT=$(folder_project $upd)

  cd "$upd"
  BRANCH="$(get-branch)"

  # Add a slice of drama using short delays
  if [[ $BACKUPABLE -eq 1 ]]; then
    # PULL FROM MAIN IF BEHIND MAIN AND CLEAN WORKTREE
    if [[ -n $MAIN_PULL_PENDING ]] && [[ -n $WT_CLEAN ]]; then
      colored-task "Update $PROJECT" "git pull $MAIN_REMOTE $BRANCH -q"
      sleep 0.25
    fi

    # PUSH TO MAIN IF AHEAD
    if [[ -n $MAIN_PUSH_PENDING ]]; then
      colored-task "Update $PROJECT" "git push $MAIN_REMOTE $BRANCH -q"
      sleep 0.25
    fi

    if [[ -n $BACKUP_PENDING ]]; then
      # push while skipping pre-push hook
      colored-task "Backup $PROJECT" "git push --no-verify $LAB_REMOTE HEAD -q"
      sleep 0.25
    fi
  fi
}

function get_repo_info () {
  SUBDIR=$1
  cd $SUBDIR
  PROJECT=$(folder_project $SUBDIR)
  BRANCH="$(get-branch)"
  ICON_OK="OK"
  ICON_MISS="MISS"
  ICON_BEHIND='BEHIND'
  ICON_AHEAD='AHEAD'
  ICON_AHEADBEHIND='AH/BE'
  ICON_WAIT='WAIT'
  ICON_STAGED='+'
  ICON_CHANGED='?'
  COL1="${PROJECT}"
  COL2="${BRANCH}"
  COL3=" "
  COL4="${ICON_MISS}"
  COL5="${ICON_MISS}"
  # Default colors for each column
  COL3COL="GRN"
  COL4COL="RED"
  COL5COL="RED"

  # Column 2, local info
  # Check for staged files
  STAGED_COUNT=$(count-staged)
  if [[ $STAGED_COUNT -gt 0 ]]; then
    [[ $COL3 == " " ]] && COL3=""
    COL3+="${ICON_STAGED}(${STAGED_COUNT})"
  fi

  # Check for unstaged files
  CHANGED_COUNT=$(count-unstaged)
  if [[ $CHANGED_COUNT -gt 0 ]]; then
    [[ $COL3 == " " ]] && COL3=""
    COL3+="${ICON_CHANGED}(${CHANGED_COUNT})"
  fi

  # Check if everything is updated locally and prepend color
  if [[ $COL3 != " " ]]; then
    COL3COL="YEL"
    COL3="${COL3}"
  else
    COL3="${ICON_OK}"
    # logic for syncable
    WT_CLEAN=1
  fi

  # Column 4, main remote info
  HAS_MAIN_REMOTE="$(git remote | grep $MAIN_REMOTE)"
  if [[ -n $HAS_MAIN_REMOTE ]]; then
    # If $MAIN_REMOTE/$BRANCH exists
    if [[ $(count-remote-branch "$MAIN_REMOTE/$BRANCH") -gt 0 ]]; then
      # Check for unpulled changes from $MAIN_REMOTE (BEHIND_MAIN)
      BEHIND_MAIN=$(count-commits-diff "$BRANCH" "$MAIN_REMOTE/$BRANCH")
      AHEAD_MAIN=$(count-commits-diff "$MAIN_REMOTE/$BRANCH" "$BRANCH")

      if [[ $BEHIND_MAIN -gt 0 ]] && [[ $AHEAD_MAIN -gt 0 ]]; then
        # if ahead and behind main, report and expect manual intervention
        COL4COL="PRL"
        COL4="${ICON_AHEADBEHIND}(${AHEAD_MAIN}/${BEHIND_MAIN})"
      else
        if [[ $BEHIND_MAIN -gt 0 ]]; then
          COL4COL="YEL"
          COL4="${ICON_BEHIND}(${BEHIND_MAIN})"
          if [[ -n $WT_CLEAN ]]; then
            # logic for syncable
            MAIN_PULL_PENDING=1
          fi
        fi
        if [[ $AHEAD_MAIN -gt 0 ]]; then
          COL4COL="YEL"
          COL4="${ICON_AHEAD}(${AHEAD_MAIN})"
          # logic for syncable
          MAIN_PUSH_PENDING=1
        fi
        if [[ $COL4COL != "YEL" ]]; then
          COL4COL="GRN"
          COL4="${ICON_OK}"
        fi
      fi
    fi
  fi

  # Column 5, lab remote info
  HAS_LAB_REMOTE="$(git remote | grep $LAB_REMOTE)"
  if [[ -n $HAS_LAB_REMOTE ]]; then
    # If $LAB_REMOTE/$BRANCH exists
    if [[ $(count-remote-branch "$LAB_REMOTE/$BRANCH") -gt 0 ]]; then
      # Check for unpushed changes to $LAB_REMOTE (AHEAD_LAB)
      BEHIND_LAB=$(count-commits-diff "$BRANCH" "$LAB_REMOTE/$BRANCH")
      AHEAD_LAB=$(count-commits-diff "$LAB_REMOTE/$BRANCH" "$BRANCH")

      if [[ $BEHIND_MAIN -gt 0 ]] && [[ $AHEAD_MAIN -gt 0 ]]; then
        # if ahead and behind main, report and expect manual intervention
        COL5COL="PRL"
        COL5="${ICON_WAIT}(?)"
      else
        if [[ $AHEAD_LAB -gt 0 ]]; then
          COL5COL="YEL"
          COL5="${ICON_AHEAD}(${AHEAD_LAB})"
          # logic for syncable
          BACKUP_PENDING=1
        elif [[ $COL4 == ${ICON_BEHIND}* ]]; then
          # If repo is behind main, it will also be ahead lab when pulled
          COL5COL="YEL"
          COL5="${ICON_WAIT}(?)"
          if [[ -n $WT_CLEAN ]]; then
            # logic for syncable
            BACKUP_PENDING=1
          fi
        else
          COL5COL="GRN"
          COL5="${ICON_OK}"
        fi
      fi
    else
      COL5COL="YEL"
      # $LAB_REMOTE/$BRANCH combination does not exist
      # logic for syncable
      BACKUP_PENDING=1
    fi
  fi

  # TRICK: to avoid colored chars to be misleading the printf cols lenght,
  # put them around the lenght of the columns definition,
  # instead of passing them inside the column values.
  # Store the line so we can use it inside the printf of the colored-task function
  # This uses 4ch less on the left column to account for the final progress, and a new line
  REPOLINE=$(printf "${CYN}%-51s${RST} %-15s ${!COL3COL}%-12s${RST} ${!COL4COL}%-12s${RST} ${!COL5COL}%-12s${RST}\n" "${COL1}" "${COL2}" "${COL3}" "${COL4}" "${COL5}")
  if [[ $BACKUPABLE -eq 1 ]]; then
    printf "${CYN}%-55s${RST} %-15s ${!COL3COL}%-12s${RST} ${!COL4COL}%-12s${RST} ${!COL5COL}%-12s${RST}" "    ${COL1}" "${COL2}" "${COL3}" "${COL4}" "${COL5}"
  fi
}

# Print table headers
printf "%-55s %-15s %-12s %-12s %-12s\n" \
  "Repositories" "Branch" "Local" "Work" "Lab"
printf "%-55s %-15s %-12s %-12s %-12s\n" \
  "--------------------------------------------------" "----------" "----------" "----------" "----------"

# Loop all sub-directories
for SUBDIR in ${FOLDERS[@]}; do
  # Only want to parse git repositories
  if [[ -d "$SUBDIR/.git" ]]; then
    get_repo_info $SUBDIR

    cd "$SUBDIR"
    
    # update trap, hide stdout, show stderr in red
    # some git commands show info as stderr, avoid them using -q
    eval "updater $SUBDIR" \
      1> /dev/null \
      2> >(while read line; do echo -e "\n${RED}$line${RST}" >&2; done) \
      &

    # Save the PID of last command run in background to a variable
    pid=$!

    # kill eventual running process when script exits
    trap "kill $pid 2> /dev/null" EXIT

    # Print a spinner in current line while process is running
    while ps -p $pid &>/dev/null; do
      for i in ${spinner[@]}; do
        # Artificially wait for the spinner to be animated
        sleep 0.025;
        if ps -p $pid >/dev/null; then
          # If process still running after sleep, print spinner
          printf "\r${YEL}[$i";
        else
          # Otherwise, clean up line
          printf "\r";
        fi
      done;
    done

    # wait for the process to complete and return its exit status
    wait $pid

    if [[ $? == 0 ]]; then
      # If exit success, re-parse to print green check and msg with updated status in previous line
      get_repo_info $SUBDIR
      printf "\r${GRN}[] %s${RST}\n" "$REPOLINE"
    else
      # Otherwise, print red error icon and message in previous line
      printf "\r${RED}[] %s${RST}\n" "$REPOLINE"
      # Exit the script
      exit 1
    fi

    # Reset variables to track logic for each repo in the loop
    reset_vars
  fi
done

