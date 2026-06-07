#!/usr/bin/env bash

set -eu

CLASS="Terminal"
OUTER_GAP=3
BORDER_SIZE=2
TERM_HEIGHT_PERCENT=70
TOP_GAP=4

calculate_terminal_geometry() {
	local mon_x mon_y mon_width mon_height mon_scale reserved_top
	local eff_width eff_height width_offset

	read -r mon_x mon_y mon_width mon_height mon_scale reserved_top <<< \
		"$(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | [.x, .y, .width, .height, .scale, .reserved[1]] | @tsv')"

	eff_width=$(echo "$mon_width $mon_scale" | awk '{printf "%.0f", $1/$2}')
	eff_height=$(echo "$mon_height $mon_scale" | awk '{printf "%.0f", $1/$2}')
	width_offset=$((OUTER_GAP + BORDER_SIZE))

	TERM_WIDTH=$((eff_width - (width_offset * 2)))
	TERM_HEIGHT=$((eff_height * TERM_HEIGHT_PERCENT / 100))
	TERM_X=$((mon_x + width_offset))
	TERM_Y=$((mon_y + reserved_top + TOP_GAP))
}

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
	calculate_terminal_geometry

	hyprctl --batch "dispatch resizewindowpixel exact $TERM_WIDTH $TERM_HEIGHT,address:$WIN ; dispatch movewindowpixel exact $TERM_X $TERM_Y,address:$WIN"
	exit 0
fi

FOCUSED=$(hyprctl activewindow -j | jq -r '.address' || echo "")
WIN_MON=$(echo "$CLIENTS" | jq -r '.[] | select(.address=="'"$WIN"'") | .monitor')
MONITORS=$(hyprctl monitors -j)
FOCUSED_MON=$(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | .id')

if [ "$FOCUSED" = "$WIN" ] && [ "$WIN_MON" = "$FOCUSED_MON" ]; then
	hyprctl dispatch movetoworkspacesilent special,address:$WIN
else
	CURWS=$(echo "$MONITORS" | jq -r '.[] | select(.focused==true) | .activeWorkspace.id')
	calculate_terminal_geometry

	hyprctl --batch "dispatch movetoworkspacesilent $CURWS,address:$WIN ; dispatch resizewindowpixel exact $TERM_WIDTH $TERM_HEIGHT,address:$WIN ; dispatch movewindowpixel exact $TERM_X $TERM_Y,address:$WIN ; dispatch focuswindow address:$WIN"
fi
