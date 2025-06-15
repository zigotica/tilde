#!/usr/bin/env bash

# Define space groups
WORK_SPACES=("Project" "Talk" "Web")
PERSONAL_SPACES=("Code" "Surf" "User")

# Event
sketchybar --add event aerospace_workspace_change

# Function to add a group of spaces
add_spaces_group() {
  local group_label="$1"
  local group_key=$(echo "$group_label" | tr '[:upper:]' '[:lower:]')
  local -a space_names=("${!2}") # Dereference the nameref to get the array

  # Add the group label item
  sketchybar --add item label."$group_key" left \
    --set label."$group_key" label="$group_label" icon.drawing=off \
          label.color="$SKBAR_COLOR_LABEL" \
          label.padding_left=8 \
          label.padding_right=8 \
          background.drawing=off

  # Add the individual space items for the group
  for sid in "${space_names[@]}"; do
    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
            background.color="$COLOR_GREEN" \
            background.corner_radius="$CORNER_RADIUS" \
            background.height="$SPACE_HEIGHT" \
            background.y_offset="$SPACE_BG_OFFSET" \
            background.drawing=off \
            label="$sid" \
            icon.padding_left=0 \
            icon.padding_right=0 \
            label.padding_left="$LABEL_PADDING" \
            label.padding_right="$LABEL_PADDING" \
            click_script="aerospace workspace $sid" \
            script="$ITEMS/spaces/plugin.sh $sid"
  done
}

# Add Workspaces - Work group
add_spaces_group "Work" WORK_SPACES[@]

# Add spacer between groups
sketchybar --add item spacer.personal left \
  --set spacer.personal width=16 \
  --set spacer.personal background.drawing=off

# Add Workspaces - Personal group
add_spaces_group "Personal" PERSONAL_SPACES[@]
