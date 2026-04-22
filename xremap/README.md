# xremap setup

Makes **Super** work as a macOS-style Cmd key system-wide, with word/line navigation on Alt and Super arrow keys.

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
1. Download the xremap binary (x11 build) to `~/.local/bin/xremap`
2. Add your user to the `input` group (requires logout to take effect)
3. Create a udev rule granting the `input` group access to `/dev/uinput`
4. Remove GNOME's conflicting Super+V shortcut (notification tray moves to Super+M)
5. Install and start xremap as a systemd user service

## How it works

xremap runs as a persistent daemon with a uinput virtual device — keys are remapped before X11 sees them, so the shortcuts work even in apps that block synthetic input (like Warp).

All keymaps use `exact_match: true`, so only the exact modifier combination triggers a remap. This means:

- `Ctrl+Alt+Shift+Super+<key>` combos used by the [window-switcher](../window-switcher/README.md) pass through untouched.
- `Ctrl+Alt+<key>` combos used by the [tiling](../tiling/README.md) setup pass through untouched — `Alt+Left` only fires when Alt is the sole modifier.

## Global shortcuts (all apps)

| Shortcut | Remapped to | Action |
|---|---|---|
| Super+C | Ctrl+C | Copy |
| Super+V | Ctrl+V | Paste |
| Super+Shift+V | Ctrl+Shift+V | Paste without formatting |
| Super+X | Ctrl+X | Cut |
| Super+A | Ctrl+A | Select all |
| Super+Z | Ctrl+Z | Undo |
| Super+B | Ctrl+B | Bold |
| Super+G | Ctrl+G | Go to / find next |
| Super+F | Ctrl+F | Find |
| Super+W | Ctrl+W | Close tab |
| Super+R | Ctrl+R | Reload / reverse search |
| Super+Q | Ctrl+Q | Quit |
| Super+Shift+T | Ctrl+Shift+T | Reopen closed tab |
| Super+Left | Home | Beginning of line |
| Super+Right | End | End of line |
| Super+Backspace | Ctrl+U | Delete to beginning of line |
| Alt+Left | Ctrl+Left | Previous word |
| Alt+Right | Ctrl+Right | Next word |
| Alt+Backspace | Ctrl+Backspace | Delete previous word |

## Terminal shortcuts (Warp, GNOME Terminal, kitty, Alacritty, Terminator, xterm)

Terminals get different copy/paste mappings because `Ctrl+C` sends SIGINT, not copy.

| Shortcut | Remapped to | Action |
|---|---|---|
| Super+C | Ctrl+Shift+C | Copy |
| Super+V | Ctrl+Shift+V | Paste |
| Super+Shift+V | Ctrl+Shift+V | Paste |
| Super+T | Ctrl+Shift+T | New tab |

## Conflicts cleared

| Shortcut | Was | Now |
|---|---|---|
| Super+V | GNOME notification tray | *(freed — tray is still on Super+M)* |
| Super+A | GNOME app drawer | *(freed — app drawer moved to Super+Space)* |
| Super+Space | Switch input source | *(freed — rebound to Ctrl+Alt+Space)* |
| Super (alone) | Open Activities overview | *(disabled)* |

## Adding more terminal apps

Edit `config.yml` and add the app's WM class to the `only` list in the Terminal section:

```bash
xprop | grep WM_CLASS   # click on the terminal window when prompted
```
