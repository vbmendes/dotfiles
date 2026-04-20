#!/bin/bash

KEYBOARD="sofle/rev1"
KEYMAP="vbmendes"
QMK_DIR="$HOME/qmk_firmware"
KEYMAP_DIR="$QMK_DIR/keyboards/sofle/rev1/keymaps/$KEYMAP"
SOURCE_DIR="$(dirname "$0")/sofle"

# --- QMK environment bootstrap ---

if ! command -v qmk &> /dev/null; then
    echo "QMK CLI not found. Installing..."
    curl -fsSL https://install.qmk.fm | sh
    # Reload PATH in case the installer added a new location
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ ! -d "$QMK_DIR" ]; then
    echo "qmk_firmware not found. Running qmk setup..."
    qmk setup -H "$QMK_DIR" --yes
fi

mkdir -p "$KEYMAP_DIR"

changed=0
for f in keymap.c rules.mk config.h; do
    src="$SOURCE_DIR/$f"
    dst="$KEYMAP_DIR/$f"
    if ! diff -q "$src" "$dst" > /dev/null 2>&1; then
        cp "$src" "$dst"
        echo "Updated $f"
        changed=1
    fi
done

[ "$changed" -eq 0 ] && echo "Keymap files already up to date."

"$(dirname "$0")/compile.sh"
