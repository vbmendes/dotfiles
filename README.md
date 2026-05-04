# dotfiles

Personal machine setup for macOS and Linux (GNOME). Covers package management, Docker, GitHub SSH/signing, window management, keyboard firmware, and key remapping.

---

## Initial setup

### macOS

```sh
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install packages
brew bundle

# 3. Install rosetta
softwareupdate --install-rosetta

# 4. Post-Homebrew tweaks (adds libpq to PATH)
./scripts/postbrew.sh

# 5. Docker
./docker/setup.sh

# 6. GitHub SSH key and commit signing
./github/setup_github_ssh.sh

# 7. Runtime version manager (Python, Go, Node, Rust)
./asdf/setup.sh

# 8. App switcher (requires Hammerspoon from step 2)
./window-switcher-mac/setup.sh

# 9. (Optional) Sofle v2 keyboard firmware
./keyboard/setup.sh
./keyboard/compile.sh
```

### Linux (GNOME)

```sh
# 1. Docker
./docker/setup.sh

# 2. GitHub SSH key and commit signing
./github/setup_github_ssh.sh

# 3. Runtime version manager (Python, Go, Node, Rust)
./asdf/setup.sh

# 4. System-wide key remapping (Super as Cmd)
./xremap/setup.sh

# 5. App switcher
./window-switcher/setup.sh

# 6. Window tiling (requires gTile GNOME extension)
./tiling/setup.sh

# 7. Cedilla fix (ç via RALT+C)
./scripts/fix_cedilla.sh

# 8. Lock screen shortcut (Ctrl+Super+Q)
./scripts/setup_lock_shortcut.sh

# 9. (Optional) Sofle v2 keyboard firmware
./keyboard/setup.sh
./keyboard/compile.sh
```

---

## Modules

### Brewfile — macOS packages

Installs Homebrew packages: `libpq` (PostgreSQL CLI tools) and `xz` (compression), plus the `hammerspoon` cask for macOS automation.

Run with:

```sh
brew bundle
```

---

### scripts/ — Post-install utilities

**`scripts/postbrew.sh`** — Run after `brew bundle`. Adds `libpq` binaries (`psql`, `pg_dump`, etc.) to `PATH` in `~/.zshrc`. Required because Homebrew installs `libpq` keg-only to avoid conflicting with the `postgresql` formula.

**`scripts/fix_cedilla.sh`** _(Linux)_ — Configures the keyboard to produce `ç` via `RALT+C` using a custom XKB symbols file and GNOME input source registration.

**`scripts/setup_lock_shortcut.sh`** _(Linux/GNOME)_ — Binds `Ctrl+Super+Q` to lock the screen.

---

### asdf/ — Runtime version manager

Installs [asdf](https://asdf-vm.com/) and sets up plugins for Python, Go, Node.js, and Rust. Installs the latest version of each and sets it as the global default.

```sh
./asdf/setup.sh
```

Supports install via Homebrew, Zypper, AUR, or a direct binary download.

---

### docker/ — Docker Engine

**macOS:** Removes Docker Desktop, installs Docker CLI + [Colima](https://github.com/abiosoft/colima) as a lightweight runtime, configures `docker-credential-osxkeychain`, and installs Docker Compose as a plugin.

**Linux:** Adds the official Docker apt repository, installs `docker-ce` and related packages, adds the current user to the `docker` group, and enables the systemd service.

```sh
./docker/setup.sh
```

---

### github/ — SSH authentication and commit signing

Generates an `ed25519` SSH key, adds it to the SSH agent, and walks you through registering it on GitHub as both an authentication key and a signing key. Configures Git to sign all commits automatically via SSH.

```sh
./github/setup_github_ssh.sh
```

---

### keyboard/ — Sofle v2 QMK firmware

Custom firmware for a Sofle v2 split keyboard with 5 layers:

| Layer | Contents |
|---|---|
| QWERTY | Base layer with home-row combos (D+F = Left Shift, etc.) |
| SYMBOLS | Symbols, brackets, cedilla (ç) |
| NUMPAD | Numpad, arrows |
| FUNCTION | F-keys |
| NAV | Navigation, media |

OLED display support and per-key encoder mappings are included.

```sh
./keyboard/setup.sh   # install QMK CLI and copy keymap files
./keyboard/compile.sh # compile firmware and print flashing instructions
```

---

### window-switcher-mac/ — App switcher for macOS

Hammerspoon scripts that bind `Hyper` (Shift+Ctrl+Alt+Cmd) + a key to focus an app or launch it if it isn't running. Repeated presses within 2 seconds cycle through the app's open windows in most-recently-used order.

Default bindings: `a` Calendar, `b` Chrome, `c` Slack, `e` VS Code, `f` Finder, `m` Spotify, `n` Obsidian, `p` 1Password, `t` Terminal, `u` Cursor, `w` WhatsApp, and more.

```sh
./window-switcher-mac/setup.sh
```

To add a shortcut without re-running setup:

```sh
./window-switcher-mac/add-shortcut
```

---

### window-switcher/ — App switcher for Linux/GNOME

GNOME custom keybindings equivalent to `window-switcher-mac`. Uses `wmctrl` and `xdotool` to focus or launch apps, cycling through windows by most-recently-used order on repeated presses.

Modifier: `Ctrl+Alt+Shift+Super`. Same key layout as the macOS module.

```sh
./window-switcher/setup.sh
./window-switcher/add-shortcut     # add a single shortcut without re-running setup
./window-switcher/remove-shortcuts # remove all registered shortcuts
```

---

### tiling/ — Window tiling

**macOS:** Uses [Rectangle](https://rectangleapp.com/) for window tiling. Install it via Homebrew or directly from the website.

**Linux/GNOME:** Configures [gTile](https://github.com/gTile/gTile) preset layouts on a 6×4 grid via `Ctrl+Alt` shortcuts:

| Keys | Layout |
|---|---|
| Arrow keys | Halves (left/right/top/bottom) |
| U / I / J / K | Quarters |
| D / F / G | Thirds |
| E / R / T | Two-thirds |
| Return | Fullscreen |

```sh
./tiling/setup.sh
./tiling/rollback.sh  # restore original GNOME keybindings
```

---

### xremap/ — System-wide key remapping for Linux

Makes `Super+C/V` behave like macOS `Cmd+C/V` everywhere. Terminals receive `Ctrl+Shift+C/V` instead to avoid conflicts. Also remaps `Super+X/A/Z/W/Q` and `Alt+Left/Right` to their expected macOS equivalents.

```sh
./xremap/setup.sh
```

Installs xremap as a systemd user service that starts on login.
