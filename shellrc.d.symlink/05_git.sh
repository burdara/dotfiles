#!/usr/bin/env sh
#
# Git configuration and setup

# Setup local git configuration
_git_config="$HOME/.config/git/config.local"
 
for attr in user.name user.email; do
  [[ -z "$(git config --file "$_git_config" "$attr")" ]] \
    && read -r -p "Enter Git $attr: " input \
    && git config --file "$_git_config" "$attr" "$input"
done

local v1 v2
v1="$(git config --file "$_git_config" diff.tool)"
v2="$(git config --file "$_git_config" merge.tool)"
if test -z "$v1" || test -z "$v2"; then
  git mergetool --tool-help
  read -r -p "Enter Git diff.tool: [$v1] " input
  git config --file "$_git_config" diff.tool "${input:-$v1}"
  read -r -p "Enter Git merge.tool: [$v1] " input
  git config --file "$_git_config" merge.tool "${input:-$v1}"
fi
