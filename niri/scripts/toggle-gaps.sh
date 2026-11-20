#!/usr/bin/env bash
LAYOUT="$HOME/.config/niri/cfg/layout.kdl"
RULES="$HOME/.config/niri/cfg/rules.kdl"

# Toggle gaps between 0 and 6
if grep -qE '^\s*gaps\s+0\b' "$LAYOUT"; then
  sed -i -E 's/^\s*gaps\s+.*/        gaps 6/' "$LAYOUT"
else
  sed -i -E 's/^\s*gaps\s+.*/        gaps 0/' "$LAYOUT"
fi

# Toggle corner radius between 0 and 20
if grep -qE 'geometry-corner-radius\s+0\b' "$RULES"; then
  sed -i -E 's/geometry-corner-radius\s+[0-9]+/geometry-corner-radius 20/' "$RULES"
else
  sed -i -E 's/geometry-corner-radius\s+[0-9]+/geometry-corner-radius 0/' "$RULES"
fi

niri msg action load-config-file >/dev/null 2>&1
