#!/bin/bash
set -euo pipefail

# ── NVIDIA Drivers ─────────────────────────────────────────────────────────────

if command -v nvidia-smi &>/dev/null; then
  echo "NVIDIA drivers already installed: $(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader)"
else
  echo "Installing NVIDIA drivers..."
  sudo apt install -y nvidia-driver-570
  echo "NVIDIA drivers installed. A reboot is required."
  echo "Run: sudo reboot"
fi

# ── Chrome: fix blank video on YouTube ────────────────────────────────────────
#
# Symptom: YouTube shows a blank screen but audio plays fine.
# Cause:   Chrome attempts hardware video decode via NVIDIA on Linux but fails
#          to render frames (common with Wayland + NVIDIA).
# Fix:     Disable hardware video decode only — WebGL/WebGPU (needed for
#          Google Meet background blur) remain hardware-accelerated.
#
# Steps to apply in Chrome (cannot be scripted — requires browser UI):
#   1. Open chrome://flags in the address bar
#   2. Search for "Hardware-accelerated video decode"
#   3. Set it to Disabled
#   4. Click "Relaunch"
#
# Verify hardware acceleration is otherwise still on:
#   - chrome://settings/system → "Use graphics acceleration when available" = ON
#   - chrome://gpu → WebGL and WebGPU should show "Hardware accelerated"
#
# If the issue persists (e.g. running under Wayland), force Chrome to use X11:

CHROME_DESKTOP="/usr/share/applications/google-chrome.desktop"

if [ -f "$CHROME_DESKTOP" ]; then
  if grep -q "ozone-platform=x11" "$CHROME_DESKTOP"; then
    echo "Chrome already configured to use X11 (ozone-platform=x11)"
  else
    echo "Configuring Chrome to run under X11 instead of Wayland..."
    sudo sed -i \
      's|Exec=/usr/bin/google-chrome-stable |Exec=/usr/bin/google-chrome-stable --ozone-platform=x11 |g' \
      "$CHROME_DESKTOP"
    echo "Done. Relaunch Chrome for the change to take effect."
  fi
else
  echo "Chrome desktop file not found at $CHROME_DESKTOP — skipping X11 override."
fi

echo ""
echo "Done."
echo ""
echo "Remaining manual step in Chrome:"
echo "  chrome://flags → 'Hardware-accelerated video decode' → Disabled → Relaunch"
