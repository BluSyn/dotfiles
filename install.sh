#!/usr/bin/env bash
# NOTE: *SHOULD* be safe to run multiple times
# Assumes dotfiles is cloned locally (e.g. git clone git@github.com:BluSyn/dotfiles.git ~/dotfiles)
# Supported OS: macOS (Homebrew), Arch Linux (pacman), Debian and Ubuntu (apt)

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SHARED_PKGS=(git openssl wget curl unzip ripgrep fzf fish tmux tmuxp bat htop jq)
BREW_PKGS=(eza starship rustup nvim herdr opencode)
BREW_CASKS=(nikitabobko/tap/aerospace wezterm alacritty)
PACMAN_PKGS=(eza starship rustup neovim)
APT_PKGS=(xz-utils neovim)

CONFIGS_ONLY=0
FORCE_FONTS=0
INSTALL_GUI=0

usage() {
  cat << 'EOF'
Usage: install.sh [options]

Options:
  --configs-only   Only update submodules, config symlinks, and herdr plugins
  --force-fonts    Re-download and reinstall the Nerd Font even if already installed
  --gui            Also install macOS GUI casks (AeroSpace, WezTerm, Alacritty)
  -h, --help       Show this help message
EOF
}

mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/.grok/bin:${HOME}/.opencode/bin:${PATH}"

have_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]]
}

