#!/usr/bin/env bash

########################################
# Source Homebrew's bash completion file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
source_brew_bash_complete() {
  brew_bash_complete="$(brew --prefix)/etc/bash_completion"
  [[ -f "$brew_bash_complete" ]] && source "$brew_bash_complete"
}

########################################
# Creates Mac related aliases
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
setup_mac_aliases() {
  # md5sum
  alias md5="md5 -r"
  alias md5sum="md5 -r"

  # crontab
  alias crontab="VIM_CRONTAB=true crontab"
}

if [[ "$(uname)" == "Darwin" ]]; then
  source_brew_bash_complete
  setup_mac_aliases
fi
