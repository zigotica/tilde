#!/usr/bin/env bash

# Git sync/backup monitor
# 󰊢 ⇡ ⇣   󰳏 󱓎 -             

sketchybar -m --add       item             git.total right                        \
              --add       event            git_upgrade                            \
              --set       git.total        update_freq="$POLL_UPDATES_LONG"       \
                                           popup.horizontal=off                   \
                                           popup.align=center                     \
                                           popup.y_offset="$POPUP_OFFSET"         \
                                           label.font="$FONT:$LABEL_SUB_SIZE"     \
                                           script="$ITEMS/git/plugin.sh $ITEMS/git" \
                                           icon.font="$ICON_FONT:$ICON_SIZE_XL"   \
                                           icon="󰊢"                               \
                                           lazy=off                               \
              --subscribe git.total        git_upgrade                            \
                                           mouse.entered                          \
                                           mouse.exited                           \
                                           mouse.exited.global                    \
                                                                                  \
              --add       item             git.sync popup.git.total               \
              --set       git.sync         script="$ITEMS/git/plugin.sh $ITEMS/git" \
                                           label.font="$FONT:$LABEL_SUB_SIZE"     \
              --subscribe git.sync         mouse.clicked                          \
                                                                                  \
              --add       item             git.backup  popup.git.total            \
              --set       git.backup       script="$ITEMS/git/plugin.sh $ITEMS/git" \
                                           label.font="$FONT:$LABEL_SUB_SIZE"     \
              --subscribe git.backup       mouse.clicked

