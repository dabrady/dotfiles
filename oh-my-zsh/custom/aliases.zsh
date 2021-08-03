## User aliases

# Specific programs
alias emacs='/Applications/MacPorts/EmacsMac.app/Contents/MacOS/Emacs'
alias emacsclient='/Applications/MacPorts/EmacsMac.app/Contents/MacOS/bin/emacsclient'

# Better zsh help
unalias run-help 2>/dev/null
autoload run-help
HELPDIR=/usr/local/share/zsh/help
alias help=run-help

# Turn on grep colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias forest='\tree --dirsfirst -C | less -r' # Page and order full tree
alias tree='tree --dirsfirst -phFDCL 1' # Customize and restrict tree to level 1
alias ls='clear; tree'
alias lsl='ls -L'
alias ls2='lsl 2'
alias ls3='lsl 3'
alias ls4='lsl 4'
alias lsa='ls -a' # Show dotfiles
alias lsd='ls -d' # Show directories only
alias lsf='ls | grep -v /$' # Show files only
alias perms="gstat -c %a" # Show file permissions
alias edit='eval $EDITOR'

alias path='echo $PATH | tr ":" "\n"'

alias interrupt='kill -2'

# Adding a trailing space to an alias causes the next word to be checked for alias-ness.
# This allows us to use the 'watch' command with an alias. Unfortunately, passing any flags will break this :P
alias watch='watch '

alias git=hub
alias make-pr='git pull-request --browse --assign $GITHUB_USER'
alias gnp='git --no-pager'
alias wat='git status'
alias huh='git diff'
alias whooops='git commit -a --amend'
alias whoops='whooops --no-edit'
alias gunstage='git unstage'
alias branches='git branch --'
alias openchanged='wat -s | awk '\''{ print $2 }'\'' | xargs $EDITOR'
alias opentouched='git --no-pager diff --name-only master | xargs $EDITOR'

alias zconf='edit $ZSH_CUSTOM/conf.zsh'
alias zals='edit $ZSH_CUSTOM/aliases.zsh'
alias zfun='edit $ZSH_CUSTOM/functions.zsh'
alias zvars='edit $ZSH_CUSTOM/vars.zsh'
alias rz='source ~/.zshrc'
alias rzconf='source $ZSH_CUSTOM/conf.zsh'
alias rzals='source $ZSH_CUSTOM/aliases.zsh'
alias rzvars='source $ZSH_CUSTOM/vars.zsh'

## Ruby things
#alias rbe=rbenv
#alias b='bundle'
#alias bi='b install'
#alias be='b exec'
#alias rspec='RAILS_ENV=test be rspec -c --format documentation'
#alias brake='be rake'
#alias brails='be rails'
#alias rc='brails c'
#alias bry='be pry -r ./config/environment'

# Creates a symblink in my project workspace to Go's special Go place.
#alias makegohappy='project=`basename $(dirname "$PWD")`/`basename "$PWD"`; ln -sv "$PWD" "$GITHUBS/$project"; unset $project'

#alias cd=cd_and_cj

alias dots='cd $GITHUBS/dotfiles'
