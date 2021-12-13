# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Change dirs without "cd"
shopt -s autocd

# Default aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Standard bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# More bash completion (brew on osx)
if [ -f /usr/local/etc/bash_completion ]; then
	. /usr/local/etc/bash_completion
fi

# Always include CWD's node_modules bin
export PATH="${PATH}:/usr/local/sbin:${HOME}/.cargo/bin"

# Search up/down
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Custom aliases, etc.
if [ -f $HOME/.dotfiles/.bashTweaks ]; then
    . $HOME/.dotfiles/.bashTweaks
fi

# TODO: REMOVE WHEN DOCKER DEVS STOP BEING DICKWADS
export COMPOSE_API_VERSION="1.40"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"
