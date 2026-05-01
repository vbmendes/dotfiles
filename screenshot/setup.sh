#!/bin/bash
set -euo pipefail

CUSTOM_KB_SCHEMA=org.gnome.settings-daemon.plugins.media-keys
CUSTOM_KB_BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

SHORTCUTS=(
  "flameshot-full|Screenshot Full|flameshot full -c|<Ctrl><Alt><Shift><Super>F3"
  "flameshot-area|Screenshot Area|flameshot gui|<Ctrl><Alt><Shift><Super>F4"
)

# Build dconf paths for each shortcut
NEW_PATHS=()
for entry in "${SHORTCUTS[@]}"; do
  IFS='|' read -r id _ _ _ <<< "$entry"
  NEW_PATHS+=("${CUSTOM_KB_BASE}/${id}/")
done

# Merge with existing custom keybindings, avoiding duplicates
EXISTING=$(gsettings get "$CUSTOM_KB_SCHEMA" custom-keybindings)
if [[ "$EXISTING" == "@as []" || "$EXISTING" == "[]" ]]; then
  EXISTING_PATHS=()
else
  mapfile -t EXISTING_PATHS < <(echo "$EXISTING" | tr -d "[] '" | tr ',' '\n' | grep -v '^$')
fi

MERGED=("${EXISTING_PATHS[@]}")
for path in "${NEW_PATHS[@]}"; do
  if ! printf '%s\n' "${MERGED[@]}" | grep -qxF "$path"; then
    MERGED+=("$path")
  fi
done

MERGED_STR=$(printf "'%s', " "${MERGED[@]}")
MERGED_STR="[${MERGED_STR%, }]"
gsettings set "$CUSTOM_KB_SCHEMA" custom-keybindings "$MERGED_STR"

# Register each shortcut
for entry in "${SHORTCUTS[@]}"; do
  IFS='|' read -r id name command binding <<< "$entry"
  path="${CUSTOM_KB_BASE}/${id}/"
  schema="${CUSTOM_KB_SCHEMA}.custom-keybinding:${path}"
  gsettings set "$schema" name    "$name"
  gsettings set "$schema" command "$command"
  gsettings set "$schema" binding "$binding"
  echo "Registered: $binding → $name"
done

echo "Done. ${#SHORTCUTS[@]} screenshot keybinding(s) registered."
