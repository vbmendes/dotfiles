# xremap setup

Makes **Super+C / Super+V** work as copy/paste system-wide (like macOS Cmd+C/V), and **Super+Shift+V** as paste without formatting.

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
1. Download the xremap binary (x11 build) to `~/.local/bin/xremap`
2. Add your user to the `input` group (requires logout to take effect)
3. Remove GNOME's conflicting Super+V shortcut (notification tray moves to Super+M)
4. Install and start xremap as a systemd user service

## How it works

xremap runs as a persistent daemon with a uinput virtual device — keys are remapped before X11 sees them, so the shortcuts work even in apps that block synthetic input (like Warp).

The remapping is context-aware:

| App type | Super+C | Super+V | Super+Shift+V |
|---|---|---|---|
| Terminals (Warp, GNOME Terminal, etc.) | `Ctrl+Shift+C` | `Ctrl+Shift+V` | `Ctrl+Shift+V` |
| All other apps | `Ctrl+C` | `Ctrl+V` | `Ctrl+Shift+V` |

Terminals get a different mapping because `Ctrl+C` in a terminal sends SIGINT, not copy.

## Adding more terminal apps

Edit `config.yml` and add the app's WM class to the `only` list:

```bash
xprop | grep WM_CLASS   # click on the terminal window when prompted
```

## Conflicts cleared

| Shortcut | Was | Now |
|---|---|---|
| Super+V | GNOME notification tray | *(freed — tray is still on Super+M)* |
| Super+A | GNOME app drawer | *(freed — app drawer moved to Super+Space)* |
| Super+Space | Switch input source | *(freed — rebound to Ctrl+Alt+Space)* |
| Super (alone) | Open Activities overview | *(disabled)* |
