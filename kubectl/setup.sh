#!/bin/bash
set -euo pipefail

# ── kubectl ────────────────────────────────────────────────────────────────────

if command -v kubectl &>/dev/null; then
  echo "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
  echo "Installing kubectl..."

  sudo apt update
  sudo apt install -y apt-transport-https ca-certificates curl gnupg

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

  sudo apt update
  sudo apt install -y kubectl

  echo "kubectl installed: $(kubectl version --client)"
fi
