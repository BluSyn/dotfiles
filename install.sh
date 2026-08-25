#!/usr/bin/env bash
# NOTE: *SHOULD* be safe to run multiple times

# Assumes dotfiles is in $HOME
# git clone git@github.com:BluSyn/dotfiles.git ~/dotfiles

# Install brew/pacman pkgs depending on OS
# Supported OS: MacOS (brew) and Arch Linux (pacman)
SHARED_PKGS=("openssl" "wget" "curl" "unzip" "ripgrep" "fish" "starship" "tmux" "tmuxp" "helix" "bat" "htop" "rustup")
PACMAN_PKGS=("neovim")
BREW_PKGS=("nvim")

echo -n "Installing default packages..."

if [[ $OSTYPE == 'darwin'* ]]; then
    if ! command -v brew &> /dev/null
    then
        echo "❌"
        echo "Homebrew not found. Go to https://brew.sh"
        exit 1
    fi

    brew install ${SHARED_PKGS[@]} ${BREW_PKGS[@]}
elif [[ $OSTYPE == 'linux'* ]]; then
    if ! command -v pacman &> /dev/null
    then
        echo "❌"
        echo "Pacman not found. Only Arch Linux supported"
        exit 1
    fi

    sudo pacman -Sy --needed ${SHARED_PKGS[@]} ${PACMAN_PKGS[@]}
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
link $HOME/dotfiles/helix $HOME/.config/helix
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

# Install latest rust stable
echo -n "Installing Rust... "
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

