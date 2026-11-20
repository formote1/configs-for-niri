#!/bin/sh
# toggle-tiling-fullscreen.sh
#
# Bound to Mod+F in Niri.
#   floating window -> tile it, then maximize the column
#   tiled window    -> maximize the column
# Maximizing is idempotent: it only runs when the column isn't already
# maximized, so pressing Mod+F again keeps it maximized.

set -eu

win=$(niri msg --json focused-window)
if [ -z "$win" ] || [ "$win" = "null" ]; then
	exit 0 # nothing focused (e.g. empty workspace)
fi

# Tile the window first if it is floating.
if [ "$(printf '%s' "$win" | jq -r '.is_floating')" = true ]; then
	niri msg action toggle-window-floating >/dev/null
	win=$(niri msg --json focused-window)
fi

# A maximized column spans the workspace width = output width - gaps.
gap=$(sed -n 's/.*\bgaps[[:space:]]\+\([0-9]\+\).*/\1/p' \
	"$HOME/.config/niri/cfg/layout.kdl" | head -n 1)
gap=${gap:-6}

ow=$(niri msg --json focused-output | jq -r '.logical.width')

maximized=$(printf '%s' "$win" | jq -r --argjson want "$((ow - 2 * gap))" \
	'.layout.tile_size[0] >= ($want - 1)')

if [ "$maximized" = false ]; then
	niri msg action maximize-column >/dev/null
fi
