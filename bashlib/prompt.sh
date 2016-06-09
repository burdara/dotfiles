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
  [[ -z "$_CLR_BLACK" ]] && export _CLR_BLACK=$(tput setaf 0 || echo "\e[30m")
  [[ -z "$_CLR_RED" ]] && export _CLR_RED=$(tput setaf 1 || echo "\e[31m")
  [[ -z "$_CLR_GREEN" ]] && export _CLR_GREEN=$(tput setaf 2 || echo "\e[32m")
  [[ -z "$_CLR_YELLOW" ]] && export _CLR_YELLOW=$(tput setaf 3 || echo "\e[33m")
  [[ -z "$_CLR_BLUE" ]] && export _CLR_BLUE=$(tput setaf 4 || echo "\e[34m")
  [[ -z "$_CLR_MAGENTA" ]] && export _CLR_MAGENTA=$(tput setaf 5 || echo "\e[35m")
  [[ -z "$_CLR_CYAN" ]] && export _CLR_CYAN=$(tput setaf 6 || echo "\e[36m")
  [[ -z "$_CLR_WHITE" ]] && export _CLR_WHITE=$(tput setaf 7 || echo "\e[97m")

  # effects
  [[ -z "$_RESET" ]] && export _RESET=$(tput sgr0 || echo "\e[0m")
  [[ -z "$_FMT_BOLD" ]] && export _FMT_BOLD=$(tput bold || echo "\e[1m")
  [[ -z "$_FMT_START_UL" ]] && export _FMT_START_UL=$(tput smul || echo "\e[4m")
  [[ -z "$_FMT_END_UL" ]] && export _FMT_END_UL=$(tput rmul || echo "\e[24m")
  [[ -z "$_FMT_REV_VID" ]] && export _FMT_REV=$(tput rev || echo "\e[7m")
  [[ -z "$_FMT_START_BLINK" ]] && export _FMT_BLINK=$(tput blink || echo "\e[5m")
  [[ -z "$_FMT_INVIS" ]] && export _FMT_INVIS=$(tput invis || echo "\e[8m")
  [[ -z "$_FMT_START_STANDOUT" ]] && export _FMT_START_STANDOUT=$(tput smso || echo "\e[7m")
  [[ -z "$_FMT_END_STANDOUT" ]] && export _FMT_END_STANDOUT=$(tput rmso || echo "\e[27m")
}

_current_envlib() {
  [[ -n "$CURRENT_ENVLIB" ]] \
    && echo "$_FMT_BOLD$_CLR_YELLOW[$CURRENT_ENVLIB]$_RESET "
}

_git_branch() {
  ! which git &>/dev/null && return 0
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return 0
  [[ "$branch" == "HEAD" ]] && local branch="detached*"
  echo "$_FMT_BOLD$_CLR_BLUE: $_FMT_BOLD$_CLR_YELLOW$branch$_RESET"
}

_git_dirty() {
  ! which git &>/dev/null && return 0
  [[ -n "$(git status --porcelain 2>/dev/null)" ]] \
    && echo "$_FMT_BOLD$_CLR_RED$_FMT_BLINK*$_RESET"
}

_terminal_clock_start() {
  while sleep 1; do
    tput sc
    tput cup 0 $(($(tput cols)-30))
    date +"%A, %m/%d/%Y %H:%M:%S"
    tput rc;
  done
}

_terminal_clock_stop() {
  [[ -n "$TERMINAL_CLOCK_PID" ]] \
    && kill "$TERMINAL_CLOCK_PID" \
    && unset TERMINAL_CLOCK_PID
}

prompt_dev() {
  # FOREGROUND
  ## PS1
  local ps1="\$(_current_envlib)"
  local ps1+="\[$_FMT_BOLD$_CLR_CYAN\]\u \[$_FMT_BOLD$_CLR_BLUE\]@ \[$_FMT_BOLD$_CLR_MAGENTA\]\h\[$_RESET\] "
  local ps1+="\[$_FMT_BOLD$_CLR_BLUE\]: \[$_FMT_BOLD$_CLR_GREEN\]\w\[$_RESET\] "
  local ps1+="\$(_git_branch)\$(_git_dirty) "
  local ps1+="\[$_FMT_BOLD$_CLR_WHITE\]\t\n\$ \[$_RESET\]"
  export PS1="$ps1"
  ## PS2
  export PS2="\[$_RED\]→\[$_RESET\] "
  ## PS3 - unchanged
  ## PS4 - unchanged

  # _terminal_clock_stop
  # _terminal_clock_start &
  # export TERMINAL_CLOCK_PID="$!"
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
