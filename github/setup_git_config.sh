#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}==>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}!${RESET} $*"; }
error()   { echo -e "${RED}✗${RESET} $*"; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

install_vim() {
    if command -v apt &>/dev/null; then
        sudo apt update -q && sudo apt install -y vim
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y vim
    elif command -v yum &>/dev/null; then
        sudo yum install -y vim
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm vim
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y vim
    elif command -v brew &>/dev/null; then
        brew install vim
    else
        error "No supported package manager found. Install vim manually and re-run."
        exit 1
    fi
}

prompt_value() {
    local label="$1"
    local current="$2"
    local result
    if [[ -n "$current" ]]; then
        read -rp "$(echo -e "${YELLOW}?${RESET} ${label} [${current}]: ")" result
        echo "${result:-$current}"
    else
        while true; do
            read -rp "$(echo -e "${YELLOW}?${RESET} ${label}: ")" result
            [[ -n "$result" ]] && break
            warn "Value cannot be empty."
        done
        echo "$result"
    fi
}

# ── user.name ─────────────────────────────────────────────────────────────────

header "Git Initial Configuration"

current_name=$(git config --global user.name 2>/dev/null || true)
name=$(prompt_value "user.name (full name)" "$current_name")
git config --global user.name "$name"
success "user.name set to '${name}'"

# ── user.email ────────────────────────────────────────────────────────────────

current_email=$(git config --global user.email 2>/dev/null || true)
email=$(prompt_value "user.email" "$current_email")
git config --global user.email "$email"
success "user.email set to '${email}'"

# ── pull.rebase ───────────────────────────────────────────────────────────────

git config --global pull.rebase false
success "pull.rebase set to false (merge strategy)"

# ── core.editor ───────────────────────────────────────────────────────────────

git config --global core.editor vim
success "core.editor set to vim"

# ── push.autoSetupRemote ──────────────────────────────────────────────────────

git config --global push.autoSetupRemote true
success "push.autoSetupRemote set to true"

# ── diff ──────────────────────────────────────────────────────────────────────

git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true
success "diff settings configured"

# ── fetch ─────────────────────────────────────────────────────────────────────

git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global fetch.all true
success "fetch settings configured"

# ── merge ─────────────────────────────────────────────────────────────────────

git config --global merge.conflictStyle zdiff3
success "merge.conflictStyle set to zdiff3"

# ── Summary ───────────────────────────────────────────────────────────────────

header "Done!"
echo ""
echo "  user.name:        $(git config --global user.name)"
echo "  user.email:       $(git config --global user.email)"
echo "  pull.rebase:      $(git config --global pull.rebase)"
echo "  core.editor:      $(git config --global core.editor)"
echo "  autoSetupRemote:  $(git config --global push.autoSetupRemote)"
echo "  diff.colorMoved:  $(git config --global diff.colorMoved)"
echo "  diff.mnemonicPrefix: $(git config --global diff.mnemonicPrefix)"
echo "  diff.renames:     $(git config --global diff.renames)"
echo "  fetch.prune:      $(git config --global fetch.prune)"
echo "  fetch.pruneTags:  $(git config --global fetch.pruneTags)"
echo "  fetch.all:        $(git config --global fetch.all)"
echo "  merge.conflictStyle: $(git config --global merge.conflictStyle)"
echo ""
success "Git global config updated."
