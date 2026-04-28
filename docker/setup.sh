#!/bin/bash
set -euo pipefail

OS="$(uname -s)"

# ── macOS ──────────────────────────────────────────────────────────────────────

if [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is required but not found. Install it first: https://brew.sh" >&2
    exit 1
  fi

  # ── Uninstall Docker Desktop if present ─────────────────────────────────────

  if brew list --cask docker &>/dev/null 2>&1; then
    echo "Removing Docker Desktop cask..."
    brew uninstall --cask docker
  fi

  if [[ -d "/Applications/Docker.app" ]]; then
    echo "Removing /Applications/Docker.app..."
    rm -rf "/Applications/Docker.app"
  fi

  for leftover in \
    "$HOME/Library/Application Support/Docker Desktop" \
    "$HOME/Library/Group Containers/group.com.docker" \
    "$HOME/Library/Logs/Docker Desktop" \
    "$HOME/Library/Preferences/com.docker.docker.plist" \
    "$HOME/Library/Saved Application State/com.electron.docker-frontend.savedState" \
    "$HOME/.docker/cli-plugins/docker-compose"; do
    if [[ -e "$leftover" ]]; then
      echo "Removing $leftover..."
      rm -rf "$leftover"
    fi
  done

  # ~/Library/Containers entries are managed by macOS sandbox — remove contents
  # but tolerate errors on the OS-owned metadata plist
  for container in "$HOME"/Library/Containers/com.docker.*; do
    if [[ -d "$container" ]]; then
      echo "Removing $container..."
      rm -rf "$container" 2>/dev/null || true
    fi
  done

  # Remove Docker Desktop credentials helper if it points to Desktop
  for bin in /usr/local/bin/docker-credential-desktop /usr/local/bin/com.docker.cli; do
    if [[ -e "$bin" ]]; then
      echo "Removing $bin..."
      rm -f "$bin"
    fi
  done

  # Fix ~/.docker/config.json if it still references docker-credential-desktop
  config="$HOME/.docker/config.json"
  if [[ -f "$config" ]] && grep -q '"credsStore": "desktop"' "$config"; then
    echo "Updating Docker config: replacing credsStore 'desktop' with 'osxkeychain'..."
    python3 -c "
import json, sys
with open('$config') as f:
    cfg = json.load(f)
cfg['credsStore'] = 'osxkeychain'
cfg.pop('plugins', None)
cfg.pop('features', None)
with open('$config', 'w') as f:
    json.dump(cfg, f, indent='\t')
    f.write('\n')
"
  fi

  echo "Docker Desktop removed."
  echo ""

  # ── Install Docker CLI + Colima ──────────────────────────────────────────────

  if command -v docker &>/dev/null; then
    echo "Docker CLI already installed: $(docker --version)"
  else
    echo "Installing Docker CLI..."
    brew install docker
    echo "Docker CLI installed: $(docker --version)"
  fi

  if command -v docker-credential-osxkeychain &>/dev/null; then
    echo "docker-credential-osxkeychain already installed"
  else
    echo "Installing docker-credential-helper..."
    brew install docker-credential-helper
  fi

  if command -v colima &>/dev/null; then
    echo "Colima already installed: $(colima version)"
  else
    echo "Installing Colima (Docker runtime)..."
    brew install colima
    echo "Colima installed: $(colima version)"
  fi

  if colima status 2>/dev/null | grep -q "Running"; then
    echo "Colima already running"
  else
    echo "Starting Colima..."
    colima start
  fi

  # ── Docker Compose ───────────────────────────────────────────────────────────

  if docker compose version &>/dev/null 2>&1; then
    echo "Docker Compose already available: $(docker compose version)"
  else
    echo "Installing Docker Compose plugin..."
    brew install docker-compose
    mkdir -p "$HOME/.docker/cli-plugins"
    ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" "$HOME/.docker/cli-plugins/docker-compose"
    echo "Docker Compose installed: $(docker compose version)"
  fi

  echo ""
  echo "Done. Run 'docker run hello-world' to verify."
  exit 0
fi

# ── Linux (Ubuntu / Debian) ────────────────────────────────────────────────────

if [[ "$OS" != "Linux" ]]; then
  echo "Unsupported OS: $OS" >&2
  exit 1
fi

if command -v docker &>/dev/null; then
  echo "Docker already installed: $(docker --version)"
else
  echo "Installing Docker Engine..."

  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt remove -y "$pkg" 2>/dev/null || true
  done

  sudo apt update
  sudo apt install -y ca-certificates curl

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "Docker installed: $(docker --version)"
fi

# ── Docker Compose ─────────────────────────────────────────────────────────────

if docker compose version &>/dev/null; then
  echo "Docker Compose already installed: $(docker compose version)"
else
  echo "Installing Docker Compose plugin..."
  sudo apt install -y docker-compose-plugin
  echo "Docker Compose installed: $(docker compose version)"
fi

# ── Post-install: add user to docker group ─────────────────────────────────────

if groups "$USER" | grep -qw docker; then
  echo "User '${USER}' already in docker group"
else
  sudo usermod -aG docker "$USER"
  echo "Added '${USER}' to docker group — log out and back in for it to take effect"
fi

# ── Enable and start Docker service ───────────────────────────────────────────

if ! sudo systemctl is-enabled docker &>/dev/null; then
  sudo systemctl enable docker
  echo "Docker service enabled"
fi

if ! sudo systemctl is-active docker &>/dev/null; then
  sudo systemctl start docker
  echo "Docker service started"
else
  echo "Docker service already running"
fi

echo ""
echo "Done. Run 'docker run hello-world' to verify (may need a new shell for group to take effect)."
