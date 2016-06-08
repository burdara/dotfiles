#!/usr/bin/env bash

########################################
# Enable/Disable shell's extglob option
# Globals:
#   None
# Arguments:
#   $1  on/off/blank
# Returns:
#   None
########################################
extglob() {
  [[ $1 = 'on'  ]] && shopt -s extglob
  [[ $1 = 'off' ]] && shopt -u extglob
  shopt extglob
}

########################################
# Flush DNS
# TODO add support for other distos
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
dnsflush() {
  [[ "$(uname)" == "Darwin" ]] && sudo dscacheutil -flushcache
}
