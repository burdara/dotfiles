#!/usr/bin/env bash

# Ruby Environment
which rbenv &>/dev/null && eval "$(rbenv init -)"

# Ruby Version manager
rvm_source_file="$HOME/.rvm/scripts/rvm"
[[ -s "$rvm_source_file" ]] && source "$rvm_source_file" && add_paths "$HOME/.rvm/bin"


# Node environment
which nodenv &>/dev/null && eval "$(nodenv init -)"

# Node Version Manager
nvm_source_file="$HOME/.nvm/nvm.sh"
[[ -s "$nvm_source_file" ]] && source "$nvm_source_file" && add_paths "$HOME/.nvm/bin"

# Python environment
which pyenv &>/dev/null && eval "$(pyenv init -)"
