#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_FILE="$SCRIPT_DIR/ignore_secrets.ini"
WARP_PASTE_FILE="$SCRIPT_DIR/warp_paste.ini"

# ── Step 1: Install CopyQ ─────────────────────────────────────────────────────

if command -v copyq &>/dev/null; then
    echo "CopyQ already installed: $(copyq --version 2>&1 | head -1)"
else
    echo "Installing CopyQ..."
    sudo apt install -y copyq xdotool ydotool
    echo "Done."
fi

# ── Step 2: Autostart ─────────────────────────────────────────────────────────

AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/copyq.desktop"
mkdir -p "$AUTOSTART_DIR"

if [ -f "$AUTOSTART_FILE" ]; then
    echo "CopyQ autostart already configured."
else
    cat > "$AUTOSTART_FILE" << 'EOF'
[Desktop Entry]
Name=CopyQ
Comment=Clipboard manager with advanced features
Exec=copyq
Icon=copyq
Terminal=false
Type=Application
Categories=Utility;
X-GNOME-Autostart-enabled=true
EOF
    echo "CopyQ autostart configured."
fi

# ── Step 3: Configure global shortcut ────────────────────────────────────────

# Must be written before CopyQ starts — it overwrites the config on exit.
python3 - << 'PYEOF'
import configparser, os

conf_path = os.path.expanduser("~/.config/copyq/copyq.conf")
shortcut  = "ctrl+shift+alt+v"
section   = "GlobalShortcuts"
key       = "show_hide_main_window"

cfg = configparser.RawConfigParser()
cfg.optionxform = str  # preserve case
if os.path.exists(conf_path):
    cfg.read(conf_path)

if not cfg.has_section(section):
    cfg.add_section(section)

if cfg.get(section, key, fallback=None) == shortcut:
    print("CopyQ global shortcut already configured.")
else:
    cfg.set(section, key, shortcut)
    os.makedirs(os.path.dirname(conf_path), exist_ok=True)
    with open(conf_path, "w") as f:
        cfg.write(f, space_around_delimiters=False)
    print("CopyQ global shortcut set: Ctrl+Shift+Alt+V → show/hide main window")
PYEOF

# ── Step 4: Import ignore-secrets commands ────────────────────────────────────

# CopyQ must be running to accept importCommands
if ! copyq version &>/dev/null 2>&1; then
    echo "Starting CopyQ..."
    copyq &
    sleep 2
fi

if copyq importCommands "$COMMANDS_FILE" 2>/dev/null; then
    echo "CopyQ ignore commands imported."
else
    echo "WARNING: Could not import CopyQ commands automatically."
    echo "  Open CopyQ → Preferences → Commands → Import, and load:"
    echo "  $COMMANDS_FILE"
fi

if copyq importCommands "$WARP_PASTE_FILE" 2>/dev/null; then
    echo "CopyQ Warp paste command imported."
else
    echo "WARNING: Could not import Warp paste command automatically."
    echo "  Open CopyQ → Preferences → Commands → Import, and load:"
    echo "  $WARP_PASTE_FILE"
fi

# ── Step 5: ydotool (kernel-level input injection for Warp paste) ─────────────

if ! command -v ydotool &>/dev/null; then
    echo "Installing ydotool..."
    sudo apt install -y ydotool
fi

# ydotoold needs /dev/uinput access — requires the 'input' group
if ! groups | grep -q '\binput\b'; then
    echo "Adding $USER to the 'input' group (requires re-login to take effect)..."
    sudo usermod -aG input "$USER"
fi

# Set up ydotoold as a user systemd service
YDOTOOL_SERVICE="$HOME/.config/systemd/user/ydotoold.service"
mkdir -p "$(dirname "$YDOTOOL_SERVICE")"

if [ -f "$YDOTOOL_SERVICE" ]; then
    echo "ydotoold service already configured."
else
    cat > "$YDOTOOL_SERVICE" << 'EOF'
[Unit]
Description=ydotoold input injection daemon

[Service]
ExecStart=/usr/bin/ydotoold

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable --now ydotoold
    echo "ydotoold service enabled and started."
fi

echo ""
echo "Done. CopyQ will start automatically on next login."
echo "To start it now: copyq &"
echo ""
echo "NOTE: If you were just added to the 'input' group, log out and back in,"
echo "      then run: systemctl --user start ydotoold"
