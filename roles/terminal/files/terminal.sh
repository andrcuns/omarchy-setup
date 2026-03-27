#!/usr/bin/env bash

set -eu

CLASS="Terminal"

CLIENTS=$(hyprctl clients -j)
WIN=$(echo "$CLIENTS" | jq -r '.[] | select(.class=="'"$CLASS"'") | .address' || true)

if [ -z "$WIN" ]; then
  TIMEOUT=2
  START=$(date +%s)

  uwsm app -- kitty --class "$CLASS" --single-instance >/dev/null 2>&1 &
  while true; do
    WIN=$(hyprctl clients -j | jq -r '.[] | select(.class=="'"$CLASS"'") | .address' || true)
    if [ -n "$WIN" ]; then break; else sleep 0.02; fi

    NOW=$(date +%s)
    if ((NOW - START > TIMEOUT)); then echo "Terminal window did not appear in $TIMEOUT seconds!" && exit 1; fi
  done

  MONITORS=$(hyprctl monitors -j)
  MON_COUNT=$(echo "$MONITORS" | jq 'length')

  read -r MON_X MON_Y MON_WIDTH MON_HEIGHT MON_SCALE RESERVED_TOP <<< \
    $(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | [.x, .y, .width, .height, .scale, .reserved[1]] | @tsv')

  GAP=$(($RESERVED_TOP + 4))

  if [ "$MON_COUNT" -gt 1 ]; then
    EFF_WIDTH=$(echo "$MON_WIDTH $MON_SCALE" | awk '{printf "%.0f", $1/$2}')
    EFF_HEIGHT=$(echo "$MON_HEIGHT $MON_SCALE" | awk '{printf "%.0f", $1/$2}')
    TERM_WIDTH=$(($EFF_WIDTH * 98 / 100))
    TERM_HEIGHT=$(($EFF_HEIGHT * 70 / 100))
    X=$(($MON_X + ($EFF_WIDTH - $TERM_WIDTH) / 2))
    Y=$(($MON_Y + $GAP))

    hyprctl --batch "dispatch resizewindowpixel exact $TERM_WIDTH $TERM_HEIGHT,address:$WIN ; dispatch movewindowpixel exact $X $Y,address:$WIN"
  else
    WIN_X=$(hyprctl clients -j | jq -r '.[] | select(.address=="'"$WIN"'") | .at[0]')
    hyprctl dispatch movewindowpixel exact $WIN_X $GAP,address:$WIN
  fi
  exit 0
fi

FOCUSED=$(hyprctl activewindow -j | jq -r '.address' || echo "")
WIN_MON=$(echo "$CLIENTS" | jq -r '.[] | select(.address=="'"$WIN"'") | .monitor')
MONITORS=$(hyprctl monitors -j)
FOCUSED_MON=$(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | .id')

if [ "$FOCUSED" = "$WIN" ] && [ "$WIN_MON" = "$FOCUSED_MON" ]; then
  hyprctl dispatch movetoworkspacesilent special,address:$WIN
else
  MON_COUNT=$(echo "$MONITORS" | jq 'length')

  read -r MON_X MON_Y MON_WIDTH MON_HEIGHT MON_SCALE RESERVED_TOP CURWS <<< \
    $(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | [.x, .y, .width, .height, .scale, .reserved[1], .activeWorkspace.id] | @tsv')

  GAP=$(($RESERVED_TOP + 4))

  if [ "$MON_COUNT" -gt 1 ]; then
    EFF_WIDTH=$(echo "$MON_WIDTH $MON_SCALE" | awk '{printf "%.0f", $1/$2}')
    EFF_HEIGHT=$(echo "$MON_HEIGHT $MON_SCALE" | awk '{printf "%.0f", $1/$2}')
    TERM_WIDTH=$(($EFF_WIDTH * 98 / 100))
    TERM_HEIGHT=$(($EFF_HEIGHT * 70 / 100))
    X=$(($MON_X + ($EFF_WIDTH - $TERM_WIDTH) / 2))
    Y=$(($MON_Y + $GAP))

    hyprctl --batch "dispatch movetoworkspacesilent $CURWS,address:$WIN ; dispatch resizewindowpixel exact $TERM_WIDTH $TERM_HEIGHT,address:$WIN ; dispatch movewindowpixel exact $X $Y,address:$WIN ; dispatch focuswindow address:$WIN"
  else
    WIN_X=$(echo "$CLIENTS" | jq -r '.[] | select(.address=="'"$WIN"'") | .at[0]')
    hyprctl --batch "dispatch movetoworkspacesilent $CURWS,address:$WIN ; dispatch movewindowpixel exact $WIN_X $GAP,address:$WIN ; dispatch focuswindow address:$WIN"
  fi
fi
