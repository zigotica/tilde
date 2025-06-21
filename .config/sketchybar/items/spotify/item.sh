#!/usr/bin/env bash

# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1455842
# --add item name e (position right of the notch)
SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set \$NAME popup.drawing=toggle"

sketchybar --add       event           spotify_change $SPOTIFY_EVENT       \
           --add       item            spotify.name e                      \
           --set       spotify.name    click_script="$POPUP_SCRIPT"        \
                                       popup.horizontal=on                 \
                                       popup.align=center                  \
                                       popup.y_offset="$POPUP_OFFSET"      \
                                       icon.drawing=on                     \
                                       icon.font="$FONT:$ICON_SIZE"        \
                                       icon.color="$COLOR_GREEN"           \
                                       icon=""                             \
                                       label.max_chars=42                  \
                                       label.font="$ICON_FONT:$LABEL_SUB_SIZE"  \
                                       scroll_texts=on                     \
                                                                           \
           --add       item            spotify.back popup.spotify.name     \
           --set       spotify.back    icon=􀊎                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       script="$ITEMS/spotify/plugin.sh"   \
                                       label.drawing=off                   \
           --subscribe spotify.back    mouse.clicked                       \
                                                                           \
           --add       item            spotify.play popup.spotify.name     \
           --set       spotify.play    icon=􀊔                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       updates=on                          \
                                       label.drawing=off                   \
                                       script="$ITEMS/spotify/plugin.sh"   \
           --subscribe spotify.play    mouse.clicked spotify_change        \
                                                                           \
           --add       item            spotify.next popup.spotify.name     \
           --set       spotify.next    icon=􀊐                              \
                                       icon.padding_left=5                 \
                                       icon.padding_right=10               \
                                       label.drawing=off                   \
                                       script="$ITEMS/spotify/plugin.sh"   \
           --subscribe spotify.next    mouse.clicked                       \
                                                                           \
           --add       item            spotify.shuffle popup.spotify.name  \
           --set       spotify.shuffle icon=􀊝                              \
                                       icon.highlight_color="$COLOR_GREEN" \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       label.drawing=off                   \
                                       script="$ITEMS/spotify/plugin.sh"   \
           --subscribe spotify.shuffle mouse.clicked                       \
                                                                           \
           --add       item            spotify.repeat popup.spotify.name   \
           --set       spotify.repeat  icon=􀊞                              \
                                       icon.highlight_color="$COLOR_GREEN" \
                                       icon.padding_left=5                 \
                                       icon.padding_right=5                \
                                       label.drawing=off                   \
                                       script="$ITEMS/spotify/plugin.sh"   \
           --subscribe spotify.repeat  mouse.clicked
