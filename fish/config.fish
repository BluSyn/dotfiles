# PATH
set PATH $PATH /opt/homebrew/bin
set PATH $PATH ~/.cargo/bin
set PATH $PATH ~/.local/bin
set PATH $PATH ./node_modules/.bin

# GIT Shortcuts
abbr -a g   'git'
abbr -a gs  'git status'
abbr -a gc  'TZ=UTC0 git commit'
abbr -a ga  'git add'
abbr -a gd  'git diff'
abbr -a gps 'git push'
abbr -a gpl 'git pull'
abbr -a gf  'git fetch'
abbr -a gr  'git remote'
abbr -a grb 'git rebase'
abbr -a gl  'git log'
abbr -a gco 'git checkout'
abbr -a gb  'git branch'
abbr -a gm  'git merge'
abbr -a gt  'git tag'

# Docker
abbr -a d 'docker'
abbr -a dps 'docker ps'
abbr -a dl 'docker logs -f --tail=1000'
abbr -a dc 'docker compose'
abbr -a dcps 'docker compose ps'
abbr -a dockerclean 'docker rmi \$(docker images | grep "<none>" | awk "{print \$3}")'
abbr -a dockerrm 'docker rm \$(docker ps -aq)'

# pnpm
abbr -a p 'pnpm'

# eza > ls
if command -v eza > /dev/null
    abbr -a l 'eza'
    abbr -a ll 'eza -labgF --git --time-style long-iso'
    abbr -a lls 'eza -labgF --git --git-ignore --time-style long-iso --ignore-glob=".git" --tree -L 2'
    abbr -a lll 'eza -la'
else
    abbr -a l 'ls'
    abbr -a ll 'ls -l'
end

# bat > cat
if command -v bat > /dev/null
    abbr -a cat 'bat'
end

# Auto attach existing tmux window on SSH
function msh
    #mosh --no-init --predict=never -- "$argv" sh -c "tmux attach || tmux new"
    mosh --client=/Users/blu/src/git/mosh/src/frontend/mosh-client --server=/home/box/src/git/mosh/src/frontend/mosh-server --no-init --predict=never -- "$argv" sh -c "tmux attach || tmux new"
end

function ssh
    LC_CTYPE=en_US.UTF-8 TERM=xterm-256color /usr/bin/ssh -t "$argv" "tmux attach || tmux new"
end

function sshr
    /usr/bin/ssh "$argv"
end

# Enable !! to repeat last command (eg, sudo !! from bash)
function last_history_item
    echo $history[1]
end
abbr -a !! --position anywhere --function last_history_item

# Fish git prompt
# NOTE: This is only used if starship is not available, see below
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'

function fish_prompt
    set -l color_dir 'C0C0C0'
    set -l color_dir_bg 'normal'
    set -l color_git 'green'
    set -l color_git_bg 'normal'
    set -l color_user 'yellow'
    set -l color_user_bg 'normal'
    set -l color_host 'blue'
    set -l color_host_bg 'normal'
    set -l color_prompt 'CCCCCC'
    set -l color_prompt_bg 'normal'
    set -l color_time 'C0C0C0'
    set -l color_time_bg 'normal'

    # Line 1: <dir> [<git>] \n
    set_color $color_dir -b $color_dir_bg; echo -n (prompt_pwd)
    set_color $color_git -b $color_git_bg; printf '%s' (__fish_git_prompt)

    # \n
    echo ""

    # Line 2: [<time>] <user>@<host> $
    set_color $color_time -b $color_time_bg; echo -n (date "+%H:%M:%S")
    echo -n " "
    set_color $color_user -b $color_user_bg; echo -n (whoami)
    set_color $color_dir -b $color_dir_bg; echo -n "@"
    set_color $color_host -b $color_host_bg; echo -n (hostname -s)
    set_color $color_prompt -b $color_prompt_bg; echo -n " → "
    set_color $arrowcol -b normal
end

function fish_right_prompt
  # empty right prompt
end

# Starship prompt replaces above if available
if command -v starship > /dev/null
    starship init fish | source
end

# FZF
function fish_user_key_bindings
    if functions -q fzf_key_bindings
        fzf_key_bindings
    end
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/blu/google-cloud-sdk/path.fish.inc' ]; . '/Users/blu/google-cloud-sdk/path.fish.inc'; end
fish_add_path /usr/local/sbin

