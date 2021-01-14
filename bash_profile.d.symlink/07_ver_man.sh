#!/usr/bin/env bash
#
# Configure verison managers.

[[ -d "$HOME/.local/bin" ]] && add_paths "$HOME/.local/bin"

# Ruby Environment
command -v rbenv &>/dev/null \
  && eval "$(rbenv init -)"

# Node environment
command -v nodenv &>/dev/null \
  && eval "$(nodenv init -)"

# Python environment
command -v pyenv &>/dev/null \
  && eval "$(pyenv init -)"
