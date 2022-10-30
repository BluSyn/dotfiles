#!/bin/bash

# Assumes dotfiles is in ~

# Fonts:
# https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/BitstreamVeraSansMono
#
# pacman -Sy alacritty fish nvim helix htop inetutils
# brew install fish helix nvim htop

ln -si ~/dotfiles/bash/bashrc ~/.bashrc
ln -si ~/dotfiles/bash/profile ~/.profile
ln -si ~/dotfiles/bash/bashTweaks ~/.bashTweaks

ln -si ~/dotfiles/git ~/.config/git
ln -si ~/dotfiles/tmux ~/.config/tmux
ln -si ~/dotfiles/tmuxp ~/.config/tmuxp
ln -si ~/dotfiles/nvim ~/.config/nvim
ln -si ~/dotfiles/helix ~/.config/helix
ln -si ~/dotfiles/alacritty ~/.config/alacritty
ln -si ~/dotfiles/htop/htoprc ~/.config/htop/htoprc

ln -si ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
