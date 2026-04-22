#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Shortcuts ──────────────────────────────────────────────────────────────
# Modifier combo applied to every shortcut below
MODIFIER="<Ctrl><Alt><Shift><Super>"

# Format: "KEY|NAME|WINDOW_PATTERN|LAUNCH_COMMAND[|WM_CLASS]"
# Specify WM_CLASS when the window title is unreliable (e.g. terminals).
# Find WM_CLASS with: xprop -id $(xdotool getactivewindow) WM_CLASS
SHORTCUTS=(
  "c|Open Slack|slack|slack"
  "b|Open Chrome|chrome|google-chrome"
  "a|Open Calendar|calendar|gtk-launch chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Profile_2|crx_kjbdgfilnfhdoflbpgamdcdgpehopbep"
  "t|Open Warp|warp|warp-terminal|dev.warp.Warp"
  "p|Open 1Password|1password|1password"
  "n|Open Obsidian|obsidian|obsidian"
  "e|Open Visual Studio Code|Visual Studio Code|code"
  "w|Open Whatsapp|Whatsapp|gtk-launch chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default|crx_hnpfjngllnobngcgfapefoaidbinmjnm"
  "u|Open Cursor|Cursor|cursor"
  "v|Open Google Meet|Google Meet|gtk-launch chrome-kjgfgldnnfoeklkmfkjfagphfepbbdan-Profile_2|crx_kjgfgldnnfoeklkmfkjfagphfepbbdan"
  "f|Open Files|Files|nautilus|org.gnome.Nautilus"
)
# ───────────────────────────────────────────────────────────────────────────

# Install dependencies
for pkg in wmctrl xdotool python3-xlib; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# Install focus-or-launch and restack-window
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/focus-or-launch" "$HOME/.local/bin/focus-or-launch"
chmod +x "$HOME/.local/bin/focus-or-launch"
echo "Installed focus-or-launch to ~/.local/bin/"

cp "$SCRIPT_DIR/restack-window" "$HOME/.local/bin/restack-window"
chmod +x "$HOME/.local/bin/restack-window"
echo "Installed restack-window to ~/.local/bin/"

# Ensure ~/.local/bin is on PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

# Remove existing vbmendes-dotfiles shortcuts before recreating
"$SCRIPT_DIR/remove-shortcuts"

# Register shortcuts
for entry in "${SHORTCUTS[@]}"; do
  "$SCRIPT_DIR/register-shortcut" "$entry"
done

echo "Done. ${#SHORTCUTS[@]} shortcut(s) registered."
