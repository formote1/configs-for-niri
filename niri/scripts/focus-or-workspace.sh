#!/bin/sh
# focus-or-workspace.sh <up|down>
#
# Move focus to the window above/below inside the current column.
# If the column has no window in that direction, switch workspace (desktop)
# instead. Bound to Mod+S / Mod+W in Niri.

set -eu

dir="${1:-}"
case "$dir" in
	up | down) ;;
	*)
		echo "usage: focus-or-workspace.sh <up|down>" >&2
		exit 2
		;;
esac

windows=$(niri msg --json windows)

# Workspace id and [column, row] of the focused tiling window (empty if none).
read -r ws col row <<EOF
$(printf '%s' "$windows" | jq -r '
	[ .[] | select(.is_focused and .layout.pos_in_scrolling_layout != null) ]
	| (.[0] // empty)
	| "\(.workspace_id) \(.layout.pos_in_scrolling_layout[0]) \(.layout.pos_in_scrolling_layout[1])"')
EOF

# Nothing focused (empty workspace): just switch workspace.
if [ -z "${ws:-}" ]; then
	niri msg action "focus-workspace-$dir" >/dev/null
	exit 0
fi

if [ "$dir" = down ]; then
	target=$((row + 1))
else
	target=$((row - 1))
fi

same_column=$(printf '%s' "$windows" | jq -r \
	--argjson ws "$ws" --argjson col "$col" --argjson row "$target" '
	[ .[] | select(.workspace_id == $ws
	               and .layout.pos_in_scrolling_layout != null
	               and .layout.pos_in_scrolling_layout[0] == $col
	               and .layout.pos_in_scrolling_layout[1] == $row) ] | length')

if [ "$same_column" -gt 0 ]; then
	niri msg action "focus-window-$dir" >/dev/null
else
	niri msg action "focus-workspace-$dir" >/dev/null
fi
