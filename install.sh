#!/usr/bin/env bash
# NOTE: *SHOULD* be safe to run multiple times

# Assumes dotfiles is in $HOME
# git clone git@github.com:BluSyn/dotfiles.git ~/dotfiles

# Install brew/pacman/apt pkgs depending on OS
# Supported OS: macOS (brew), Arch Linux (pacman), Debian and Ubuntu (apt)
SHARED_PKGS=("openssl" "wget" "curl" "unzip" "ripgrep" "fish" "starship" "tmux" "tmuxp" "bat" "htop" "rustup")
PACMAN_PKGS=("neovim")
BREW_PKGS=("nvim" "herdr" "opencode")

os_id=""
os_like=""
if [[ -r /etc/os-release ]]; then
  os_id=$(. /etc/os-release && printf '%s' "${ID-}")
  os_like=$(. /etc/os-release && printf '%s' "${ID_LIKE-}")
fi

# Debian/Ubuntu names differ, and a few tools landed in apt only on newer
# releases: neovim (not nvim), starship (Debian 13+ / Ubuntu 25.04+), rustup
# (Debian 13+ / Ubuntu 24.04+). bat's binary is batcat. xz-utils is required
# to unpack the Nerd Font below.
# herdr is a Homebrew formula and an Omarchy pacman package. Other Arch,
# Debian, and Ubuntu installs use the upstream installer.
# node:22-trixie has no sudo. The default user is root; the image's "node"
# user is not, and apt cannot run there.
have_root() {
  [[ "$(id -u)" -eq 0 ]]
}

