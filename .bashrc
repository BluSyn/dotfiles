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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [ -f ~/.bashTweaks ]; then
    . ~/.bashTweaks
fi

# More bash completion (osx)
if [ -d /usr/local/etc/bash_completion.d ]; then
    source /usr/local/etc/bash_completion.d/*.sh
fi

# Always include CWD's node_modules bin
export PATH="${PATH}:./node_modules/.bin"

# Search up/down
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/blu/google-cloud-sdk/path.bash.inc' ]; then source '/Users/blu/google-cloud-sdk/path.bash.inc'; fi

# # The next line enables shell command completion for gcloud.
if [ -f '/Users/blu/google-cloud-sdk/completion.bash.inc' ]; then source '/Users/blu/google-cloud-sdk/completion.bash.inc'; fi

# Android Studio BS
export ANDROID_HOME="/Users/blu/Library/Android/sdk"
