#!/bin/bash
###
#  Bash Profile
#
#  Uses custom functions defined in ~/.bashlib/
###
if [[ $PROFILE_LOADED ]]; then
    echo "Profile already loaded!"
fi

[[ -r ~/.bashrc ]] && . ~/.bashrc

printf "Loading Bash Profile..."

### Include libs
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -d $scriptPath/.bashlib ]]; then
    for i in $(ls $scriptPath/.bashlib/); do
        source $scriptPath/.bashlib/$i
    done
else
    echo -e "\n\n\tError:  missing ~/.bashlib/ dir!!!\n\n";
fi


### Shell Settings
set -o vi                                # Set vi mode for bash shell
export CLICOLOR=1                        # Turn on colors
export LSCOLORS=gxfxcxdxbxegedabagacad   # Color files by type


### Prompt
# Pass prompt pattern key - see bashlibs/prompt.sh
# (smiley|redline|fancy)
set_prompt fancy

### Misc
# Ruby Version Mmanager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Keep this in to only load once
export PROFILE_LOADED="yes"
printf "Done.\n"
