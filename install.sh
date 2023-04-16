#!/usr/bin/env bash

# Assumes dotfiles is in $HOME
# git clone git@github.com:BluSyn/dotfiles.git

# Fonts:
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/BitstreamVeraSansMono

# Packages:
# pacman -Sy alacritty fish nvim helix htop inetutils
# brew install fish helix nvim htop

# ln command has different options on MacOS/Linux
link() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    ln -sfh $1 $2
  elif [[ $OSTYPE == 'linux'* ]]; then
    ln -sfT $1 $2
  fi
}

link $HOME/dotfiles/bash/bashrc $HOME/.bashrc
link $HOME/dotfiles/bash/profile $HOME/.profile
link $HOME/dotfiles/bash/bashTweaks $HOME/.bashTweaks

link $HOME/dotfiles/git $HOME/.config/git
link $HOME/dotfiles/tmux $HOME/.config/tmux
link $HOME/dotfiles/tmuxp $HOME/.config/tmuxp
link $HOME/dotfiles/nvim $HOME/.config/nvim
link $HOME/dotfiles/helix $HOME/.config/helix
link $HOME/dotfiles/alacritty $HOME/.config/alacritty

mkdir $HOME/.config/htop
link $HOME/dotfiles/htop/htoprc $HOME/.config/htop/htoprc

mkdir $HOME/.config/fish
link $HOME/dotfiles/fish/config.fish $HOME/.config/fish/config.fish
