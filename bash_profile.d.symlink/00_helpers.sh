#!/usr/bin/env bash
#
#  Helper functions.

# Enable/Disable shell's extglob option
# Refer to https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html
# Globals:
#   None
# Arguments:
#   1: on/off/""
# Returns:
#   None
extglob() {
  local usage="usage: extglob [on|off]"
  case "$1" in
    on)  shopt -s extglob ;;
    off) shopt -u extglob ;;
    -h|--help) echo "$usage" && return 0 ;;
  esac
  shopt extglob
}

# Flush DNS. Currently darwin only.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
dnsflush() {
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
  ! command -v perl &>/dev/null && echo "perl binary not found" && return 1
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
# i.e http_proxy, https_proxy, HTTP_PROXY, HTTPS_PROXY
# Globals:
#   None
# Arguments:
#   1: set or unset (required)
#   @: options - see usage
# Returns:
#   None
set_web_proxy() {
  local usage action
  usage=$(cat <<EOF
usage: set_web_proxy [set|unset] [options]
arguments:
  set|unset|""            set, unset, or show variables
options:
  -x, --proxy-url <url>   Proxy URL
  -u, --username <name>   Proxy username
  -p, --password <name>   Proxy password. Recommend use of --password-stdin or prompt instead
  --password-stdin        Read password from stdin
  -h, --help
EOF
)

  local proxy_vars="http_proxy https_proxy HTTP_PROXY HTTPS_PROXY"
  while [[ -n "$1" ]]; do
    case "$1" in
      -x|--proxy-url) shift; proxy_url="$1" ;;
      -u|--username) shift; username="$1" ;;
      -p|--password) shift; password="$1" ;;
      --password-stdin) password="$(cat /dev/stdin)" ;;
      -h|--help) echo "$usage" && return 0 ;;
      *) action="$1";
    esac
    shift
  done

  local python_cmd
  case "$(python --version)" in
    *3.*) python_cmd='import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))' ;;
    *2.*) python_cmd='import sys, urllib as ul; print ul.quote_plus(sys.argv[1])' ;;
    *) echo "python not found" && return 1 ;;
  esac

  local cmd
  case "$action" in
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
    *)
      for v in $proxy_vars; do
        echo "$v=${!v}"
      done
    ;;
  esac
}

# Fetches certificate information from specified hostname
# Globals:
# Arguments:
#   1: hostname (required)
# Returns:
#   Certificate information
show-cert() {
  ! command -v openssl &>/dev/null && echo "openssl binary not found" && return 1
  local usage="usage; show-cert <hostname> [servername]"
  [[ -z "$1" ]] && echo "argument <hostname> missing or empty" && echo "$usage" && return 1
  echo \
    | openssl s_client -showcerts -servername "${2:-$1}" -connect "$1:443" 2>/dev/null \
    | openssl x509 -inform pem -noout -text
}
