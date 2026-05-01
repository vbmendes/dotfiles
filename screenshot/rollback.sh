#!/bin/bash
set -euo pipefail

CUSTOM_KB_SCHEMA=org.gnome.settings-daemon.plugins.media-keys
CUSTOM_KB_BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

# Read current keybinding list
EXISTING=$(gsettings get "$CUSTOM_KB_SCHEMA" custom-keybindings)
if [[ "$EXISTING" == "@as []" || "$EXISTING" == "[]" ]]; then
  echo "No custom keybindings found — nothing to remove."
  exit 0
fi

mapfile -t ALL_PATHS < <(echo "$EXISTING" | tr -d "[] '" | tr ',' '\n' | grep -v '^$')

KEPT=()
REMOVED=0
for path in "${ALL_PATHS[@]}"; do
  id=$(basename "$path")
  if [[ "$id" == flameshot-* ]]; then
    schema="${CUSTOM_KB_SCHEMA}.custom-keybinding:${path}"
    gsettings reset "$schema" name    2>/dev/null || true
    gsettings reset "$schema" command 2>/dev/null || true
    gsettings reset "$schema" binding 2>/dev/null || true
    echo "Removed: $path"
    (( REMOVED++ )) || true
  else
    KEPT+=("$path")
  fi
done

if [[ "${#KEPT[@]}" -eq 0 ]]; then
  gsettings set "$CUSTOM_KB_SCHEMA" custom-keybindings "@as []"
else
  KEPT_STR=$(printf "'%s', " "${KEPT[@]}")
  KEPT_STR="[${KEPT_STR%, }]"
  gsettings set "$CUSTOM_KB_SCHEMA" custom-keybindings "$KEPT_STR"
fi

echo "Rollback complete. Removed ${REMOVED} flameshot keybinding(s)."
