# CopyQ setup

Installs [CopyQ](https://hluk.github.io/CopyQ/) as a clipboard history manager with support for images and automatic filtering of password manager entries.

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
1. Install CopyQ via `apt`
2. Configure autostart on login
3. Import the ignore rules for 1Password

## Filtering 1Password entries

The file `ignore_secrets.ini` contains a CopyQ automatic command that detects when the clipboard was set by the **1Password desktop app** and silently discards it, so passwords are never stored in history.

### Limitation: Chrome extension

When copying from the **1Password browser extension**, the clipboard owner is Chrome itself — there is no reliable way to distinguish it from a regular copy in a web page. The ignore rule does **not** cover this case.

Workaround options:
- In 1Password browser extension settings, enable **"Clear clipboard after"** (e.g. 90 seconds) — the entry will be short-lived in history.
- Or: go to CopyQ → Preferences → Commands → Import `ignore_secrets.ini` and extend the script to also check for Chrome's window title if you find a reliable pattern.

## Images

CopyQ stores images copied to the clipboard by default — no extra configuration needed.

## Keyboard shortcut

To open the CopyQ history popup, bind a shortcut in CopyQ → Preferences → Shortcuts → **"Show/hide main window"**. A common choice is `Meta+V` or `Ctrl+Alt+V`.
