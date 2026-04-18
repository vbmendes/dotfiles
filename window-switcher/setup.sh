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
)
# ───────────────────────────────────────────────────────────────────────────

# Install dependencies
for pkg in wmctrl xdotool; do
  if ! command -v "$pkg" &>/dev/null; then
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# Install focus-or-launch
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/focus-or-launch" "$HOME/.local/bin/focus-or-launch"
chmod +x "$HOME/.local/bin/focus-or-launch"
echo "Installed focus-or-launch to ~/.local/bin/"

# Ensure ~/.local/bin is on PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

# Remove existing vbmendes-dotfiles shortcuts before recreating
"$SCRIPT_DIR/remove-shortcuts"

# Register shortcuts
BASE=org.gnome.settings-daemon.plugins.media-keys
SCHEMA="$BASE.custom-keybinding"
PATH_BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

new_paths=()

for entry in "${SHORTCUTS[@]}"; do
  IFS='|' read -r key name pattern command wm_class <<< "$entry"

  slug=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  full_path="$PATH_BASE/vbmendes-dotfiles-$slug/"
  binding="${MODIFIER}${key}"

  if [[ -n "${wm_class:-}" ]]; then
    fol_command="focus-or-launch --class '$wm_class' '$pattern' '$command'"
  else
    fol_command="focus-or-launch '$pattern' '$command'"
  fi

  gsettings set "$SCHEMA:$full_path" name    "$name"
  gsettings set "$SCHEMA:$full_path" command "$fol_command"
  gsettings set "$SCHEMA:$full_path" binding "$binding"

  new_paths+=("$full_path")
  echo "Registered: $binding → $name"
done

# Merge new paths with any existing non-dotfiles shortcuts
current=$(gsettings get "$BASE" custom-keybindings)
if [[ "$current" == "@as []" ]]; then
  existing_paths=()
else
  mapfile -t existing_paths < <(echo "$current" | tr -d "[]'" | tr ',' '\n' | tr -d ' ' | grep -v '^$')
fi

all_paths=("${existing_paths[@]}" "${new_paths[@]}")
list=$(printf "'%s'," "${all_paths[@]}")
list="[${list%,}]"
gsettings set "$BASE" custom-keybindings "$list"

echo "Done. ${#new_paths[@]} shortcut(s) registered."
