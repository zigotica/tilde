#!/usr/bin/env bash

function icon_map() {
  case "$1" in
  "Figma")
    icon_result=":figma:"
    ;;
  "Alacritty" | "Hyper" | "iTerm2" | "kitty" | "Terminal" | "WezTerm" | "Ghostty")
    icon_result=":terminal:"
    ;;
  "App Store")
    icon_result=":app_store:"
    ;;
  "Discord" | "Discord Canary" | "Discord PTB")
    icon_result=":discord:"
    ;;
  "Telegram")
    icon_result=":telegram:"
    ;;
  "1Password")
    icon_result=":one_password:"
    ;;
  "Dropbox")
    icon_result=":dropbox:"
    ;;
  "Reminders")
    icon_result=":reminders:"
    ;;
  "Finder")
    icon_result=":finder:"
    ;;
  "Notes")
    icon_result=":notes:"
    ;;
  "Code" | "Code - Insiders")
    icon_result=":code:"
    ;;
  "Chromium" | "Google Chrome" | "Google Chrome Canary")
    icon_result=":google_chrome:"
    ;;
  "Firefox")
    icon_result=":firefox:"
    ;;
  "Slack")
    icon_result=":slack:"
    ;;
  "Spotify")
    icon_result=":spotify:"
    ;;
  "Neovide" | "MacVim" | "Vim" | "VimR")
    icon_result=":vim:"
    ;;
  "KeePassXC")
    icon_result=":kee_pass_x_c:"
    ;;
  "Pages")
    icon_result=":pages:"
    ;;
  "VLC")
    icon_result=":vlc:"
    ;;
  "Calendar")
    icon_result=":calendar:"
    ;;
  "Safari" | "Safari Technology Preview")
    icon_result=":safari:"
    ;;
  "Xcode")
    icon_result=":xcode:"
    ;;
  "Numbers")
    icon_result=":numbers:"
    ;;
  "zoom.us")
    icon_result=":zoom:"
    ;;
  "VSCodium")
    icon_result=":vscodium:"
    ;;
  "Firefox Developer Edition" | "Firefox Nightly")
    icon_result=":firefox_developer_edition:"
    ;;
  "Docker" | "Docker Desktop")
    icon_result=":docker:"
    ;;
  "Bitwarden")
    icon_result=":bit_warden:"
    ;;
  "Obsidian")
    icon_result=":obsidian:"
    ;;
  "FaceTime")
    icon_result=":face_time:"
    ;;
  "Microsoft Teams")
    icon_result=":microsoft_teams:"
    ;;
  "Bear")
    icon_result=":bear:"
    ;;
  "System Preferences" | "System Settings")
    icon_result=":gear:"
    ;;
  "WhatsApp")
    icon_result=":whats_app:"
    ;;
  *)
    icon_result=":default:"
    ;;
  esac
}

icon_map "$1"

echo "$icon_result"
