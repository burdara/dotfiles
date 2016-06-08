#!/usr/bin/env bash

version_manager_paths=(
  "$HOME/.rvm/bin"
  "$HOME/.nvm/bin"
  "$HOME/.pyenv/bin"
)
add_paths ${version_manager_paths[@]}

# Ruby Version manager
rvm_source_file="$HOME/.rvm/scripts/rvm"
[[ -s "$rvm_source_file" ]] && source "$rvm_source_file"

# Node Version Manager
nvm_source_file="$HOME/.nvm/nvm.sh"
[[ -s "$nvm_source_file" ]] && source "$nvm_source_file"

# Python environment
which pyenv &>/dev/null && eval "$(pyenv init -)"
