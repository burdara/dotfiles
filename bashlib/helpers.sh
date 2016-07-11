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

########################################
# Set command line proxy environment variables
# Globals:
#   Sets the following variables
#     - http_proxy
#     - https_proxy
#     - HTTP_PROXY
#     - HTTPS_PROXY
# Arguments:
#   $1  proxy_url (optional)
#   $2  proxy_username (optional)
#   $3  proxy_password (optional)
# Returns:
#   None
########################################
proxy() {
  local proxy_vars="http_proxy https_proxy HTTP_PROXY HTTPS_PROXY"
  [[ -z "$1" ]] && echo "\$1 [un]set arg missing." && return 1
  [[ -n "$2" ]] && local proxy_url="$2"
  [[ -n "$3" ]] && local username="$3"
  [[ -n "$4" ]] && local password="$4"
  case "$1" in
    set)
      [[ -z "$proxy_url" ]] && read -r -p "proxy url: " proxy_url
      while [[ -z "$proxy_url" ]]; do
        read -r -p "proxy url: " proxy_url
      done
      while [[ -z "$username" ]]; do
        read -r -p "proxy username: " username
      done
      while [[ -z "$password" ]]; do
        read -s -r -p "proxy password: " password
      done
      local safe_password=$(python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" $password)
      for v in $proxy_vars; do
        local cmd="export $v=http://$username:$safe_password@$proxy_url"
        $cmd
      done
    ;;
    unset)
      for v in $proxy_vars; do
        local cmd="unset $v"
        $cmd
      done
    ;;
  esac
  unset proxy_url
  unset username
  unset passworda
}
