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

Custom QMK keymap for the JosefAdamcik Sofle v2 (`sofle/rev1`, USB ID `fc32:0287`).

## Setup

Copies keymap files to `~/qmk_firmware` and compiles. Only changed files are copied.

```bash
./keyboard/setup.sh
```

## Compile only

```bash
./keyboard/compile.sh
```

## Flash

Flash each half separately with the same command. Right side first, then left.

1. Plug in one half via USB
2. Put it in bootloader mode by **double-tapping the reset button** on the PCB
3. Run:

```bash
qmk flash -kb sofle/rev1 -km vbmendes
```

4. Repeat for the other half

## Layers

| # | Name     | Activation |
|---|----------|------------|
| 0 | QWERTY   | Base |
| 1 | SYMBOLS  | Hold SYMB thumb |
| 2 | NUMPAD   | `TO(NUMP)` from SYMBOLS/NAV outer column |
| 3 | FUNCTION | Hold FUNC thumb (from SYMBOLS/NUMPAD) |
| 4 | NAV      | Hold NAV thumb |

**Top row:** `ESC F1–F10 C+G+Q` on QWERTY; `← 1–0 C+G+Q` on all other layers.

**Encoder left:** VOL- / VOL+ (QWERTY), BRID / BRIU (FUNCTION)  
**Encoder right:** PGUP / PGDN (QWERTY), MPRV / MNXT (FUNCTION), LEFT / RGHT (NAV)  
**Encoder buttons:** left = MUTE, right = Hyper+F5

## Combos

Active on all layers except NAV. All key positions are QWERTY layer.

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

## Cedilla

The cedilla key (on the SYMBOLS layer) sends `RALT+C`. On Linux, run
`./scripts/fix_cedilla.sh` once to configure the XKB layout so this produces `ç`.
