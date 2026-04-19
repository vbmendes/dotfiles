# window-switcher

GNOME keyboard shortcuts that focus an already-running window or launch the app if it isn't open. Pressing the same shortcut multiple times cycles through all windows of that app.

Shortcuts are registered as GNOME custom keybindings via `gsettings` and are namespaced under `vbmendes-dotfiles-` so they can be cleanly removed and re-applied without touching any shortcuts you set up manually.

## Scripts

### `setup.sh`
Full install. Installs `wmctrl` and `xdotool` if missing, copies `focus-or-launch` to `~/.local/bin`, removes any previously registered dotfiles shortcuts, then registers all entries from the `SHORTCUTS` array.

Edit the `SHORTCUTS` array at the top of this file to configure your bindings. Each entry has the form:

```
"KEY|NAME|WINDOW_PATTERN|LAUNCH_COMMAND[|WM_CLASS]"
```

- **KEY** — single key combined with `MODIFIER` (default `<Ctrl><Alt><Shift><Super>`)
- **NAME** — human-readable label shown in GNOME Settings
- **WINDOW_PATTERN** — substring matched against window titles to detect a running instance
- **LAUNCH_COMMAND** — command to run when no window is found
- **WM_CLASS** *(optional)* — match by WM_CLASS instead of title (more reliable for terminals and Electron apps)

To find the WM_CLASS of a window, switch to it first, then run:

```bash
sleep 3 && xprop -id $(xdotool getactivewindow) WM_CLASS
```

The `sleep 3` gives you time to click on the target window before the command captures the active window.

### `add-shortcut`
Add a single new shortcut without re-running the full setup. Appends the entry to `setup.sh` and immediately registers it in gsettings.

```bash
# Direct launch command
./add-shortcut <KEY> <NAME> --launch <COMMAND> --pattern <PATTERN>

# Chrome installed app (auto-detects launch command and WM_CLASS)
./add-shortcut <KEY> <NAME> --chrome-app <SEARCH> --pattern <PATTERN>
```

The `--chrome-app` mode searches `~/.local/share/applications/chrome-*.desktop` by app name, extracts the app ID, and derives the correct `gtk-launch` command and `crx_<id>` WM_CLASS automatically.

If the key is already bound, the script prints the existing binding and prompts you to confirm before replacing it. Pass `--no-apply` to update `setup.sh` without registering the shortcut in gsettings immediately.

### `register-shortcut`
Low-level script called by `setup.sh` and `add-shortcut`. Registers a single entry into gsettings and merges its path into the GNOME custom-keybindings list.

```bash
./register-shortcut "KEY|NAME|PATTERN|COMMAND[|WM_CLASS]"
```

### `remove-shortcuts`
Removes all shortcuts whose gsettings path starts with `vbmendes-dotfiles-`, leaving any manually created shortcuts untouched.

```bash
./remove-shortcuts
```

### `focus-or-launch`
The runtime helper copied to `~/.local/bin`. Each shortcut calls this script, which finds existing windows matching the pattern (or WM_CLASS) and focuses them, cycling through multiple windows on repeated presses. If no window is found, it runs the launch command.

When multiple windows exist, they are ordered by most recently used first (`_NET_WM_USER_TIME`). The order is snapshotted on the first press and reused as long as you keep pressing the shortcut within 2 seconds of the previous press. After 2 seconds of inactivity the snapshot resets, so the next press re-sorts by most recently used again.

```bash
focus-or-launch [--class <WM_CLASS>] <PATTERN> <COMMAND>
```
