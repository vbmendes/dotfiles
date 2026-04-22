# asdf setup

Installs [asdf](https://asdf-vm.com) and adds plugins for Python, Go, Node.js, and Rust.

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
1. Install asdf if not already present (prompts for install method)
2. Configure your selected shells
3. Add the language plugins

## Install methods

| Option | Requirement | Best for |
|--------|-------------|----------|
| Homebrew | `brew` | macOS / Linux with Homebrew |
| Zypper | `zypper` | openSUSE / SLES |
| AUR (Pacman) | `git`, `makepkg`, `base-devel` | Arch Linux |
| Source (git) | `git` | Ubuntu / Debian / anything else |

## Plugins installed

| Language | Plugin source |
|----------|--------------|
| Python | https://github.com/asdf-community/asdf-python |
| Go | https://github.com/asdf-community/asdf-golang |
| Node.js | https://github.com/asdf-vm/asdf-nodejs |
| Rust | https://github.com/asdf-community/asdf-rust |

## Installing a version

After setup, restart your shell, then:

```bash
asdf install python latest
asdf install golang latest
asdf install nodejs latest
asdf install rust latest
```

To set a global default:

```bash
asdf set -u python latest
```
