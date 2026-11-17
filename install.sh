#!/usr/bin/env bash
# NOTE: *SHOULD* be safe to run multiple times

# Assumes dotfiles is in $HOME
# git clone git@github.com:BluSyn/dotfiles.git ~/dotfiles

# Install brew/pacman/apt pkgs depending on OS
# Supported OS: macOS (brew), Arch Linux (pacman), Ubuntu (apt)
SHARED_PKGS=("openssl" "wget" "curl" "unzip" "ripgrep" "fish" "starship" "tmux" "tmuxp" "bat" "htop" "rustup")
PACMAN_PKGS=("neovim")
BREW_PKGS=("nvim" "herdr")

os_id=""
os_like=""
if [[ -r /etc/os-release ]]; then
  os_id=$(. /etc/os-release && printf '%s' "${ID-}")
  os_like=$(. /etc/os-release && printf '%s' "${ID_LIKE-}")
fi

# Ubuntu names differ, and a few tools landed in apt only on newer releases:
# neovim (not nvim), starship (25.04+), rustup (24.04+).
# bat's binary is batcat. xz-utils is required to unpack the Nerd Font below.
# herdr is a Homebrew formula and an Omarchy pacman package. Other Arch and
# Ubuntu installs use the upstream installer.
install_ubuntu_packages() {
  local pkg
  local pkgs
  pkgs=(openssl wget curl unzip xz-utils ripgrep fish tmux tmuxp bat htop neovim)

  sudo apt-get update || return 1

  for pkg in rustup starship herdr; do
    if apt-cache show "$pkg" &> /dev/null; then
      pkgs+=("$pkg")
    fi
  done

  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}" || return 1

  sudo mkdir -p /usr/local/bin

  # Debian/Ubuntu ship bat as batcat. fish/config.fish looks for `bat`.
  if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
    sudo ln -sfn "$(command -v batcat)" /usr/local/bin/bat
  fi

  if ! command -v starship &> /dev/null; then
    curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh || return 1
    sh /tmp/starship-install.sh -y -b /usr/local/bin || return 1
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
}

# https://herdr.dev/docs/install/ — non-interactive, installs to ~/.local/bin.
install_herdr_release() {
  curl -fsSL https://herdr.dev/install.sh -o /tmp/herdr-install.sh || return 1
  sh /tmp/herdr-install.sh || return 1
  rm -f /tmp/herdr-install.sh
}

# herdr is in the Omarchy repo. Plain Arch does not ship it.
install_arch_packages() {
  local pkgs herdr_via_script
  pkgs=("${SHARED_PKGS[@]}" "${PACMAN_PKGS[@]}")
  herdr_via_script=0

  sudo pacman -Sy || return 1
  if pacman -Si herdr &> /dev/null; then
    pkgs+=(herdr)
  else
    herdr_via_script=1
  fi
  sudo pacman -S --needed "${pkgs[@]}" || return 1

  if [[ $herdr_via_script == 1 ]] && ! command -v herdr &> /dev/null; then
    install_herdr_release || return 1
  fi
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
elif [[ $OSTYPE == 'linux'* ]] && command -v pacman &> /dev/null; then
    install_arch_packages
elif [[ $os_id == "ubuntu" || $os_like == *ubuntu* ]]; then
    if ! command -v apt-get &> /dev/null
    then
        echo "❌"
        echo "apt-get not found."
        exit 1
    fi

    install_ubuntu_packages
else
    echo "❌"
    echo "Unsupported OS. Supported: macOS (Homebrew), Arch Linux (pacman), Ubuntu (apt)."
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
mkdir $HOME/.config/htop
link $HOME/dotfiles/htop/htoprc $HOME/.config/htop/htoprc

# config only, don't mount DIR as fish adds untracked files here
mkdir $HOME/.config/fish
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

