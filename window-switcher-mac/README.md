# window-switcher-mac

Hammerspoon keyboard shortcuts that focus an already-running window or launch the app if it isn't open. Pressing the same shortcut multiple times cycles through all windows of that app, ordered by most recently used.

The modifier is **Shift+Ctrl+Alt+Cmd** (the "hyper" key).

## Requirements

- [Hammerspoon](https://www.hammerspoon.org) — `brew install --cask hammerspoon`
- Accessibility permission granted to Hammerspoon (System Settings → Privacy & Security → Accessibility)

## Installation

```bash
./setup.sh
```

`setup.sh` symlinks `hyper.lua` and `hyper-apps.lua` into `~/.hammerspoon/` and adds `require('hyper')` to your `init.lua` (creating a minimal one if none exists). It then reloads Hammerspoon if it's running.

Because the files are symlinked, any edit to `hyper-apps.lua` in this directory is immediately reflected — just reload Hammerspoon (Ctrl+`` ` ``) to apply.

## Configuration

Edit `hyper-apps.lua` to configure your shortcuts. Each entry has the form:

```lua
{ 'KEY', 'AppName' [, 'WindowCycleId'] }
```

- **KEY** — single alphanumeric character combined with the hyper modifier
- **AppName** — exact app name as shown in Activity Monitor, or a bundle ID
- **WindowCycleId** *(optional)* — the name Hammerspoon sees for the app's windows when it differs from `AppName` (e.g. VS Code opens as `'Visual Studio Code'` but its windows belong to `'Code'`)

### Finding the right names

```bash
# AppName from the Hammerspoon console (with the app open):
hs.application.frontmostApplication():name()

# WindowCycleId (when windows don't match AppName):
hs.window.focusedWindow():application():name()

# Bundle ID:
mdls -name kMDItemCFBundleIdentifier /Applications/App.app
```

After editing `hyper-apps.lua`, reload Hammerspoon with Ctrl+`` ` ``.

## Adding a shortcut

```bash
./add-shortcut <KEY> <AppName> [<WindowCycleId>]
```

Examples:

```bash
./add-shortcut g 'Google Chrome'
./add-shortcut e 'Visual Studio Code' Code
```

The script updates `hyper-apps.lua` and reloads Hammerspoon automatically. If the key is already bound it prompts you to confirm before replacing it.

## How cycling works

On the **first press**: if the app is not frontmost, it is focused (or launched). macOS activates the most recently used window automatically.

On **repeated presses within 2 seconds**: cycles through all visible, non-minimised windows of the app in MRU order. The order is snapshotted on the first press of each burst and reused until 2 seconds pass without a press. After the timeout the snapshot resets, so the next press re-sorts by most recently used.

## Reloading

Hammerspoon is reloaded automatically by `setup.sh` and `add-shortcut` if the `hs` CLI is available (`brew install hammerspoon` installs it). You can also reload manually:

- **Ctrl+`` ` ``** — keyboard shortcut defined in `init.lua`
- Hammerspoon menu bar icon → Reload Config
