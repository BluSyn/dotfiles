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
link $HOME/dotfiles/tmux $HOME/.config/tmux
link $HOME/dotfiles/tmuxp $HOME/.config/tmuxp
link $HOME/dotfiles/nvim $HOME/.config/nvim
link $HOME/dotfiles/helix $HOME/.config/helix
link $HOME/dotfiles/alacritty $HOME/.config/alacritty
link $HOME/dotfiles/starship/starship.toml $HOME/.config/starship.toml

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

# Build tmux plugin
echo -n "Building tmux plugin... "
cargo build --release --manifest-path=$HOME/dotfiles/tmux/plugins/tmux-thumbs/Cargo.toml
echo "✔︎"

# Install nvim plugins
echo -n "Installing nvim plugins... "
nvim +'PackerInstall' +qa
echo "✔︎"

# Install Nerd Font
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/BitstreamVeraSansMono
FONTDIR="${HOME}/Library/Fonts"

echo -n "Installing Nerd Font... "
wget -P /tmp/ https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/BitstreamVeraSansMono.zip

if [[ $OSTYPE == 'linux'* ]]; then
    FONTDIR="${HOME}/.local/share/fonts/"
    mkdir -p ${FONTDIR}
fi

unzip -n /tmp/BitstreamVeraSansMono.zip "*.ttf" -d ${FONTDIR}
rm /tmp/BitstreamVeraSansMono.zip

echo "✔︎"
echo "Installation Complete ✔︎"

