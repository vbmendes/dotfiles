# MacBook Internal Keyboard (Karabiner-Elements)

Custom complex modification for the MacBook internal keyboard, providing QMK-like layers via Karabiner-Elements.

## Setup

Copies the complex modification to `~/.config/karabiner/assets/complex_modifications/` and enables the rules in the default Karabiner profile (requires `jq`):

```bash
./keyboard/karabiner/setup.sh
```

If `jq` is not available, install the file manually and enable via **Karabiner-Elements → Complex Modifications → Add rule → QMK-like MacBook internal keyboard layers → Enable All**.

## Simple Modifications

| From | To |
|------|----|
| Left Shift | Left Command |
| Right Shift | Left Command |
| Left Command | Left Shift |
| Spacebar | Left Command |
| Right Command | Spacebar |
| Left Option | F18 (nav layer trigger) |
| Left Control | F17 (numpad layer trigger) |
| Right Option | F19 (symbols layer trigger) |
| Globe (fn) | Left Control |
| \\ | Globe (fn) |

These are applied as device-level simple modifications (built-in keyboard only) and **replace** any existing `is_built_in_keyboard: true` device entry.

## Layers / Mappings

**Caps Lock** — Meh (⌃⌥⇧) when held; Caps Lock when tapped  
**Left Option** — activates navigation layer while held (→ F18)  
**Right Option** — activates symbols layer while held (→ F19)  
**Left Control** — activates numpad layer while held (→ F17)

### Numpad (Left Shift held)

```
,------+------+------+------+------+------+------+------+------+------.
|   !  |   @  |   #  |   $  |   %  |   *  |   7  |   8  |   9  |   =  |
|------+------+------+------+------+------+------+------+------+------|
|   {  |   }  |   (  |   )  |   _  |   -  |   4  |   5  |   6  | BSPC |
|------+------+------+------+------+------+------+------+------+------|
|   \  |C+G+SP|   [  |   ]  |   &  |   +  |   1  |   2  |   3  |   .  |
`------+------+------+------+------+------+------+------+------+------'
   Q      W      E      R      T      Y      U      I      O      P
   A      S      D      F      G      H      J      K      L      ;
   Z      X      C      V      B      N      M      ,      .      /
```

### Symbols (Right Option held)

```
,------+------+------+------+------+------+------+------+------+------.
|   !  |   @  |   #  |   $  |   %  |   *  |      |      |      |   =  |
|------+------+------+------+------+------+------+------+------+------|
|      |      |   (  |   )  |   _  |   ^  |   '  |   `  |   ç  | BSPC |
|------+------+------+------+------+------+------+------+------+------|
|   \  |C+G+SP|   [  |   ]  |   &  |circ' |quot' |grav' |RA+0  |RA+9  |
`------+------+------+------+------+------+------+------+------+------'
   Q      W      E      R      T      Y      U      I      O      P
   A      S      D      F      G      H      J      K      L      ;
   Z      X      C      V      B      N      M      ,      .      /
```

### Navigation (Left Option held)

```
,------+------+------+------+------+------+------+------+------+------.
| ESC  | HOME | PGDN | PGUP | END  | HOME | PGDN | PGUP | END  |   =  |
|------+------+------+------+------+------+------+------+------+------|
| DEL  | LEFT | DOWN |  UP  | RGHT | LEFT | DOWN |  UP  | RGHT | BSPC |
|------+------+------+------+------+------+------+------+------+------|
| LSFT | LCTL | LALT | LGUI | MEH  | MEH  | LGUI | LALT | LCTL | LSFT |
`------+------+------+------+------+------+------+------+------+------'
   Q      W      E      R      T      Y      U      I      O      P
   A      S      D      F      G      H      J      K      L      ;
   Z      X      C      V      B      N      M      ,      .      /
```

## Combos

Active when not in the navigation layer. All key positions are QWERTY layer.

| Combo | Output       |
|-------|-------------|
| D + F | Left Shift  |
| X + C | Left Ctrl   |
| C + V | Left GUI    |
| Z + V | Left Alt    |
| J + K | Right Shift |
| . + , | Right Ctrl  |
| M + , | Right GUI   |
| M + / | Right Alt   |

---

# Sofle v2 QMK Keymap

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
