#!/usr/bin/env bash
#
#  Bash Profile

printf "Loading dot files...\n"
bashrc_file="$HOME/.bashrc"
bashlib_dir="$HOME/.bashlib"

# Source bashlib file (first level)
[[ -r "$bashrc_file" ]] && source "$bashrc_file"
if [[ -d "$HOME/.bashlib" ]]; then
  for f in $(find $HOME/.bashlib/ -type f -maxdepth 1 \( ! -iname ".*" \)); do
    source $f
  done
fi

# Shell Settings
set -o vi                                # Set vi mode for bash shell
export CLICOLOR=1                        # Turn on colors
export LSCOLORS=gxfxcxdxbxegedabagacad   # Color files by type

# Prompt - Pass prompt pattern key - see bashlibs/prompt.sh
set_prompt dev

# Custom user bash_profile
custom_bash_profile="$HOME/.bash_profile.$(whoami)"
[[ ! -e "$custom_bash_profile" ]] \
  && touch "$custom_bash_profile" \
  && printf "$custom_bash_profile created for user specific customizations.\n"
[[ -s "$custom_bash_profile" ]] && source "$custom_bash_profile"

printf "Done.\n"
