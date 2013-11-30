#!/usr/bin/env bash

### Path
PATH=$PATH:/usr/local/git/bin

### Aliases
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

### bare vim
[[ -d $HOME/bin ]] && mkdir -p $HOME/bin
git_vim=$HOME/bin/gitvim
echo "vim -u 'NONE' \$@" > $git_vim
chmod +x $git_vim

### Bash Completion
find_source_bash_competion() {
    [[ -z $1 ]] && return 1
    cmd_script=$(which $1)
    [[ -z $cmd_script ]] && return 1
    cmd_script_dir=$(dirname $cmd_script)
    if [[ -L $cmd_script ]]; then 
        cmd_script=$(readlink $cmd_script)
        tmp_script_dir=$(dirname $cmd_script)
        c=$(echo $tmp_script_dir | cut -c1)
        [[ $c = "." || $fc != "/" ]] && cmd_script_dir=$cmd_script_dir/$tmp_script_dir
    fi
    cmd_bc_dir=$cmd_script_dir/../etc/bash_completion.d
    if [[ -d $cmd_bc_dir ]]; then
        for bc in $(find $cmd_bc_dir -type f); do source $bc; done
    fi
}
find_source_bash_competion git
find_source_bash_competion git-flow

### Functions

# Remove Submodule
#
# Usage: `git_remove_submodule path/to/submodule`
#
# Does the inverse of `git submodule add`:
#  1) `deinit` the submodule
#  2) Remove the submodule from the index and working directory
#  3) Clean up the .gitmodules file (won't be needed with 1.8.5!)
# Based on example by Adam Sharp, Aug 21, 2013
git_remove_submodule() {
    submodule_name=$(echo "$1" | sed 's/\/$//'); shift
    if git submodule status "$submodule_name" >/dev/null 2>&1; then
        git submodule deinit -f "$submodule_name"
        git rm -rf "$submodule_name"
        git config -f .gitmodules --remove-section "submodule.$submodule_name"
        if [ -z "$(cat .gitmodules)" ]; then
            git rm -f .gitmodules
        else
            git add .gitmodules
        fi
    else
        echo "Submodule '$submodule_name' not found"
        exit 1
   fi
}

