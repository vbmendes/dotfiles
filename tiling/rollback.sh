#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove gTile keybindings
"$SCRIPT_DIR/remove-shortcuts"

WM=org.gnome.desktop.wm.keybindings
MEDIA=org.gnome.settings-daemon.plugins.media-keys

# Restore default workspace-switching bindings
gsettings reset "$WM" switch-to-workspace-left
gsettings reset "$WM" switch-to-workspace-right
gsettings reset "$WM" switch-to-workspace-up
gsettings reset "$WM" switch-to-workspace-down
gsettings reset "$WM" move-to-workspace-left
gsettings reset "$WM" move-to-workspace-right
gsettings reset "$WM" move-to-workspace-up
gsettings reset "$WM" move-to-workspace-down
echo "Restored default Ctrl+Alt+Arrow workspace-switching bindings"

# Restore default Ctrl+Alt+T terminal binding
gsettings reset "$MEDIA" terminal
echo "Restored default Ctrl+Alt+T terminal binding"

# Restore default show-desktop bindings
gsettings reset "$WM" show-desktop
echo "Restored default show-desktop bindings"

echo "Rollback complete."
