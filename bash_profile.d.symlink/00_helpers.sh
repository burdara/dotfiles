#!/usr/bin/env bash
#
#  Helper functions.

# Enable/Disable shell's extglob option
# Globals:
#   None
# Arguments:
#   1: on/off/blank
# Returns:
#   None
extglob() {
  [[ $1 = 'on'  ]] && shopt -s extglob
  [[ $1 = 'off' ]] && shopt -u extglob
  shopt extglob
}

# Flush DNS
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
dnsflush() {
  #TODO: add support for other distos
  [[ "$(uname)" == "Darwin" ]] \
    && sudo dscacheutil -flushcache \
    && sudo killall -HUP mDNSResponder
}

# Disk Usage by Folder
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
duf() {
  local perl_cmds
  perl_cmds=$(cat <<EOF
(\$s, \$f)=split(m{\\t});
for (qw(K M G)) {
  if(\$s<1024) {
    printf("%.1f",\$s);
    print "\$_\\t\$f"; 
    last
  }
  \$s=\$s/1024
}
EOF
)
  du -sk ./* 2>/dev/null \
    | sort -n \
    | perl -ne "$perl_cmds"
}

# Set command line http(s) proxy environment variables
# I.e http_proxy, https_proxy, HTTP_PROXY, HTTPS_PROXY
# Globals:
# Arguments:
#   1: set or unset (required)
#   2: proxy url (optional)
#   3: proxy username (optional)
#   4: proxy password (optional)
# Returns:
#   None.
set_web_proxy() {
  local proxy_vars="http_proxy https_proxy HTTP_PROXY HTTPS_PROXY"
  [[ -z "$1" ]] && echo "\$1 [un]set arg missing." && return 1
  [[ -n "$2" ]] && local proxy_url="$2"
  [[ -n "$3" ]] && local username="$3"
  [[ -n "$4" ]] && local password="$4"
  local python_cmd
  python_cmd=$(cat <<EOF
import sys, urllib as ul;
print ul.quote_plus(sys.argv[1]);
EOF
)
  local cmd
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
      local safe_password
      safe_password=$(python -c "$python_cmd" "$password")
      for v in $proxy_vars; do
        cmd="export $v=http://$username:$safe_password@$proxy_url"
        $cmd
      done
    ;;
    unset)
      for v in $proxy_vars; do
        cmd="unset $v"
        $cmd
      done
    ;;
  esac
}
