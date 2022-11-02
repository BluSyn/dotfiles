# PATH
set PATH $PATH /opt/homebrew/bin
set PATH $PATH ~/.cargo/bin
set PATH $PATH ~/.local/bin
set PATH $PATH ~/.local/share/solana/install/active_release/bin
if not contains ./node_modules/.bin $PATH
  set PATH ./node_modules/.bin $PATH
end

# GIT Shortcuts
abbr -a g 'git'
abbr -a gs 'git status'
abbr -a gc 'TZ=UTC0 git commit'
abbr -a ga 'git add'
abbr -a gd 'git diff'
abbr -a gps 'git push'
abbr -a gpl 'git pull'
abbr -a gr 'git remote'
abbr -a grb 'git rebase'
abbr -a gl 'git log'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a gm 'git merge'
abbr -a gt 'git tag'

# Docker
abbr -a d 'docker'
abbr -a dps 'docker ps'
abbr -a dl 'docker logs -f --tail=1000'
abbr -a dc 'docker-compose'
abbr -a dockerclean 'docker rmi \$(docker images | grep "<none>" | awk "{print \$3}")'
abbr -a dockerrm 'docker rm \$(docker ps -aq)'


# exa > ls
if command -v exa > /dev/null
	abbr -a l 'exa'
	abbr -a ll 'exa -labgF --git --time-style long-iso'
    abbr -a lls 'exa -labgF --git --git-ignore --time-style long-iso --ignore-glob=".git" --tree -L 2'
	abbr -a lll 'exa -la'
else
	abbr -a l 'ls'
	abbr -a ll 'ls -l'
end

# Auto attach existing tmux window on SSH
function msh
    mosh --no-init --predict=never -- "$argv" sh -c "tmux attach || tmux new"
end

function ssh
    LC_CTYPE=en_US.UTF-8 TERM=xterm-256color /usr/bin/ssh -t "$argv" "tmux attach || tmux new"
end

function sshr
    /usr/bin/ssh "$argv"
end

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'

function fish_prompt
    # Line 1: <dir> [<git>] \n
	set_color C0C0C0; echo -n (prompt_pwd)
    set_color green; printf '%s ' (__fish_git_prompt)
    echo ""

    # Line 2: [<time>][<user>@<host>] $
    set_color normal; echo -n "["
    set_color C0C0C0; echo -n (date "+%H:%M:%S")
    set_color normal; echo -n "]["
    set_color yellow; echo -n (whoami)
    set_color C0C0C0; echo -n "@"
    set_color blue; echo -n (hostname -s)
    set_color normal; echo -n "] \$ "
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
