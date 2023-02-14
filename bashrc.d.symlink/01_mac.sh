#!/usr/bin/env bash
#
# Mac (darwin) bash specific configurations

# Source Homebrew's bash completion links
# Globals: None
# Arguments: None
# Returns: None
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

if [[ "$(uname)" == "Darwin" ]]; then
  _source_brew_bash_complete && unset _source_brew_bash_complete
fi
