#!/usr/bin/env bash
#
# Mac (darwin) specific configurations

# Source Homebrew's bash completion links
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_source_brew_bash_complete() {
  local brew_bash_completion_dir
  brew_bash_completion_dir="$(brew --prefix)/etc/bash_completion.d"
  [[ ! -d "$brew_bash_completion_dir" ]] && return 0
  local bc

  # shellcheck disable=2044
  for bc in $(find "$brew_bash_completion_dir" -maxdepth 1 -type f -o -type l); do
    # shellcheck source=/dev/null
    [[ -r "$bc" ]] && source "$bc"
  done

  # bash-completion@2
  local brew_bash_completion_2
  brew_bash_completion_2="$(brew --prefix)/etc/profile.d/bash_completion.sh"
  # shellcheck source=/dev/null
  [[ -r "$brew_bash_completion_2" ]] && source "$brew_bash_completion_2"
}

# Creates Mac related aliases
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_setup_darwin_aliases() {
  # md5sum
  alias md5="md5 -r"
  alias md5sum="md5 -r"

  # crontab
  alias crontab="VIM_CRONTAB=true crontab"
}

if [[ "$(uname)" == "Darwin" ]]; then
  _source_brew_bash_complete && unset _source_brew_bash_complete
  _setup_darwin_aliases && unset _setup_darwin_aliases
  
  # custom paths
  [[ -d "$(brew --prefix)/Cellar/gnu-getopt" ]] \
    && add_paths --prepend "$(dirname "$(find "$(brew --prefix)/Cellar/gnu-getopt" -path '*/bin/getopt')")"
fi
