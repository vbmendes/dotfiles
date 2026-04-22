# keyboard

Everything related to keyboard hardware, firmware, and input remapping.

## Contents

### [`qmk/`](qmk/README.md)
Custom QMK firmware for the JosefAdamcik Sofle v2. Defines layers, combos, and encoders. Run `qmk/setup.sh` to copy keymap files and compile, then flash each half with `qmk flash`.

### [`xremap/`](xremap/README.md)
System-wide key remapping daemon. Makes Super work as a macOS-style Cmd key, adds word/line navigation on Alt and Super arrows, and handles terminal-specific copy/paste. Run `xremap/setup.sh` to install and start the service.

### [`fix_cedilla.sh`](fix_cedilla.sh)
Configures the XKB layout so `RALT+C` produces `ç`. Required once after a fresh install if you use the cedilla key on the SYMBOLS layer.

### [`setup_lock_shortcut.sh`](setup_lock_shortcut.sh)
Binds `Ctrl+Super+Q` to lock the screen via GNOME's screensaver shortcut.

## Setup order

On a fresh machine, run in this order:

```bash
keyboard/fix_cedilla.sh
keyboard/setup_lock_shortcut.sh
keyboard/xremap/setup.sh
keyboard/qmk/setup.sh   # only if building firmware
```
