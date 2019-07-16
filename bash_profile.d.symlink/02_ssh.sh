#!/usr/bin/env bash
#
# SSH helper functions

# Set aws environemnt variables
# Globals:
#   SSH_CMD:  SSH command (default: ssh)
#   CSSH_CMD: Cluster SSH command (default: csshx)
# Arguments:
#   [options]:  See usage below
# Returns:
#   None
sshw() {
  local user="robbie"
  local options="-o StrictHostKeyChecking=no"
  local ssh_cmd="${SSH_CMD:-ssh}"
  local hc=0
  local cmd hosts full_cmd show_cmd c_hosts c_options
  while [[ -n "$1" ]]; do
    case "$1" in
      -i) shift; options+="-i $1 " ;;
      -t) shift; options+="-N -f -L $1:localhost:$1 " ;;
      -u) shift; user="$1" ;;
      -h) shift; 
        [[ -n "$hosts" ]] && hosts+=" "
        hosts+="$1"
        ((hc++)) 
        ;;
      -c) show_cmd="true" ;;
      --help) cat <<EOF
usage: sshw [options]
options:
  -i <identity_file>  SSH identity file
  -t <tunnel_port>    Create SSH tunnel using specified port
  -u <user>           SSH username (default: $user)
  -h <host_or_ip>     SSH host/ip
  -c                  Outputs SSH command
  --help              Prints usage
  -- <cmd>            Execute command via SSH
  [ssh options]       Pass any other SSH options
EOF
        return 0
        ;;
      --) shift; cmd="-T \"$*\"" ;;
      *)
        [[ -n "$options" ]] && options+=" "
        options+="$1" 
        ;;
    esac
    shift
  done
  full_cmd="$ssh_cmd $options $user@$hosts $cmd"

  # multiple hosts provided, then use cluster ssh
  if [[ "$hc" -gt 1 ]]; then
    ssh_cmd="${CSSH_CMD:-csshx}"
    for h in $hosts; do
      [[ -n "$c_hosts" ]] && c_hosts+=" "
      c_hosts+="$user@$h"
    done
    case "$ssh_cmd" in
      i2cssh) c_options="--iterm2 $(sed 's/-\(.\) /-X\1=/g' <<<"$options")" ;;
      csshx) c_options="--ssh_args \"$options\"" ;;
    esac
    full_cmd="$ssh_cmd $c_options $c_hosts"
  fi
  [[ "$show_cmd" == "true" ]] && echo "$full_cmd"
  eval "$full_cmd"
}
