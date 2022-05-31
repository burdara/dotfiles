#!/usr/bin/env bash
#
# Configure verison managers.

test -d "$HOME/.local/bin" && add_paths "$HOME/.local/bin"

# Ruby Environment
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# Node environment
command -v nodenv >/dev/null 2>&1 && eval "$(nodenv init -)"

# Python environment
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init --path)"