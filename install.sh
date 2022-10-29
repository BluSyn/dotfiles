#!/bin/bash

# Assumes .dotfiles is in ~

# BASH
ln -si ~/.dotfiles/bash/bashrc ~/.bashrc
ln -si ~/.dotfiles/bash/profile ~/.profile
ln -si ~/.dotfiles/bash/bashTweaks ~/.bashTweaks

# FISH
ln -si ~/.dotfiles/config.fish ~/.config/fish/config.fish

# GIT
ln -si ~/.dotfiles/git ~/.config/git

# TMUX
ln -si ~/.dotfiles/tmux ~/config/tmux

# NeoVIM
ln -si ~/.dotfiles/nvim ~/.config/nvim

# Helix
ln -si ~/.dotfiles/helix ~/.config/helix

# Allacritty
ln -si ~/.dotfiles/alacritty ~/.config/alacritty

# Other
ln -si ~/.dotfiles/htop/htoprc ~/.config/htop/htoprc