find_sudo() {
  local p
  command -v sudo 2> /dev/null && return 0
  for p in /usr/bin/sudo /bin/sudo /usr/local/bin/sudo; do
    if [[ -x $p ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done
  return 1
}

as_root() {
  if have_root; then
    "$@"
  else
    local sudo_bin
    sudo_bin=$(find_sudo) || return 1
    "$sudo_bin" "$@"
  fi
}

is_debian_like() {
  [[ -r /etc/os-release ]] && (
    . /etc/os-release
    [[ ${ID-} == debian || ${ID-} == ubuntu || ${ID_LIKE-} == *debian* || ${ID_LIKE-} == *ubuntu* ]]
  )
}

is_omarchy() {
  [[ -d /usr/share/omarchy || -n ${OMARCHY_PATH-} ]]
}

run_installer() {
  local url=$1 interpreter=$2 tmp status=0
  shift 2
  tmp=$(mktemp) || return 1
  curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$tmp" \
    && "$interpreter" "$tmp" "$@" \
    || status=$?
  rm -f "$tmp"
  return "$status"
}

install_brew_packages() {
  if ! command -v brew &> /dev/null; then
    local brew_bin
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [[ -x $brew_bin ]]; then
        eval "$("$brew_bin" shellenv)"
        break
      fi
    done
  fi
  if ! command -v brew &> /dev/null; then
    echo "" >&2
    echo "Homebrew not found. Go to https://brew.sh" >&2
    return 1
  fi
  brew install "${SHARED_PKGS[@]}" "${BREW_PKGS[@]}" || return 1
  if [[ $INSTALL_GUI == 1 ]]; then
    brew install --cask "${BREW_CASKS[@]}" || return 1
  fi
}

# herdr and opencode are in Omarchy/Arch repos when available; otherwise fall back to upstream installers.
install_arch_packages() {
  local pkg pkgs=("${SHARED_PKGS[@]}" "${PACMAN_PKGS[@]}")

  as_root pacman -Sy || return 1
  for pkg in herdr opencode; do
    if pacman -Si "$pkg" &> /dev/null; then
      pkgs+=("$pkg")
    fi
  done
  as_root pacman -Syu --needed "${pkgs[@]}"
}

# Debian/Ubuntu package names differ (neovim, batcat, xz-utils for Nerd Font), and newer tools
# (eza, rustup, starship, herdr) may not be in apt on older releases. Also tolerates containers like
# node:22-trixie running as a non-root user without sudo.
install_apt_packages() {
  if ! command -v apt-get &> /dev/null; then
    echo "" >&2
    echo "apt-get not found." >&2
    return 1
  fi

  local pkg pkgs=("${SHARED_PKGS[@]}" "${APT_PKGS[@]}")
  local bin_dir="${HOME}/.local/bin"

  if have_root || find_sudo &> /dev/null; then
    as_root apt-get update || return 1
    for pkg in eza rustup starship herdr; do
      if apt-cache show "$pkg" &> /dev/null; then
        pkgs+=("$pkg")
      fi
    done
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || return 1
    bin_dir=/usr/local/bin
    as_root mkdir -p "$bin_dir"
  else
    echo ""
    echo "No root access and sudo is not installed. Skipping apt packages."
  fi

  # Debian/Ubuntu ship bat as batcat; fish/config.fish expects `bat`.
  if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
    if [[ -w $bin_dir ]]; then
      ln -sfn "$(command -v batcat)" "${bin_dir}/bat"
    else
      as_root ln -sfn "$(command -v batcat)" "${bin_dir}/bat"
    fi
  fi

  if ! command -v starship &> /dev/null; then
    run_installer https://starship.rs/install.sh sh -y -b "$bin_dir" || return 1
  fi

  if ! command -v rustup &> /dev/null; then
    # --no-modify-path: bashrc already sources ~/.cargo/env, and profile is a symlink into this repo.
    run_installer https://sh.rustup.rs sh -y --no-modify-path --default-toolchain stable || return 1
  fi
}

install_user_clis() {
  # Fallback when herdr was not installed via Homebrew, pacman, or apt.
  if ! command -v herdr &> /dev/null; then
    run_installer https://herdr.dev/install.sh sh || return 1
  fi

  # Grok's installer rewrites bashrc/fish config; those are symlinks into this repo.
  if ! command -v grok &> /dev/null; then
    (export SHELL=/bin/sh; run_installer https://x.ai/cli/install.sh bash) || return 1
  fi
  if [[ -x ${HOME}/.grok/bin/grok ]]; then
    ln -sfn "${HOME}/.grok/bin/grok" "${HOME}/.local/bin/grok"
  fi

  # OpenCode 2 fallback when not installed via Homebrew or pacman.
  if ! command -v opencode &> /dev/null; then
    run_installer https://opencode.ai/v2/install bash --no-modify-path || return 1
  fi
  if [[ -x ${HOME}/.opencode/bin/opencode ]]; then
    ln -sfn "${HOME}/.opencode/bin/opencode" "${HOME}/.local/bin/opencode"
  fi

  # Runs after Grok so Cursor keeps the `agent` command.
  if ! command -v cursor-agent &> /dev/null; then
    run_installer https://cursor.com/install bash || return 1
  fi
}

install_packages() {
  if [[ $OSTYPE == darwin* ]]; then
    install_brew_packages || return 1
  elif [[ $OSTYPE == linux* ]] && command -v pacman &> /dev/null; then
    install_arch_packages || return 1
  elif is_debian_like; then
    install_apt_packages || return 1
  else
    echo "" >&2
    echo "Unsupported OS. Supported: macOS (Homebrew), Arch Linux (pacman), Debian and Ubuntu (apt)." >&2
    return 1
  fi

  install_user_clis
}

# ln has different no-dereference flags on macOS vs Linux.
link() {
  local src="${DOTFILES}/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ $OSTYPE == darwin* ]]; then
    ln -sfh "$src" "$dst"
  elif [[ $OSTYPE == linux* ]]; then
    ln -sfT "$src" "$dst"
  fi
}

backup_and_link() {
  local dst="$2"
  if [[ -e $dst && ! -L $dst ]]; then
    mv "$dst" "${dst}.orig"
  fi
  link "$1" "$dst"
}

install_configs() {
  link bash/bashrc            "${HOME}/.bashrc"
  link bash/profile           "${HOME}/.profile"
  link bash/bashTweaks        "${HOME}/.bashTweaks"
  link git                    "${HOME}/.config/git"
  # Omarchy ships tmux and nvim as real directories.
  backup_and_link tmux        "${HOME}/.config/tmux"
  backup_and_link nvim        "${HOME}/.config/nvim"
  link tmuxp                  "${HOME}/.config/tmuxp"
  link wezterm                "${HOME}/.config/wezterm"
  link starship/starship.toml "${HOME}/.config/starship.toml"
  link herdr/config.toml      "${HOME}/.config/herdr/config.toml"
  # Link config files only so htop/fish can keep untracked state in their dirs.
  link htop/htoprc            "${HOME}/.config/htop/htoprc"
  link fish/config.fish       "${HOME}/.config/fish/config.fish"

  if [[ $OSTYPE == darwin* ]]; then
    link aerospace "${HOME}/.config/aerospace"
  fi

  if [[ $OSTYPE == linux* ]] && is_omarchy; then
    # Hyprland (Omarchy): share binds/input; keep machine-local monitors/looknfeel/autostart.
    link hypr/hyprland.lua "${HOME}/.config/hypr/hyprland.lua"
    link hypr/bindings.lua "${HOME}/.config/hypr/bindings.lua"
    link hypr/input.lua    "${HOME}/.config/hypr/input.lua"

    # Omarchy terminals: start fish instead of bash and use Omarchy's dynamic theme.
    if [[ -L ${HOME}/.config/alacritty ]]; then
      rm -f "${HOME}/.config/alacritty"
    fi
    link omarchy-terminal/alacritty.toml "${HOME}/.config/alacritty/alacritty.toml"
    link omarchy-terminal/foot.ini       "${HOME}/.config/foot/foot.ini"
    link omarchy-terminal/kitty.conf     "${HOME}/.config/kitty/kitty.conf"
    link omarchy-terminal/ghostty.config "${HOME}/.config/ghostty/config"

    # Asahi/brcmfmac: bounce Wi-Fi once after the desktop starts.
    link omarchy-hooks/asahi-wifi-bounce.sh "${HOME}/.config/omarchy/hooks/post-boot.d/asahi-wifi-bounce.sh"
    chmod 755 "${DOTFILES}/omarchy-hooks/asahi-wifi-bounce.sh"

    # Apple Silicon SPI trackpad quirks (install-quirks.sh copies to /etc/libinput/).
    if [[ -e ${HOME}/.config/libinput && ! -L ${HOME}/.config/libinput ]]; then
      rm -rf "${HOME}/.config/libinput"
    fi
    link libinput "${HOME}/.config/libinput"
    chmod 755 "${DOTFILES}/libinput/install-quirks.sh"
  else
    link alacritty "${HOME}/.config/alacritty"
  fi
}

# pane-nav actions are resolved by the herdr server that owns the session.
# Re-running link replaces the same plugin id.
install_herdr_plugins() {
  if [[ $OSTYPE != darwin* && $OSTYPE != linux* ]]; then
    echo "pane-nav is linux/macos only"
    return 0
  fi
  if ! command -v herdr &> /dev/null; then
    echo "" >&2
    echo "herdr not found" >&2
    return 1
  fi
  herdr plugin link "${DOTFILES}/herdr/plugins/pane-nav" || return 1
  # Apply updated config/plugins immediately if a herdr server is running.
  herdr server reload-config &> /dev/null || true
}

install_rust() {
  if ! command -v rustup &> /dev/null; then
    echo "" >&2
    echo "rustup not found; skipping." >&2
    return 0
  fi
  if ! rustup show active-toolchain &> /dev/null; then
    rustup default stable
  fi
}

# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/DejaVuSansMono
install_nerd_font() {
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/DejaVuSansMono.tar.xz"
  local tmp font_dir

  if [[ $OSTYPE == darwin* ]]; then
    font_dir="${HOME}/Library/Fonts"
  elif [[ $OSTYPE == linux* ]]; then
    font_dir="${HOME}/.local/share/fonts"
  else
    return 0
  fi

  if [[ $FORCE_FONTS != 1 ]] && compgen -G "${font_dir}/DejaVuSansM*.ttf" &> /dev/null; then
    return 0
  fi

  tmp=$(mktemp) || return 1
  if curl -fsSL "$url" -o "$tmp"; then
    mkdir -p "$font_dir"
    if [[ $OSTYPE == darwin* ]]; then
      tar -xvf "$tmp" -C "$font_dir" '*.ttf'
    else
      tar -xvf "$tmp" -C "$font_dir" --wildcards '*.ttf'
      if command -v fc-cache &> /dev/null; then
        fc-cache -f "$font_dir"
      fi
    fi
  fi
  rm -f "$tmp"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --configs-only) CONFIGS_ONLY=1 ;;
      --force-fonts)  FORCE_FONTS=1 ;;
      --gui)          INSTALL_GUI=1 ;;
      -h|--help)      usage; exit 0 ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [[ $CONFIGS_ONLY != 1 ]]; then
    echo -n "Installing default packages..."
    if ! install_packages; then
      echo "❌"
      echo "Failed to install packages!"
      exit 1
    fi
    echo "✔︎"
  fi

  echo -n "Git Submodules... "
  git -C "$DOTFILES" submodule update --init --recursive
  echo "✔︎"

  echo -n "Installing Configs..."
  install_configs
  echo "✔︎"

  if [[ $CONFIGS_ONLY != 1 ]] || command -v herdr &> /dev/null; then
    echo -n "Linking herdr plugins... "
    if ! install_herdr_plugins; then
      echo "❌"
      echo "Failed to link herdr plugins!"
      exit 1
    fi
    echo "✔︎"
  fi

  if [[ $CONFIGS_ONLY != 1 ]]; then
    echo -n "Installing Rust... "
    install_rust
    echo "✔︎"

    echo -n "Installing Nerd Font... "
    install_nerd_font
    echo "✔︎"
  fi

  echo "Installation Complete ✔︎"
}

main "$@"
