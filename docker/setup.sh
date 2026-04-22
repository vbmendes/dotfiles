#!/bin/bash
set -euo pipefail

# ── Docker Engine ──────────────────────────────────────────────────────────────

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