find_sudo() {
  local candidate
  if command -v sudo &> /dev/null; then
    command -v sudo
    return 0
  fi
  for candidate in /usr/bin/sudo /bin/sudo /usr/local/bin/sudo; do
    if [[ -x $candidate ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

as_root() {
  if have_root; then
    "$@"
  else
    local bin
    bin="$(find_sudo)" || return 1
    "$bin" "$@"
  fi
}

install_apt_packages() {
  local pkg
  local pkgs
  local bin_dir
  pkgs=(openssl wget curl unzip xz-utils ripgrep fish tmux tmuxp bat htop neovim)

  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  if have_root || find_sudo &> /dev/null; then
    as_root apt-get update || return 1

    for pkg in rustup starship herdr; do
      if apt-cache show "$pkg" &> /dev/null; then
        pkgs+=("$pkg")
      fi
    done

    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || return 1

    bin_dir=/usr/local/bin
    as_root mkdir -p "$bin_dir"
  else
    echo "No root access and sudo is not installed. Skipping apt packages."
    bin_dir="${HOME}/.local/bin"
  fi

  # Debian/Ubuntu ship bat as batcat. fish/config.fish looks for `bat`.
  if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
    if [[ $bin_dir == /usr/local/bin ]]; then
      as_root ln -sfn "$(command -v batcat)" "${bin_dir}/bat"
    else
      ln -sfn "$(command -v batcat)" "${bin_dir}/bat"
    fi
  fi

  if ! command -v starship &> /dev/null; then
    curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh || return 1
    sh /tmp/starship-install.sh -y -b "$bin_dir" || return 1
    rm -f /tmp/starship-install.sh
  fi

  if ! command -v herdr &> /dev/null; then
    install_herdr_release || return 1
  fi

  if ! command -v rustup &> /dev/null; then
    # --no-modify-path: bashrc already sources ~/.cargo/env, and profile is a symlink into this repo.
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o /tmp/rustup-init.sh || return 1
    sh /tmp/rustup-init.sh -y --no-modify-path --default-toolchain stable || return 1
    rm -f /tmp/rustup-init.sh
  fi

  install_user_clis || return 1
}

# https://herdr.dev/docs/install/ — non-interactive, installs to ~/.local/bin.
install_herdr_release() {
  curl -fsSL https://herdr.dev/install.sh -o /tmp/herdr-install.sh || return 1
  sh /tmp/herdr-install.sh || return 1
  rm -f /tmp/herdr-install.sh
}

# Grok's installer rewrites bashrc and fish config. Those files are symlinks
# into this repo, and fish/config.fish already adds ~/.grok/bin.
install_grok_cli() {
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${HOME}/.grok/bin:${PATH}"
  if ! command -v grok &> /dev/null && [[ ! -x ${HOME}/.grok/bin/grok ]]; then
    curl -fsSL https://x.ai/cli/install.sh -o /tmp/grok-install.sh || return 1
    SHELL=/bin/sh bash /tmp/grok-install.sh || return 1
    rm -f /tmp/grok-install.sh
  fi
  if [[ -x ${HOME}/.grok/bin/grok ]]; then
    ln -sfn "${HOME}/.grok/bin/grok" "${HOME}/.local/bin/grok"
  fi
}

# OpenCode 2. --no-modify-path keeps it from appending to the linked shell rc.
# Homebrew formula and Arch package are preferred when present; this is the fallback.
install_opencode_cli() {
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${HOME}/.opencode/bin:${PATH}"
  if ! command -v opencode &> /dev/null && [[ ! -x ${HOME}/.opencode/bin/opencode ]]; then
    curl -fsSL https://opencode.ai/v2/install -o /tmp/opencode-install.sh || return 1
    bash /tmp/opencode-install.sh --no-modify-path || return 1
    rm -f /tmp/opencode-install.sh
  fi
  if [[ -x ${HOME}/.opencode/bin/opencode ]]; then
    ln -sfn "${HOME}/.opencode/bin/opencode" "${HOME}/.local/bin/opencode"
  fi
}

# https://cursor.com/docs/cli/installation — agent and cursor-agent in ~/.local/bin.
# Runs after Grok so Cursor keeps the `agent` command.
install_cursor_cli() {
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! command -v cursor-agent &> /dev/null && [[ ! -x ${HOME}/.local/bin/cursor-agent ]]; then
    curl -fsS https://cursor.com/install -o /tmp/cursor-install.sh || return 1
    bash /tmp/cursor-install.sh || return 1
    rm -f /tmp/cursor-install.sh
  fi
}

install_user_clis() {
  install_grok_cli || return 1
  install_opencode_cli || return 1
  install_cursor_cli || return 1
}

# herdr is in the Omarchy repo. Plain Arch does not ship it.
install_arch_packages() {
  local pkgs herdr_via_script
  pkgs=("${SHARED_PKGS[@]}" "${PACMAN_PKGS[@]}")
  herdr_via_script=0

  as_root pacman -Sy || return 1
  if pacman -Si herdr &> /dev/null; then
    pkgs+=(herdr)
  else
    herdr_via_script=1
  fi
  if pacman -Si opencode &> /dev/null; then
    pkgs+=(opencode)
  fi
  as_root pacman -S --needed "${pkgs[@]}" || return 1

  if [[ $herdr_via_script == 1 ]] && ! command -v herdr &> /dev/null; then
    install_herdr_release || return 1
  fi
  install_user_clis || return 1
}

echo -n "Installing default packages..."

if [[ $OSTYPE == 'darwin'* ]]; then
    if ! command -v brew &> /dev/null
    then
        echo "❌"
        echo "Homebrew not found. Go to https://brew.sh"
        exit 1
    fi

    brew install ${SHARED_PKGS[@]} ${BREW_PKGS[@]}
    install_user_clis
elif [[ $OSTYPE == 'linux'* ]] && command -v pacman &> /dev/null; then
    install_arch_packages
elif [[ $os_id == "debian" || $os_id == "ubuntu" || $os_like == *debian* || $os_like == *ubuntu* ]]; then
    if ! command -v apt-get &> /dev/null
    then
        echo "❌"
        echo "apt-get not found."
        exit 1
    fi

    install_apt_packages
else
    echo "❌"
    echo "Unsupported OS. Supported: macOS (Homebrew), Arch Linux (pacman), Debian and Ubuntu (apt)."
    exit 1
fi

if [ $? -ne 0 ]; then
  echo "❌"
  echo "Failed to install packages!"
  exit 1
fi

echo "✔︎"
echo -n "Git Submodules... "
git submodule update --init --recursive
echo "✔︎"

# ln command has different options on MacOS/Linux
link() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    ln -sfh $1 $2
  elif [[ $OSTYPE == 'linux'* ]]; then
    ln -sfT $1 $2
  fi
}

echo -n "Installing Configs..."
mkdir -p "$HOME/.config/herdr" "$HOME/.config/htop" "$HOME/.config/fish"
link $HOME/dotfiles/bash/bashrc $HOME/.bashrc
link $HOME/dotfiles/bash/profile $HOME/.profile
link $HOME/dotfiles/bash/bashTweaks $HOME/.bashTweaks

link $HOME/dotfiles/git $HOME/.config/git

# Omarchy ships tmux and nvim as existing dirs,needs custom check
if [[ -e $HOME/.config/tmux && ! -L $HOME/.config/tmux ]]; then
  mv "$HOME/.config/tmux" "$HOME/.config/tmux.orig"
fi
link $HOME/dotfiles/tmux $HOME/.config/tmux

if [[ -e $HOME/.config/nvim && ! -L $HOME/.config/nvim ]]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.orig"
fi
link $HOME/dotfiles/nvim $HOME/.config/nvim

link $HOME/dotfiles/tmuxp $HOME/.config/tmuxp
link $HOME/dotfiles/alacritty $HOME/.config/alacritty
link $HOME/dotfiles/wezterm $HOME/.config/wezterm
link $HOME/dotfiles/starship/starship.toml $HOME/.config/starship.toml
link $HOME/dotfiles/herdr/config.toml $HOME/.config/herdr/config.toml

# macos only configs
if [[ $OSTYPE == 'darwin'* ]]; then
  link $HOME/dotfiles/aerospace $HOME/.config/aerospace
fi

# Hyprland is Linux/Omarchy only. Share the Voyager/Mac-compatible binds;
# keep monitors.lua, looknfeel.lua, autostart.lua machine-local.
if [[ $OSTYPE == 'linux'* ]]; then
  mkdir -p $HOME/.config/hypr
  link $HOME/dotfiles/hypr/hyprland.lua $HOME/.config/hypr/hyprland.lua
  link $HOME/dotfiles/hypr/bindings.lua $HOME/.config/hypr/bindings.lua
  link $HOME/dotfiles/hypr/input.lua $HOME/.config/hypr/input.lua

  # Omarchy terminals: start fish instead of the login shell (bash).
  # Alacritty is linked as a whole dir earlier (shared Mac config), so only
  # the Omarchy-specific emulators are linked here.
  mkdir -p $HOME/.config/foot $HOME/.config/kitty $HOME/.config/ghostty
  link $HOME/dotfiles/omarchy-terminal/foot.ini $HOME/.config/foot/foot.ini
  link $HOME/dotfiles/omarchy-terminal/kitty.conf $HOME/.config/kitty/kitty.conf
  link $HOME/dotfiles/omarchy-terminal/ghostty.config $HOME/.config/ghostty/config

  # Asahi/brcmfmac: bounce Wi-Fi once after the desktop starts.
  mkdir -p $HOME/.config/omarchy/hooks/post-boot.d
  link $HOME/dotfiles/omarchy-hooks/asahi-wifi-bounce.sh $HOME/.config/omarchy/hooks/post-boot.d/asahi-wifi-bounce.sh
  chmod 755 $HOME/dotfiles/omarchy-hooks/asahi-wifi-bounce.sh

  # Apple Silicon SPI trackpad: user copy is git-tracked; libinput only
  # reads /etc/libinput/local-overrides.quirks (install-quirks.sh copies it).
  if [[ -e $HOME/.config/libinput && ! -L $HOME/.config/libinput ]]; then
    rm -rf "$HOME/.config/libinput"
  fi
  link $HOME/dotfiles/libinput $HOME/.config/libinput
  chmod 755 $HOME/dotfiles/libinput/install-quirks.sh
fi

# aider doesnt use standard config dir, apparently just to annoy everyone
# link $HOME/dotfiles/aider/conf.yml $HOME/.aider.conf.yml

# Frequently htop dir already exists, just link config
link $HOME/dotfiles/htop/htoprc $HOME/.config/htop/htoprc

# config only, don't mount DIR as fish adds untracked files here
link $HOME/dotfiles/fish/config.fish $HOME/.config/fish/config.fish

echo "✔︎"

# Install latest rust stable.
# The Ubuntu rustup.sh fallback installs into ~/.cargo/bin, which this shell
# does not pick up until a new login.
echo -n "Installing Rust... "
export PATH="${HOME}/.cargo/bin:${PATH}"
rustup default stable
echo "✔︎"

# Install Nerd Font
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/DejaVuSansMono
echo -n "Installing Nerd Font... "
wget -P /tmp/ https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/DejaVuSansMono.tar.xz

if [[ $OSTYPE == 'darwin'* ]]; then
    FONTDIR="${HOME}/Library/Fonts"
    tar -xvf /tmp/DejaVuSansMono.tar.xz -C ${FONTDIR} '*.ttf'
elif [[ $OSTYPE == 'linux'* ]]; then
    FONTDIR="${HOME}/.local/share/fonts/"
    mkdir -p ${FONTDIR}
    tar -xvf /tmp/DejaVuSansMono.tar.xz -C ${FONTDIR} --wildcards '*.ttf'
fi

rm /tmp/DejaVuSansMono.tar.xz

echo "✔︎"
echo "Installation Complete ✔︎"

