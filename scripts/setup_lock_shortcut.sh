#!/bin/bash

BINDING="['<Primary><Super>q']"
SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
KEY="screensaver"

CURRENT=$(gsettings get "$SCHEMA" "$KEY" 2>/dev/null)
if [ "$CURRENT" = "$BINDING" ]; then
    echo "Lock screen shortcut already set to Ctrl+Super+Q."
else
    gsettings set "$SCHEMA" "$KEY" "$BINDING"
    echo "Lock screen shortcut set to Ctrl+Super+Q."
fi
