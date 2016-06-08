#!/usr/bin/env bash
#
# Set the bash prompt

define_colors() {
  [[ "$COLORTERM" == "gnome-*" && "$TERM" == "xterm" ]] \
    && infocmp "gnome-256color" &>/dev/null \
    && export TERM="gnome-256color"
  infocmp "xterm-256color" &>/dev/null \
    && export TERM="xterm-256color"

  local color_support="$(tput colors 2>/dev/null)"
  [[ -z "$color_support" ]] && return 0

  # defaults 8 colors
  [[ -z "$_BLACK" ]] && export _BLACK=$(tput setaf 0 || echo "\e[30m")
  [[ -z "$_RED" ]] && export _RED=$(tput setaf 1 || echo "\e[31m")
  [[ -z "$_GREEN" ]] && export _GREEN=$(tput setaf 2 || echo "\e[32m")
  [[ -z "$_YELLOW" ]] && export _YELLOW=$(tput setaf 3 || echo "\e[33m")
  [[ -z "$_BLUE" ]] && export _BLUE=$(tput setaf 4 || echo "\e[34m")
  [[ -z "$_MAGENTA" ]] && export _MAGENTA=$(tput setaf 5 || echo "\e[35m")
  [[ -z "$_CYAN" ]] && export _CYAN=$(tput setaf 6 || echo "\e[36m")
  [[ -z "$_WHITE" ]] && export _WHITE=$(tput setaf 7 || echo "\e[97m")

  # effects
  [[ -z "$_RESET" ]] && export _RESET=$(tput sgr0 || echo "\e[0m")
  [[ -z "$_BOLD" ]] && export _BOLD=$(tput bold || echo "\e[1m")
  [[ -z "$_START_UL" ]] && export _START_UL=$(tput smul || echo "\e[4m")
  [[ -z "$_END_UL" ]] && export _END_UL=$(tput rmul || echo "\e[24m")
  [[ -z "$_REV_VID" ]] && export _REV=$(tput rev || echo "\e[7m")
  [[ -z "$_START_BLINK" ]] && export _BLINK=$(tput blink || echo "\e[5m")
  [[ -z "$_INVIS" ]] && export _INVIS=$(tput invis || echo "\e[8m")
  [[ -z "$_START_STANDOUT" ]] && export _START_STANDOUT=$(tput smso || echo "\e[1m")
  [[ -z "$_END_STANDOUT" ]] && export _END_STANDOUT=$(tput rmso || echo "\e[21m")
}

_git_branch() {
  ! which git &>/dev/null && return 0
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return 0
  [[ "$branch" == "HEAD" ]] && local branch="detached*"
  echo "$_BOLD$_BLUE: $_BOLD$_YELLOW$branch$_RESET"
}

_git_dirty() {
  ! which git &>/dev/null && return 0
  [[ -n "$(git status --porcelain 2>/dev/null)" ]] \
    && echo "$_BOLD$_RED$_BLINK*$_RESET"
}

prompt_dev() {
  # PS1
  local ps1=""
  [[ -n "$CURRENT_ENVLIB" ]] \
    && local ps1+="\[$_BOLD$_YELLOW\][\$CURRENT_ENVLIB]\[$_RESET\] "
  local ps1+="\[$_BOLD$_CYAN\]\u \[$_BOLD$_BLUE\]@ \[$_BOLD$_MAGENTA\]\h\[$_RESET\] "
  local ps1+="\[$_BOLD$_BLUE\]: \[$_BOLD$_GREEN\]\w\[$_RESET\] "
  local ps1+="\$(_git_branch)\$(_git_dirty) "
  local ps1+="\[$_BOLD$_WHITE\]\t\n\$ \[$_RESET\]"
  export PS1="$ps1"

  # PS2
  export PS2="\[$_RED\]→\[$_RESET\] "

  # PS3 - unchanged
  # PS4 - unchanged
}

#######################################
# Set Prompt
# Globals:
#   None
# Arguments:
#   $1  prompt_name
# Returns:
#   None
#######################################
function set_prompt {
  local pattern_function="prompt_${1:-dev}"
  $pattern_function
}

define_colors
