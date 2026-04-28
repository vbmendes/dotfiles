#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HS_DIR="$HOME/.hammerspoon"

# ── Check Hammerspoon is installed ────────────────────────────────────────────

HS_APP=""
for candidate in "/Applications/Hammerspoon.app" "$HOME/Applications/Hammerspoon.app"; do
  [[ -d "$candidate" ]] && HS_APP="$candidate" && break
done
if [[ -z "$HS_APP" ]]; then
  HS_APP=$(mdfind "kMDItemCFBundleIdentifier == 'org.hammerspoon.Hammerspoon'" 2>/dev/null | head -1)
fi

if [[ -z "$HS_APP" ]]; then
  echo "Hammerspoon not found. Install it with: brew install --cask hammerspoon"
  exit 1
fi

mkdir -p "$HS_DIR"

# ── Symlink runtime files ─────────────────────────────────────────────────────

for file in hyper.lua hyper-apps.lua; do
  target="$HS_DIR/$file"
  source="$SCRIPT_DIR/$file"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "Already linked: $target"
  else
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup="$target.bak"
      echo "Backing up existing $target → $backup"
      mv "$target" "$backup"
    fi
    ln -sf "$source" "$target"
    echo "Linked: $target → $source"
  fi
done

# ── Create or update init.lua ─────────────────────────────────────────────────

INIT="$HS_DIR/init.lua"
REQUIRE_LINE="require('hyper')"

if [[ ! -f "$INIT" ]]; then
  cat > "$INIT" <<'EOF'
require('hs.ipc')

-- Ctrl+` to reload config
hs.hotkey.bind({'ctrl'}, '`', nil, hs.reload)

require('hyper')

hs.notify.new({title='Hammerspoon', informativeText='Ready'}):send()
EOF
  echo "Created: $INIT"
elif ! grep -qF "$REQUIRE_LINE" "$INIT"; then
  echo "" >> "$INIT"
  echo "$REQUIRE_LINE" >> "$INIT"
  echo "Added '$REQUIRE_LINE' to existing $INIT"
else
  echo "Already present in init.lua: $REQUIRE_LINE"
fi

# ── Reload Hammerspoon ────────────────────────────────────────────────────────

if pgrep -x Hammerspoon > /dev/null; then
  if command -v hs &>/dev/null; then
    hs -c "hs.reload()" 2>/dev/null && echo "Hammerspoon reloaded." || true
  else
    echo "Hammerspoon is running — reload it manually (Ctrl+\`) or via its menu."
  fi
else
  echo "Open Hammerspoon to activate the shortcuts."
fi

echo ""
echo "Done. Edit $SCRIPT_DIR/hyper-apps.lua to change your shortcuts, then run setup.sh again to reload."
