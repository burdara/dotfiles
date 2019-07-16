#!/usr/bin/env bash
#
# Configure verison managers.

# Ruby Environment
command -v rbenv &>/dev/null \
  && eval "$(rbenv init -)"

# Node environment
command -v nodenv &>/dev/null \
  && eval "$(nodenv init -)"

# Python environment
command -v pyenv &>/dev/null \
  && eval "$(pyenv init -)"
