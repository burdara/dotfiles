#!/bin/bash
###
#  Bash Profile
#
#  Uses custom functions defined in ~/.bashlib/
###
if [[ $PROFILE_LOADED ]]; then 
    #exit
    echo hi
fi
#exit

printf "Loading Bash Profile..."

### Include libs
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -d $scriptPath/.bashlib ]]; then 
    source $scriptPath/.bashlib/prompt.sh
else
    echo -e "\n\n\tError:  missing ~/.bashlib/ dir!!!\n\n";
fi


### Aliases
# ls
alias ll='ls -l'
alias l='ls -l'
# git
alias ga='git add'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gundo="git reset HEAD"


### Shell Settings
set -o vi                                # Set vi mode for bash shell
export CLICOLOR=1                        # Turn on colors
export LSCOLORS=gxfxcxdxbxegedabagacad   # Color files by type


### Prompt
# Pass prompt pattern key - see bashlibs/prompt.sh
# (smiley|redline|fancy)
set_prompt fancy  


### Path
PATH=/usr/local/bin:$PATH
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:/usr/local/git/bin
PATH=$PATH:$HOME/.rvm/bin 
export PATH=$PATH

### Environment Variables
export GRADLE_OPTS="-Xmx1g"
export JAVA_HOME=/Library/Java/Home
export CATALINA_HOME=/Library/Tomcat/Home
# For SSH
export SHCN="StrictHostKeyChecking=no"


### Misc
# Ruby Version Mmanager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 

# Keep this in to only load once
export PROFILE_LOADED="yes" 
printf "Done.\n"
