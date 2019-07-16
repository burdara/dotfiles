#!/usr/bin/env bash
#
# Git configuration and setup

# Setup git aliases
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_setup_git_aliases() {
  alias ga='git add'
  alias gl='git pull'
  alias gp='git push'
  alias gd='git diff'
  alias gc='git commit'
  alias gca='git commit -a'
  alias gco='git checkout'
  alias gb='git branch'
  alias gs='git status'
  alias gundo="git reset HEAD --hard"
}

# Setup user specific gitconfig file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_setup_git_config() {
  local config="$HOME/.config/git/config.custom"

  local attr input 
  for attr in user.name user.email; do
    [[ -z "$(git config --file "$config" "$attr")" ]] \
      && read -r -p "Enter Git $attr: " input \
      && git config --file "$config" "$attr" "$input"
  done

  local v1 v2
  v1="$(git config --file "$config" diff.tool)"
  v2="$(git config --file "$config" merge.tool)"
  if [[ -z "$v1" || -z "$v2" ]]; then
    git mergetool --tool-help
    read -r -p "Enter Git diff.tool: [$v1] " input
    git config --file "$config" diff.tool "${input:-$v1}"
    read -r -p "Enter Git merge.tool: [$v1] " input
    git config --file "$config" merge.tool "${input:-$v1}"
  fi
}

if command -v git &>/dev/null; then
  _setup_git_aliases && unset _setup_git_aliases
  _setup_git_config && unset _setup_git_config
fi 