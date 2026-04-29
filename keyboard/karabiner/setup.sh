#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.config/karabiner/assets/complex_modifications"
KARABINER_CONFIG="$HOME/.config/karabiner/karabiner.json"
MOD_FILE="$SCRIPT_DIR/qmk-like-macbook.json"

mkdir -p "$DEST_DIR"
cp "$MOD_FILE" "$DEST_DIR/qmk-like-macbook.json"
echo "Installed: $DEST_DIR/qmk-like-macbook.json"

if ! command -v jq &>/dev/null; then
    echo ""
    echo "jq not found — enable manually in Karabiner-Elements under Simple Modifications (for all keyboards):"
    echo "  left_shift       → left_command"
    echo "  right_shift      → left_command"
    echo "  left_command     → left_shift"
    echo "  spacebar         → left_command"
    echo "  right_command    → spacebar"
    echo "  left_option      → f18  (nav layer)"
    echo "  left_control     → f17  (numpad layer)"
    echo "  right_option    → f19  (symbols layer)"
    echo "  fn (globe)       → left_control"
    echo "  backslash        → fn (globe)"
    echo ""
    echo "  Complex Modifications → Add rule → QMK-like MacBook internal keyboard layers → Enable All"
    exit 0
fi

if [[ ! -f "$KARABINER_CONFIG" ]]; then
    echo ""
    echo "Karabiner config not found at $KARABINER_CONFIG"
    echo "Enable manually after launching Karabiner-Elements."
    exit 0
fi

BACKUP="$KARABINER_CONFIG.bak.$(date +%Y%m%d%H%M%S)"
cp "$KARABINER_CONFIG" "$BACKUP"

# Simple modifications — replaces the is_keyboard:true device entry, preserving other device entries
jq '
    .profiles[0].devices = (
        ((.profiles[0].devices // []) | map(select(.identifiers.is_keyboard != true))) +
        [{
            "identifiers": {"is_keyboard": true},
            "simple_modifications": [
                {"from": {"key_code": "left_shift"},                             "to": [{"key_code": "left_command"}]},
                {"from": {"key_code": "right_shift"},                            "to": [{"key_code": "left_command"}]},
                {"from": {"key_code": "left_command"},                           "to": [{"key_code": "left_shift"}]},
                {"from": {"key_code": "spacebar"},                               "to": [{"key_code": "left_command"}]},
                {"from": {"key_code": "right_command"},                          "to": [{"key_code": "spacebar"}]},
                {"from": {"key_code": "left_option"},                            "to": [{"key_code": "f18"}]},
                {"from": {"key_code": "left_control"},                           "to": [{"key_code": "f17"}]},
                {"from": {"key_code": "right_option"},                           "to": [{"key_code": "f19"}]},
                {"from": {"apple_vendor_top_case_key_code": "keyboard_fn"},      "to": [{"key_code": "left_control"}]},
                {"from": {"key_code": "backslash"},                              "to": [{"apple_vendor_top_case_key_code": "keyboard_fn"}]}
            ]
        }]
    )
' "$KARABINER_CONFIG" > "$KARABINER_CONFIG.tmp" && mv "$KARABINER_CONFIG.tmp" "$KARABINER_CONFIG"
echo "Simple modifications applied."

# Complex modifications
DESCRIPTION=$(jq -r '.rules[0].description' "$MOD_FILE")
ALREADY=$(jq --arg desc "$DESCRIPTION" '
    .profiles[0].complex_modifications.rules // [] |
    map(select(.description == $desc)) |
    length > 0
' "$KARABINER_CONFIG")

if [[ "$ALREADY" == "true" ]]; then
    echo "Complex modification rules already enabled."
else
    jq --slurpfile mod "$MOD_FILE" '
        .profiles[0].complex_modifications.rules += $mod[0].rules
    ' "$KARABINER_CONFIG" > "$KARABINER_CONFIG.tmp" && mv "$KARABINER_CONFIG.tmp" "$KARABINER_CONFIG"
    echo "Complex modification rules enabled."
fi

echo "Done (backup: $BACKUP)"
