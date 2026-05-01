# Screenshot Setup

Uses [Flameshot](https://flameshot.org/) for screenshots on GNOME/Ubuntu.

## Install

```bash
sudo apt install flameshot
```

## Keybindings

| Shortcut | Action |
|---|---|
| `Ctrl+Alt+Shift+Super+F3` | Full screenshot (copied to clipboard) |
| `Ctrl+Alt+Shift+Super+F4` | Area selection with annotation toolbar |

## Setup

```bash
./screenshot/setup.sh
```

Registers the keybindings as GNOME custom keybindings. Merges safely with any existing custom keybindings.

## Rollback

```bash
./screenshot/rollback.sh
```

Removes all custom keybindings whose ID starts with `flameshot-`, leaving other custom keybindings untouched.
