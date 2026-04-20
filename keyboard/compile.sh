#!/bin/bash

KEYBOARD="sofle/rev1"
KEYMAP="vbmendes"

qmk compile -kb "$KEYBOARD" -km "$KEYMAP"
STATUS=$?

echo ""
echo "To flash (repeat for each half — right side first, then left):"
echo "  1. Plug in one half via USB"
echo "  2. Put it in bootloader mode (double-tap the reset button on the PCB)"
echo "  3. Run: qmk flash -kb $KEYBOARD -km $KEYMAP"
echo "  4. Repeat for the other half"

exit $STATUS
