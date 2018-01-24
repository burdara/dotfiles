#!/usr/bin/env bash
#
# vault bashlib

_vault_get_secrets_from_json() {
  local path="$1"
  local json=$(vault read -format=json "$path" 2>/dev/null | jq -r ".data")
  [[ -z "$json" ]] && return
  local keys=$(echo "$json" | jq -r 'keys[]' | tr '\n' ' ')
  echo "$path [ $keys]"
}

_vault_get_secrets_from_path() {
  local path="$1"
  local paths=$(vault list "$path" 2>/dev/null)
  [[ -z "$paths" ]] && return
  for p in $paths; do
    [[ "$p" == "Keys" ]] && continue
    [[ "$p" =~ .*/ ]] && _vault_get_secrets_from_path "${path}${p}"
    _vault_get_secrets_from_json "${path}${p}"
  done
}

#######################################
# Iterates through vault and outputs list of secrets that you have access to.
# Globals:
#   None
# Arguments:
#   $@ list of mounts (optional)
# Returns:
#   None
#######################################
vault_list() {
  local mounts="$@"
  [[ -z "$mounts" ]] && local mounts=$(vault mounts | awk '{ print $1 }')
  for m in $mounts; do
    [[ "$m" == "Path" || "$m" == "sys/" ]] && continue
    [[ ! "$m" =~ .*/ ]] && m+="/"
    _vault_get_secrets_from_path "$m"
  done
}
