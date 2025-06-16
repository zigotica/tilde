#!/usr/bin/env bash

# Add packages monitor
# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1559843
#   󰆧 󰏗 󱧖

sketchybar -m --add       item             packages.total right                   \
              --add       event            pkg_upgrade                            \
              --set       packages.total   update_freq="$POLL_UPDATES_LONG"       \
                                           popup.horizontal=on                    \
                                           popup.align=center                     \
                                           popup.y_offset="$POPUP_OFFSET"         \
                                           script="$ITEMS/packages/plugin.sh"     \
                                           icon=""                               \
                                           label.font="$FONT:$LABEL_SUB_SIZE"     \
                                           lazy=off                               \
              --subscribe packages.total   pkg_upgrade                            \
                                           mouse.entered                          \
                                           mouse.exited                           \
                                           mouse.exited.global                    \
                                                                                  \
              --add       item             packages.brew popup.packages.total     \
              --set       packages.brew    script="$ITEMS/packages/plugin.sh"     \
              --subscribe packages.brew    mouse.clicked                          \
                                                                                  \
              --add       item             packages.mas  popup.packages.total     \
              --set       packages.mas     script="$ITEMS/packages/plugin.sh"     \
              --subscribe packages.mas     mouse.clicked
