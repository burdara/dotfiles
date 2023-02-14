#!/usr/bin/env bash
#
# Bash Helper functions.

# Enable/Disable bash extglob option
# Refer to https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
# Globals: None
# Arguments:
#   1: on/off/""
# Returns: None
extglob() {
  local usage="usage: extglob [on|off]"
  case "$1" in
    on)  shopt -s extglob ;;
    off) shopt -u extglob ;;
    -h|--help) echo "$usage" && return 0 ;;
  esac
  shopt extglob
}
