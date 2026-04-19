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
prompt()  { echo -e "${YELLOW}?${RESET} $*"; }

pause() {
    echo ""
    read -rp "$(echo -e "${BLUE}[Press Enter to continue]${RESET}")" _
}

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

open_url() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" 2>/dev/null &
    elif command -v open &>/dev/null; then
        open "$url" 2>/dev/null &
    fi
}

install_git() {
    if command -v apt &>/dev/null; then
        sudo apt update -q && sudo apt install -y git
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git
    elif command -v yum &>/dev/null; then
        sudo yum install -y git
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm git
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y git
    elif command -v brew &>/dev/null; then
        brew install git
    else
        error "Could not detect a supported package manager. Install git manually and re-run."
        exit 1
    fi
}

# ── Prerequisite: git ─────────────────────────────────────────────────────────

if ! command -v git &>/dev/null; then
    warn "git is not installed."
    if confirm "Install git now?"; then
        install_git
        success "git installed: $(git --version)"
    else
        error "git is required. Exiting."
        exit 1
    fi
else
    success "git found: $(git --version)"
fi

# ── Step 1: Generate SSH key ──────────────────────────────────────────────────

header "Step 1 — Generate SSH Key"

default_key="$HOME/.ssh/id_ed25519"

read -rp "$(echo -e "${YELLOW}?${RESET} Email for SSH key label: ")" email
if [[ -z "$email" ]]; then
    error "Email cannot be empty."
    exit 1
fi

read -rp "$(echo -e "${YELLOW}?${RESET} Key path [${default_key}]: ")" key_path
key_path="${key_path:-$default_key}"
pub_key="${key_path}.pub"

if [[ -f "$key_path" ]]; then
    warn "Key already exists at ${key_path}"
    if ! confirm "Overwrite it?"; then
        info "Using existing key at ${key_path}"
    else
        ssh-keygen -t ed25519 -C "$email" -f "$key_path"
        success "Key generated at ${key_path}"
    fi
else
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
    success "Key generated at ${key_path}"
fi

# ── Step 2: Add to SSH agent ──────────────────────────────────────────────────

header "Step 2 — Add Key to SSH Agent"

eval "$(ssh-agent -s)" >/dev/null
ssh-add "$key_path"
success "Key added to SSH agent."

# Persistence
if [[ "$OSTYPE" == "linux"* ]]; then
    if confirm "Make SSH agent persistent across sessions (adds to ~/.bashrc)?"; then
        shell_rc="$HOME/.bashrc"
        {
            echo ""
            echo '# SSH agent'
            echo 'eval "$(ssh-agent -s)"'
            echo "ssh-add ${key_path}"
        } >> "$shell_rc"
        success "Added SSH agent startup to ${shell_rc}"
    fi
fi

pause

# ── Step 3: Add to GitHub as Authentication Key ───────────────────────────────

header "Step 3 — Add Public Key to GitHub (Authentication)"

pub_key_content=$(cat "$pub_key")
info "Your public key:"
echo ""
echo "    ${pub_key_content}"
echo ""

if command -v xclip &>/dev/null; then
    echo "$pub_key_content" | xclip -selection clipboard
    success "Copied to clipboard."
elif command -v pbcopy &>/dev/null; then
    echo "$pub_key_content" | pbcopy
    success "Copied to clipboard."
else
    warn "Could not copy automatically — copy the key above manually."
fi

info "Opening GitHub SSH key settings..."
open_url "https://github.com/settings/ssh/new"

echo ""
echo "  1. Set Key type → ${BOLD}Authentication Key${RESET}"
echo "  2. Paste the public key and save."
echo ""

pause

info "Testing GitHub SSH connection..."
if ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 | grep -q "successfully authenticated"; then
    success "GitHub authentication works!"
else
    warn "Could not confirm authentication — check GitHub and try: ssh -T git@github.com"
fi

# ── Step 4: Add to GitHub as Signing Key ─────────────────────────────────────

header "Step 4 — Add Public Key to GitHub (Signing)"

info "The same key must also be added as a Signing Key on GitHub."
info "Opening GitHub SSH key settings again..."
open_url "https://github.com/settings/ssh/new"

echo ""
echo "  1. Paste the same public key."
echo "  2. Set Key type → ${BOLD}Signing Key${RESET}"
echo "  3. Save."
echo ""

pause

# ── Step 5: Configure Git for SSH signing ────────────────────────────────────

header "Step 5 — Configure Git for SSH Commit Signing"

git config --global gpg.format ssh
git config --global user.signingkey "$pub_key"
git config --global commit.gpgsign true

if confirm "Also auto-sign tags?"; then
    git config --global tag.gpgsign true
    success "Tag signing enabled."
fi

# Set email if not already configured
current_email=$(git config --global user.email 2>/dev/null || true)
if [[ -z "$current_email" ]]; then
    git config --global user.email "$email"
    success "Git user.email set to ${email}"
elif [[ "$current_email" != "$email" ]]; then
    warn "Git user.email is currently '${current_email}', not '${email}'."
    if confirm "Update git user.email to '${email}'?"; then
        git config --global user.email "$email"
        success "Updated."
    fi
fi

success "Git signing configured."

# ── Step 6: Allowed signers file ──────────────────────────────────────────────

header "Step 6 — Set Up Allowed Signers File"

allowed_signers_dir="$HOME/.config/git"
allowed_signers_file="${allowed_signers_dir}/allowed_signers"
git_email=$(git config --global user.email)

mkdir -p "$allowed_signers_dir"

# Avoid duplicate entries
if grep -qF "$pub_key_content" "$allowed_signers_file" 2>/dev/null; then
    info "Key already present in ${allowed_signers_file}"
else
    echo "${git_email} ${pub_key_content}" >> "$allowed_signers_file"
    success "Added key to ${allowed_signers_file}"
fi

git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"
success "allowedSignersFile configured."

# ── Step 7: Verify ────────────────────────────────────────────────────────────

header "Step 7 — Verify Signed Commits"

if confirm "Create a test signed commit in a temporary repo to verify?"; then
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    git -C "$tmp_dir" init -q
    git -C "$tmp_dir" commit --allow-empty -m "test: verify signed commits"
    echo ""
    git -C "$tmp_dir" log --show-signature -1
    echo ""
    success "Verification complete. Look for 'Good \"git\" signature' above."
fi

# ── Summary ───────────────────────────────────────────────────────────────────

header "Done!"
echo ""
echo "  SSH key:        ${key_path}"
echo "  Public key:     ${pub_key}"
echo "  Allowed signers: ${allowed_signers_file}"
echo ""
success "All commits will now be automatically signed and show as Verified on GitHub."
