#!/usr/bin/env bash

set -eu

export CLASS="Terminal"

function address() {
  echo $(hyprctl clients -j | jq -r '.[] | select(.class=="'"$CLASS"'") | .address' || true)
}

function allign-vertical() {
  local win=${1}

  local win_x=$(hyprctl clients -j | jq -r '.[] | select(.address=="'"$win"'") | .at[0]')
  local info=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | [.width, .height]')
  local width=$(echo "$info" | jq -r '.[0]')
  local height=$(echo "$info" | jq -r '.[1]')
  local offset=$(($height * 5 / 100))

  hyprctl dispatch movewindowpixel exact $win_x $offset,address:$win
}

WIN=$(address)

if [ -z "$WIN" ]; then
  TIMEOUT=2
  START=$(date +%s)

  uwsm app -- kitty --class "$CLASS" >/dev/null 2>&1 &
  while true; do
    WIN=$(address)
    if [ -n "$WIN" ]; then break; else sleep 0.02; fi

    NOW=$(date +%s)
    if ((NOW - START > TIMEOUT)); then echo "Terminal window did not appear in $TIMEOUT seconds!" && exit 1; fi
  done

  allign-vertical $WIN
  exit 0
fi

FOCUSED=$(hyprctl activewindow -j | jq -r '.address' || echo "")

if [ "$FOCUSED" = "$WIN" ]; then
  hyprctl dispatch movetoworkspacesilent special,address:$WIN
else
  CURWS=$(hyprctl activeworkspace -j | jq -r '.id')
  hyprctl dispatch movetoworkspacesilent $CURWS,address:$WIN
  allign-vertical $WIN
  hyprctl dispatch focuswindow address:$WIN
fi
