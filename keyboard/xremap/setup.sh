#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
XREMAP_BIN="$HOME/.local/bin/xremap"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/xremap.service"

# ── Step 1: Install xremap binary ─────────────────────────────────────────────

if [ -x "$XREMAP_BIN" ]; then
    echo "xremap already installed at $XREMAP_BIN."
else
    echo "Downloading xremap..."
    DOWNLOAD_URL=$(curl -sf "https://api.github.com/repos/xremap/xremap/releases/latest" \
        | python3 -c "import sys,json; assets=json.load(sys.stdin)['assets']; \
          print(next(a['browser_download_url'] for a in assets if 'x11' in a['name'] and 'x86_64' in a['name']))")
    if [ -z "$DOWNLOAD_URL" ]; then
        echo "ERROR: Could not determine xremap download URL. Install manually from:"
        echo "  https://github.com/xremap/xremap/releases"
        exit 1
    fi
    mkdir -p "$HOME/.local/bin"
    curl -sL "$DOWNLOAD_URL" -o /tmp/xremap.zip
    unzip -qo /tmp/xremap.zip -d /tmp/xremap_extracted
    install -m 755 /tmp/xremap_extracted/xremap "$XREMAP_BIN"
    rm -rf /tmp/xremap.zip /tmp/xremap_extracted
    echo "xremap installed to $XREMAP_BIN."
fi

# ── Step 2: Add user to input group ───────────────────────────────────────────

if groups | grep -q '\binput\b'; then
    echo "User already in 'input' group."
else
    echo "Adding $USER to the 'input' group (requires re-login to take effect)..."
    sudo usermod -aG input "$USER"
fi

# ── Step 2b: Grant input group access to uinput ───────────────────────────────

UDEV_RULE=/etc/udev/rules.d/60-xremap.rules
if [ -f "$UDEV_RULE" ]; then
    echo "udev rule for uinput already exists."
else
    echo "Creating udev rule to grant input group access to /dev/uinput..."
    echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' | sudo tee "$UDEV_RULE" > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "udev rule applied."
fi

# ── Step 3: Configure GNOME shortcuts ────────────────────────────────────────

# Super+V: free it from notification tray (keep Super+M)
CURRENT_TRAY=$(gsettings get org.gnome.shell.keybindings toggle-message-tray)
if echo "$CURRENT_TRAY" | grep -q "Super.*v"; then
    gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"
    echo "Removed Super+V from toggle-message-tray (kept Super+M)."
fi

# Super+A: move app drawer to Super+Space (free Super+A for select-all)
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>space']"
echo "App drawer moved to Super+Space."

# Super+Space was switch-input-source — remove it (XF86Keyboard still works)
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Ctrl><Alt>space', 'XF86Keyboard']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Ctrl><Alt>space', '<Shift>XF86Keyboard']"
echo "Input source switcher rebound to Ctrl+Alt+Space."

# Disable Super key alone from opening Activities overview
gsettings set org.gnome.mutter overlay-key ''
echo "Disabled Super key opening Activities overview."

# ── Step 4: Reload xremap if already running ──────────────────────────────────

if systemctl --user is-active --quiet xremap 2>/dev/null; then
    systemctl --user restart xremap
    echo "xremap restarted to pick up config changes."
fi

# ── Step 5: Install and enable systemd user service ───────────────────────────

mkdir -p "$SERVICE_DIR"

# Substitute real home path (systemd %h may not expand in all contexts)
sed "s|%h|$HOME|g" "$SCRIPT_DIR/xremap.service" > "$SERVICE_FILE"

systemctl --user daemon-reload
systemctl --user enable --now xremap
echo "xremap service enabled and started."

echo ""
echo "Done."
echo "NOTE: If you were just added to the 'input' group, log out and back in,"
echo "      then run: systemctl --user restart xremap"
