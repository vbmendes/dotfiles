#!/bin/bash
set -euo pipefail

ASDF_VERSION="v0.18.1"

PLUGINS=(
  "python|https://github.com/asdf-community/asdf-python.git"
  "golang|https://github.com/asdf-community/asdf-golang.git"
  "nodejs|https://github.com/asdf-vm/asdf-nodejs.git"
  "rust|https://github.com/asdf-community/asdf-rust.git"
)

# ── Install asdf ───────────────────────────────────────────────────────────────

if command -v asdf &>/dev/null; then
  echo "asdf already installed: $(asdf version)"
  INSTALL_METHOD="existing"
else
  echo "Select asdf install method:"
  echo "  1) Homebrew     (macOS/Linux, requires brew)"
  echo "  2) Zypper       (openSUSE/SLES, requires zypper)"
  echo "  3) AUR (Pacman) (Arch Linux, requires git + makepkg)"
  echo "  4) Binary        (any OS, including Ubuntu — downloads from GitHub releases)"
  echo ""
  read -rp "Choice [1-4]: " choice

  case "$choice" in
    1) INSTALL_METHOD="brew" ;;
    2) INSTALL_METHOD="zypper" ;;
    3) INSTALL_METHOD="aur" ;;
    4) INSTALL_METHOD="binary" ;;
    *) echo "Invalid choice." >&2; exit 1 ;;
  esac

  echo "Installing asdf ${ASDF_VERSION} via ${INSTALL_METHOD}..."
  case "$INSTALL_METHOD" in
    brew)
      if ! command -v brew &>/dev/null; then
        echo "Error: brew not found." >&2; exit 1
      fi
      brew install asdf
      ;;
    zypper)
      if ! command -v zypper &>/dev/null; then
        echo "Error: zypper not found." >&2; exit 1
      fi
      sudo zypper install -y asdf
      ;;
    aur)
      if ! command -v makepkg &>/dev/null; then
        echo "Error: makepkg not found. Install base-devel first." >&2; exit 1
      fi
      TMP_DIR=$(mktemp -d)
      git clone https://aur.archlinux.org/asdf-vm.git "$TMP_DIR/asdf-vm"
      (cd "$TMP_DIR/asdf-vm" && makepkg -si)
      rm -rf "$TMP_DIR"
      ;;
    binary)
      OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
      ARCH="$(uname -m)"
      case "$ARCH" in
        x86_64)         ARCH="amd64" ;;
        aarch64|arm64)  ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
      esac
      VER="${ASDF_VERSION#v}"
      URL="https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf_${VER}_${OS}_${ARCH}.tar.gz"
      INSTALL_DIR="$HOME/.local/bin"
      mkdir -p "$INSTALL_DIR"
      echo "Downloading asdf ${ASDF_VERSION} (${OS}/${ARCH})..."
      curl -fsSL "$URL" | tar -xz -C "$INSTALL_DIR" asdf
      chmod +x "$INSTALL_DIR/asdf"
      export ASDF_DATA_DIR="$HOME/.asdf"
      export PATH="$INSTALL_DIR:$ASDF_DATA_DIR/shims:$PATH"
      ;;
  esac
  echo "asdf installed: $(asdf version)"
fi

# Remove legacy asdf.sh sourcing lines from a rc file and write the new line
_configure_rc() {
  local rc="$1" new_line="$2"
  # Remove old Bash-era sourcing lines
  sed -i '/asdf\.sh\|asdf\.fish/d' "$rc" 2>/dev/null || true
  if grep -qF "$new_line" "$rc" 2>/dev/null; then
    echo "already up-to-date in ${rc}"
  else
    echo "$new_line" >> "$rc"
    echo "updated ${rc}"
  fi
}

# ── Configure shells ───────────────────────────────────────────────────────────

declare -a AVAILABLE_SHELLS=()
command -v bash &>/dev/null && AVAILABLE_SHELLS+=("bash")
command -v zsh  &>/dev/null && AVAILABLE_SHELLS+=("zsh")
command -v fish &>/dev/null && AVAILABLE_SHELLS+=("fish")

if [[ ${#AVAILABLE_SHELLS[@]} -eq 0 ]]; then
  echo "No supported shells detected, skipping shell configuration."
else
  echo ""
  echo "Detected shells. Select which to configure (space-separated numbers, e.g. 1 2):"
  for i in "${!AVAILABLE_SHELLS[@]}"; do
    echo "  $((i+1))) ${AVAILABLE_SHELLS[$i]}"
  done
  echo ""
  read -rp "Choice: " shell_choices

  for num in $shell_choices; do
    idx=$((num - 1))
    if [[ $idx -lt 0 || $idx -ge ${#AVAILABLE_SHELLS[@]} ]]; then
      echo "Invalid selection: ${num}, skipping." >&2
      continue
    fi
    shell="${AVAILABLE_SHELLS[$idx]}"

    case "$shell" in
      bash)
        RC="$HOME/.bashrc"
        if [[ "$INSTALL_METHOD" == "brew" ]]; then
          LINE='export PATH="$(brew --prefix asdf)/bin:$PATH"'
        else
          LINE='export ASDF_DATA_DIR="$HOME/.asdf"; export PATH="$ASDF_DATA_DIR/shims:$PATH"'
        fi
        echo -n "bash: "; _configure_rc "$RC" "$LINE"
        ;;
      zsh)
        RC="$HOME/.zshrc"
        if [[ "$INSTALL_METHOD" == "brew" ]]; then
          LINE='export PATH="$(brew --prefix asdf)/bin:$PATH"'
        else
          LINE='export ASDF_DATA_DIR="$HOME/.asdf"; export PATH="$ASDF_DATA_DIR/shims:$PATH"'
        fi
        echo -n "zsh: "; _configure_rc "$RC" "$LINE"
        ;;
      fish)
        FISH_CONF="$HOME/.config/fish/conf.d/asdf.fish"
        mkdir -p "$(dirname "$FISH_CONF")"
        if [[ "$INSTALL_METHOD" == "brew" ]]; then
          LINE='fish_add_path (brew --prefix asdf)/bin'
        else
          LINE='set -gx ASDF_DATA_DIR $HOME/.asdf; fish_add_path $ASDF_DATA_DIR/bin $ASDF_DATA_DIR/shims'
        fi
        echo -n "fish: "; _configure_rc "$FISH_CONF" "$LINE"
        ;;
    esac
  done
fi

# ── Add plugins ────────────────────────────────────────────────────────────────

echo ""
for entry in "${PLUGINS[@]}"; do
  IFS='|' read -r name url <<< "$entry"
  if asdf plugin list 2>/dev/null | grep -q "^${name}$"; then
    echo "Plugin already added: ${name}"
  else
    echo "Adding plugin: ${name}"
    asdf plugin add "$name" "$url"
  fi
done

echo ""
echo "Done. Plugins: $(asdf plugin list | tr '\n' ' ')"
echo "Run 'asdf install <plugin> latest' to install a version."
