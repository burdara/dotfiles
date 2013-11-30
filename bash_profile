#!/usr/bin/env bash
###
#  Bash Profile
#
#  Uses custom functions defined in ~/.bashlib/
###
[[ $PROFILE_LOADED ]] && echo "Profile already loaded!"
printf "Loading Bash Profile..."

[[ -r $HOME/.bashrc ]] && source $HOME/.bashrc

if [[ -d $HOME/.bashlib ]]; then
    for f in $(find $HOME/.bashlib/ -type f -d 1); do
        source $f
    done
fi

### Shell Settings
set -o vi                                # Set vi mode for bash shell
export CLICOLOR=1                        # Turn on colors
export LSCOLORS=gxfxcxdxbxegedabagacad   # Color files by type

### Prompt
# Pass prompt pattern key - see bashlibs/prompt.sh
set_prompt sexy # (smiley|redline|fancy|sexy)

### Misc

export PROFILE_LOADED="yes"
printf "Done.\n"
