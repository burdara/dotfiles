#!/usr/bin/env sh
#
# Git configuration and setup

# Setup local git configuration
_git_config="$HOME/.config/git/config.local"
 
for attr in user.name user.email; do
  if test -z "$(git config --file "$_git_config" "$attr")"; then
    printf "Enter Git %s: " "$attr" >&2
    read -r input \
    git config --file "$_git_config" "$attr" "$input"
  fi
done

v1="$(git config --file "$_git_config" diff.tool)"
v2="$(git config --file "$_git_config" merge.tool)"
if test -z "$v1" || test -z "$v2"; then
  git mergetool --tool-help
  printf "Enter Git diff.tool: [%s]" "$v1" >&2
  read -r input
  git config --file "$_git_config" diff.tool "${input:-$v1}"
  printf "Enter Git merge.tool: [%s]" "$v1" >&2
  read -r input
  git config --file "$_git_config" merge.tool "${input:-$v1}"
fi
