#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

packages=()
while IFS= read -r line; do
    line="${line%%#*}"   # strip inline comments
    line="${line// /}"   # strip spaces
    [[ -n "$line" ]] && packages+=("$line")
done < "${SCRIPT_DIR}/apt.txt"

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "No packages found in apt.txt"
    exit 0
fi

echo "Installing ${#packages[@]} packages..."
sudo apt update -q
sudo apt install -y "${packages[@]}"
echo "Done."
