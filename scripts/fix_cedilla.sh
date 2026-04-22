#!/bin/bash

ENV_FILE="/etc/environment"
XKB_SYMBOLS_DIR="$HOME/.config/xkb/symbols"
XKB_SYMBOLS_FILE="$XKB_SYMBOLS_DIR/custom"
XKB_SYSTEM_SYMBOLS_FILE="/usr/share/X11/xkb/symbols/custom"
XKB_LAYOUT_SOURCE="[('xkb', 'custom')]"
XKB_CONTENT='partial alphanumeric_keys
xkb_symbols "basic" {

    include "us(alt-intl)"
    name[Group1]= "English (US, alt. intl., custom)";

    key <AB03> { [ c, C, ccedilla, Ccedilla ] };
    key <AE09> { [ 9, parenleft, dead_acute, ordfeminine ] };
    key <AE10> { [ 0, parenright, degree, ordmasculine ] };
};'

# ── Step 1: /etc/environment IM module fix ────────────────────────────────────

grep -q "GTK_IM_MODULE=cedilla" "$ENV_FILE" && grep -q "QT_IM_MODULE=cedilla" "$ENV_FILE" && {
    echo "Cedilla IM module fix already applied."
} || {
    echo "Applying cedilla IM module fix to $ENV_FILE (requires sudo)..."
    sudo bash -c '
        grep -q "GTK_IM_MODULE=cedilla" /etc/environment || echo "GTK_IM_MODULE=cedilla" >> /etc/environment
        grep -q "QT_IM_MODULE=cedilla" /etc/environment || echo "QT_IM_MODULE=cedilla" >> /etc/environment
    '
    echo "Done. Log out and back in for IM module changes to take effect."
}

# ── Step 2: User XKB symbols file (Wayland) ──────────────────────────────────

if diff -q <(printf '%s\n' "$XKB_CONTENT") "$XKB_SYMBOLS_FILE" > /dev/null 2>&1; then
    echo "XKB custom symbols already up to date at $XKB_SYMBOLS_FILE."
else
    mkdir -p "$XKB_SYMBOLS_DIR"
    printf '%s\n' "$XKB_CONTENT" > "$XKB_SYMBOLS_FILE"
    echo "Written XKB symbols to $XKB_SYMBOLS_FILE."
fi

# ── Step 3: System XKB symbols file (X11) ────────────────────────────────────

if diff -q <(printf '%s\n' "$XKB_CONTENT") "$XKB_SYSTEM_SYMBOLS_FILE" > /dev/null 2>&1; then
    echo "XKB system symbols already up to date at $XKB_SYSTEM_SYMBOLS_FILE."
else
    echo "Installing XKB symbols to $XKB_SYSTEM_SYMBOLS_FILE (requires sudo)..."
    sudo bash -c "printf '%s\n' '$XKB_CONTENT' > $XKB_SYSTEM_SYMBOLS_FILE"
    echo "Done."
fi

# ── Step 4: Register custom layout as GNOME input source ─────────────────────

CURRENT_SOURCES=$(gsettings get org.gnome.desktop.input-sources sources 2>/dev/null)
if [ "$CURRENT_SOURCES" = "$XKB_LAYOUT_SOURCE" ]; then
    echo "GNOME input source already set to custom."
else
    echo "Setting GNOME input source to custom..."
    gsettings set org.gnome.desktop.input-sources sources "$XKB_LAYOUT_SOURCE"
    echo "Done. Log out and back in for the layout change to take effect."
fi
