# tiling

Window tiling via [gTile](https://github.com/gTile/gTile) GNOME extension. Shortcuts snap the focused window to a region of a 6×4 grid using `Ctrl+Alt+<key>` combos (no need to open the gTile UI).

## Prerequisites

Install the gTile GNOME extension before running setup:

```bash
# Via GNOME Extensions app, or:
gext install gTile@vibou
```

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

## Shortcuts

All shortcuts use `Ctrl+Alt` as the modifier.

| Shortcut | Layout |
|---|---|
| `Ctrl+Alt+Left` | Half left |
| `Ctrl+Alt+Right` | Half right |
| `Ctrl+Alt+Up` | Half top |
| `Ctrl+Alt+Down` | Half bottom |
| `Ctrl+Alt+U` | Quarter top-left |
| `Ctrl+Alt+I` | Quarter top-right |
| `Ctrl+Alt+J` | Quarter bottom-left |
| `Ctrl+Alt+K` | Quarter bottom-right |
| `Ctrl+Alt+D` | Third left |
| `Ctrl+Alt+F` | Third middle |
| `Ctrl+Alt+G` | Third right |
| `Ctrl+Alt+E` | Two-thirds left |
| `Ctrl+Alt+R` | Two-thirds middle |
| `Ctrl+Alt+T` | Two-thirds right |
| `Ctrl+Alt+Enter` | Fullscreen |

## Scripts

### `setup.sh`
Configures gTile presets and grid size, registers all keybindings, and clears conflicting defaults.

### `remove-shortcuts`
Removes all 15 gTile preset keybindings and restores gTile's default action bindings.

### `rollback.sh`
Runs `remove-shortcuts` and also restores all GNOME system defaults that `setup.sh` changed.

## Conflicts cleared

| Shortcut | Was | Now |
|---|---|---|
| `Ctrl+Alt+Arrow` | GNOME workspace switching | *(freed — rebound to `Super+Ctrl+Alt+Arrow`)* |
| `Ctrl+Alt+T` | GNOME default terminal | *(freed)* |
| `Ctrl+Alt+D` | GNOME show-desktop | *(freed — show-desktop kept on `Super+D`)* |
| `Ctrl+Alt+J` / `Ctrl+Alt+K` | gTile contract-top / contract-bottom | *(freed)* |

## Compatibility with xremap

The [xremap setup](../xremap/README.md) uses `exact_match: true`, so its `Alt+Left` / `Alt+Right` / `Alt+Backspace` remappings only fire when Alt is the **sole** modifier. `Ctrl+Alt+Left` and other tiling combos pass through to gTile untouched.
