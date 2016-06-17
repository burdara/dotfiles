#!/usr/bin/env bash

# Paths
git_paths=(
  "/usr/local/git/bin"
)
add_paths ${git_paths[@]}

# Aliases
alias ga='git add'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gundo="git reset HEAD"

#######################################
# Creates gitvim script
# spf13-vim components can cause issues with git commit messages
# Globals:
#   None
# Arguments:
#   $1  source_file_url
# Returns:
#   None
#######################################
create_bare_vim() {
  local home_bin_dir="$HOME/bin"
  [[ ! -d "$home_bin_dir" ]] && mkdir -p "$home_bin_dir"
  git_vim_file="$home_bin_dir/gitvim"
  [[ -x "$git_vim_file" ]] && return 0
  printf "vim -u 'NONE' \$@" > $git_vim_file
  chmod +x $git_vim_file
}

#######################################
# Download and source file
# Globals:
#   None
# Arguments:
#   $1  source_file_url
# Returns:
#   None
#######################################
download_bash_source_file() {
  [[ -z "$1" ]] && printf "missing url arg\n" && return 1
  local url="$1"
  local filename="$HOME/${url##*/}"
  [[ ! -e "$filename" ]] && curl -s -o "$filename" "$url"
  [[ -s "$filename" ]] && source "$filename"
}

#######################################
# Setup gitconfig file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
setup_git_config() {
  gitconfig_file="$HOME/.gitconfig"
  gitconfig_lock_file="$HOME/.gitconfig.lock"
  [[ -e "$gitconfig_lock_file" ]] && return 0

  git config --global core.editor gitvim

  local v="$(git config --global user.name)"
  read -r -p "Enter Git user.name: [$v] " user_input
  git config --global user.name "${user_input:-$v}"

  local v="$(git config --global user.email)"
  read -r -p "Enter Git user.email: [$v] " user_input
  git config --global user.email "${user_input:-$v}"

  git mergetool --tool-help && printf "Custom options:\n"
  if [[ "$(uname)" == "Darwin" ]]; then
    stree_diff_file="/Applications/SourceTree.app/Contents/Resources/opendiff-w.sh"
    [[ -x "$stree_diff_file" ]] && printf "\t\t SourceTree\n"
  fi

  local v="$(git config --global diff.tool)"
  read -r -p "Enter Git diff.tool: [$v] " user_input
  git config --global diff.tool "${user_input:-$v}"
  if [[ "${user_input:-$v}" == "SourceTree" ]]; then
    git config --global difftool.SourceTree.cmd \
      "$stree_diff_file \"$LOCAL\" \"$REMOTE\""
  fi

  local v="$(git config --global merge.tool)"
  read -r -p "Enter Git merge.tool: [$v] " user_input
  git config --global merge.tool "${user_input:-$v}"
  if [[ "${user_input:-$v}" == "SourceTree" ]]; then
    git config --global mergetool.SourceTree.cmd \
      "$stree_diff_file \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\""
    git config --global mergetool.SourceTree.trustExitCode = true
    git config --global mergetool.SourceTree.keepBackup = false
  fi

  touch "$gitconfig_lock_file"
}

create_bare_vim
setup_git_config
[[ ! -e "/usr/share/bash-completion/completions/git" ]] \
  && download_bash_source_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
download_bash_source_file "https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash"
