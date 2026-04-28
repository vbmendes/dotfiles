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

confirm() {
    local msg="$1"
    local response
    while true; do
        read -rp "$(echo -e "${YELLOW}?${RESET} ${msg} [y/n]: ")" response
        case "$response" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) warn "Please answer y or n." ;;
        esac
    done
}

# ── Already installed? ────────────────────────────────────────────────────────

if command -v gh &>/dev/null; then
    success "gh is already installed: $(gh --version | head -1)"
    if ! confirm "Reinstall / upgrade anyway?"; then
        exit 0
    fi
fi

# ── Install ───────────────────────────────────────────────────────────────────

header "Step 1 — Install GitHub CLI"

if command -v apt &>/dev/null; then
    info "Installing via GitHub's official apt repository..."

    (type -p wget >/dev/null || (sudo apt update && sudo apt install -y wget))

    sudo mkdir -p -m 755 /etc/apt/keyrings
    sudo mkdir -p -m 755 /etc/apt/sources.list.d

    out=$(mktemp)
    wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg
    cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    rm -f "$out"
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt update
    sudo apt install -y gh

elif command -v dnf &>/dev/null; then
    info "Installing via dnf..."
    sudo dnf install -y 'dnf-command(config-manager)'
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh

elif command -v yum &>/dev/null; then
    info "Installing via yum..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo yum install -y gh

elif command -v pacman &>/dev/null; then
    info "Installing via pacman..."
    sudo pacman -Sy --noconfirm github-cli

elif command -v brew &>/dev/null; then
    info "Installing via Homebrew..."
    brew install gh

else
    error "No supported package manager found. Install gh manually: https://github.com/cli/cli#installation"
    exit 1
fi

success "gh installed: $(gh --version | head -1)"

# ── Authenticate ──────────────────────────────────────────────────────────────

header "Step 2 — Authenticate with GitHub"

if gh auth status &>/dev/null; then
    success "Already authenticated."
else
    info "Running 'gh auth login'..."
    gh auth login
fi

# ── Summary ───────────────────────────────────────────────────────────────────

header "Done!"
echo ""
gh auth status
echo ""
success "GitHub CLI is ready to use."
