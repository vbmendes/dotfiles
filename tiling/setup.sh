#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODIFIER="<Ctrl><Alt>"
GTILE_SCHEMA=org.gnome.shell.extensions.gtile
GTILE_SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/gTile@vibou/schemas"
export GSETTINGS_SCHEMA_DIR="${GTILE_SCHEMA_DIR}${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"

# Format: "KEY|PRESET_NUMBER|NAME"
SHORTCUTS=(
  "Left|1|Tile half left"
  "Right|2|Tile half right"
  "Up|3|Tile half top"
  "Down|4|Tile half bottom"
  "u|5|Tile quarter top-left"
  "i|6|Tile quarter top-right"
  "j|7|Tile quarter bottom-left"
  "k|8|Tile quarter bottom-right"
  "d|9|Tile third left"
  "f|10|Tile third middle"
  "g|11|Tile third right"
  "e|12|Tile two-thirds left"
  "r|13|Tile two-thirds middle"
  "t|14|Tile two-thirds right"
  "Return|15|Tile fullscreen"
)

# Format: "PRESET_NUMBER|LAYOUT"  (6x4 grid, 1-based col:row coordinates)
GTILE_LAYOUTS=(
  "1|6x4 1:1 3:4"    # half-left
  "2|6x4 4:1 6:4"    # half-right
  "3|6x4 1:1 6:2"    # half-top
  "4|6x4 1:3 6:4"    # half-bottom
  "5|6x4 1:1 3:2"    # quarter top-left
  "6|6x4 4:1 6:2"    # quarter top-right
  "7|6x4 1:3 3:4"    # quarter bottom-left
  "8|6x4 4:3 6:4"    # quarter bottom-right
  "9|6x4 1:1 2:4"    # third left
  "10|6x4 3:1 4:4"   # third middle
  "11|6x4 5:1 6:4"   # third right
  "12|6x4 1:1 4:4"   # two-thirds left
  "13|6x4 2:1 5:4"   # two-thirds middle
  "14|6x4 3:1 6:4"   # two-thirds right
  "15|6x4 1:1 6:4"   # fullscreen
)

# Check gTile is available
if ! gsettings list-schemas 2>/dev/null | grep -q "^${GTILE_SCHEMA}$"; then
  echo "ERROR: gTile schema not found. Install the gTile GNOME extension first." >&2
  exit 1
fi

# Enable global preset shortcuts (work without opening gTile UI)
gsettings set "$GTILE_SCHEMA" global-presets true

# Configure grid size and preset layouts
gsettings set "$GTILE_SCHEMA" grid-sizes "6x4"
for entry in "${GTILE_LAYOUTS[@]}"; do
  IFS='|' read -r num layout <<< "$entry"
  gsettings set "$GTILE_SCHEMA" "resize${num}" "$layout"
done
echo "Configured ${#GTILE_LAYOUTS[@]} gTile preset layout(s) (grid: 6x4)"

# Clear conflicting default gTile action bindings
# (<Ctrl><Alt>j and <Ctrl><Alt>k are used by gTile's contract actions by default)
gsettings set "$GTILE_SCHEMA" action-contract-top    "@as []"
gsettings set "$GTILE_SCHEMA" action-contract-bottom "@as []"
echo "Cleared conflicting gTile action-contract bindings"

# Remap conflicting default GNOME keybindings
WM=org.gnome.desktop.wm.keybindings
MEDIA=org.gnome.settings-daemon.plugins.media-keys

gsettings set "$WM" switch-to-workspace-left  "['<Super><Ctrl><Alt>Left']"
gsettings set "$WM" switch-to-workspace-right "['<Super><Ctrl><Alt>Right']"
gsettings set "$WM" switch-to-workspace-up    "['<Super><Ctrl><Alt>Up']"
gsettings set "$WM" switch-to-workspace-down  "['<Super><Ctrl><Alt>Down']"
gsettings set "$WM" move-to-workspace-left    "['<Super><Ctrl><Shift><Alt>Left']"
gsettings set "$WM" move-to-workspace-right   "['<Super><Ctrl><Shift><Alt>Right']"
gsettings set "$WM" move-to-workspace-up      "['<Super><Ctrl><Shift><Alt>Up']"
gsettings set "$WM" move-to-workspace-down    "['<Super><Ctrl><Shift><Alt>Down']"
echo "Remapped Ctrl+Alt+Arrow → Super+Ctrl+Alt+Arrow (workspace switching)"

gsettings set "$MEDIA" terminal "@as []" 2>/dev/null || true
echo "Cleared Ctrl+Alt+T terminal binding"

# Keep only Super+D for show-desktop (remove Ctrl+Alt+D and Ctrl+Super+D)
gsettings set "$WM" show-desktop "['<Super>d']"
echo "Cleared Ctrl+Alt+D show-desktop binding"

# Register gTile preset keybindings
for entry in "${SHORTCUTS[@]}"; do
  IFS='|' read -r key num name <<< "$entry"
  binding="${MODIFIER}${key}"
  gsettings set "$GTILE_SCHEMA" "preset-resize-${num}" "['${binding}']"
  echo "Registered: $binding → $name (preset ${num})"
done

echo "Done. ${#SHORTCUTS[@]} keybinding(s) registered via gTile."
