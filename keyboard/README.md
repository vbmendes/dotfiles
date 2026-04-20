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
