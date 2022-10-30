#!/usr/bin/env bash

# Assumes dotfiles is in ~

# Fonts:
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/BitstreamVeraSansMono
#
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

link ~/dotfiles/bash/bashrc ~/.bashrc
link ~/dotfiles/bash/profile ~/.profile
link ~/dotfiles/bash/bashTweaks ~/.bashTweaks

link ~/dotfiles/git ~/.config/git
link ~/dotfiles/tmux ~/.config/tmux
link ~/dotfiles/tmuxp ~/.config/tmuxp
link ~/dotfiles/nvim ~/.config/nvim
link ~/dotfiles/helix ~/.config/helix
link ~/dotfiles/alacritty ~/.config/alacritty
link ~/dotfiles/htop/htoprc ~/.config/htop/htoprc

mkdir ~/.config/fish
link ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
