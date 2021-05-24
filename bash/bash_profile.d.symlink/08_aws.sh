#!/usr/bin/env bash
#
# AWS CLI configurations.
export AWS_SDK_LOAD_CONFIG=1

# Disables aws_ps1 output
# Globals: None
# Arguments: None
# Returns:
#   Sets environment variable AWS_PS1
aws_ps1_off() {
  export AWS_PS1="off"
}

# Enables aws_ps1 output
# Globals: None
# Arguments: None
# Returns:
#   Sets environment variable AWS_PS1
aws_ps1_on() {
  export AWS_PS1="on"
}

# Set aws environemnt variables
# Globals:
#   AWS_ACCESS_KEY_ID
#   AWS_DEFAULT_PROFILE
#   AWS_DEFAULT_REGION
#   AWS_PROFILE
#   AWS_ROLE_ARN
#   AWS_SRC_PROFILE   
#   AWS_SECRET_ACCESS_KEY
#   AWS_SESSION_TOKEN
#   AWS_SESSION_TOKEN_EXPIRE
# Arguments:
#   See usage
# Returns: None
aws-env() {
  local usage
  usage=$(cat <<EOF
usage: aws-env [options]
options:
  -e, --exports            Displays AWS environment commands for cut & paste.
  -p, --profile <profile>  Sets AWS profile.
  -r, --region <region>    Sets AWS region.
  +v, +vars                Set extra AWS environment variables.
  -v, -vars                Cleanup extra AWS environment variables.
  -h, --help               Prints usage.
EOF
)
  if [[ "$#" -eq 0 ]]; then
    env | grep "AWS_" | sed -e "s/\(AWS_SECRET_ACCESS_KEY=\).*/\1********/" \
      -e "s/\(AWS_SESSION_TOKEN=\).*/\1********/"
    return 0
  fi
  local rc
  ! command -v aws &>/dev/null 2>&1 \
    && printf "aws cli binary not found" && rc=1
  [[ ! -e "$HOME/.aws/credentials" || ! -e "$HOME/.aws/config" ]] \
    && printf "aws profiles not configured; please run 'aws configure --profile PROFILE_NAME'" \
    && rc=1
  [[ "$rc" -eq 1 ]] && return 1

  local profile="${AWS_PROFILE:-default}"
  local add_vars print_exports region
  while [[ -n "$1" ]]; do
    case "$1" in
      -e|--exports)  print_exports=1 ;;
      -p|--profile)  shift; profile="$1" ;;
      -r|--region)   shift; region="$1" ;;
      +v|+vars)      add_vars="plus" ;;
      -v|-vars)      add_vars="minus" ;;
      -h|--help)     echo "$usage" && return 0 ;;
    esac
    shift
  done

  local _tmp
  [[ "$profile" != "$AWS_PROFILE" ]] \
    && export AWS_PROFILE="$profile"

  _tmp="$(aws configure get "$profile.region")"
  if [[ -n "$region" && "$_tmp" != "$region" ]]; then
    export AWS_DEFAULT_REGION="$region"
  elif [[ -n "$_tmp" && -z "$AWS_DEFAULT_REGION" ]]; then
    export AWS_DEFAULT_REGION="$_tmp"
  else
    export AWS_DEFAULT_REGION="us-west-2"
  fi

  # Cleanup empty variables
  for v in \
    AWS_DEFAULT_PROFILE \
    AWS_ROLE_ARN \
    AWS_SRC_PROFILE \
    AWS_DEFAULT_REGION \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_SESSION_TOKEN \
    AWS_SESSION_TOKEN_EXPIRE
  do
    [[ -z "${!v}" ]] && unset "$v"
  done
  
  if [[ -n "$add_vars" && "$add_vars" == "plus" ]]; then
    # Save profile and unset
    export _AWS_PROFILE=$AWS_PROFILE
    unset AWS_PROFILE

    # role arn
    _tmp="$(aws configure get "$profile.role_arn")"
    [[ -n "$_tmp" && -z $AWS_ROLE_ARN ]] \
      && export AWS_ROLE_ARN="$_tmp"
    
    # src profile
    _tmp="$(aws configure get "$profile.source_profile")"
    [[ -n "$_tmp" && -z $AWS_SRC_PROFILE ]] \
      && export AWS_SRC_PROFILE="$_tmp"
    [[ -n "$AWS_SRC_PROFILE" ]] && local profile="$AWS_SRC_PROFILE"
    
    # standards
    _tmp="$(aws configure get "$profile.aws_access_key_id")"
    [[ -n "$_tmp" && -z $AWS_ACCESS_KEY_ID ]] \
      && export AWS_ACCESS_KEY_ID="$_tmp"
    
    _tmp="$(aws configure get "$profile.aws_secret_access_key")"
    [[ -n "$_tmp" && -z $AWS_SECRET_ACCESS_KEY ]] \
      && export AWS_SECRET_ACCESS_KEY="$_tmp"
    
    _tmp="$(aws configure get "$profile.aws_session_token")"
    [[ -n "$_tmp" && -z $AWS_SESSION_TOKEN ]] \
      && export AWS_SESSION_TOKEN="$_tmp"

    # custom
    _tmp="$(aws configure get "$profile.aws_session_token_expire")"
    [[ -n "$_tmp" && -z $AWS_SESSION_TOKEN_EXPIRE ]] \
      && export AWS_SESSION_TOKEN_EXPIRE="$_tmp"

  elif [[ -n "$add_vars" && "$add_vars" == "minus" ]]; then
    for e in $(env | grep -e "^AWS_" | awk -F= '{print $1}' | xargs); do
      case "$e" in
        AWS_DEFAULT_PROFILE|AWS_DEFAULT_REGION|AWS_SDK_LOAD_CONFIG) : ;;
        *) unset "$e" ;;
      esac
    done
    [[ -n "$_AWS_PROFILE" ]] \
      && export AWS_PROFILE="$_AWS_PROFILE" \
      && unset _AWS_PROFILE
  fi

  aws-ps1 --clear

  if [[ "$print_exports" -eq 1 ]]; then
    printf "set +o history\\n"
    env | grep "AWS_" | sed "s/^/export /g"
    printf "set -o history\\n"
  fi
}

# Set aws environemnt variables
# Globals: None
# Arguments:
#   See usage
# Returns: None
aws_ssh_cssh_helper() {
  local ipa ips args ip_data plookup ilookup ask region user_input tmp_ips
  while [[ -n "$1" ]]; do
    case "$1" in
      -lp|--lookup-public )     shift; plookup+="$1 " ;;
      -li|-l|--lookup-internal) shift; ilookup+="$1 " ;;
      -I|--interactive)         ask="--include-names" ;;
      -r|--region)              shift; region="$1" ;;
      -h|--help)                cat <<EOF
usage: aws_ssh_cssh_helper [options]
options:
  -lp, --lookup-public         Lookup public IPs.
  -l, -li, --lookup-internal   Lookup internal IPs.
  -I, --interactive            Interactive mode.
  -h, --help                   Prints usage.
  -r, --region <region>        Sets AWS region.
  [ssh_options]                Additional SSH or CSSHx options.
EOF
        return 0
        ;;
      *) 
        if [[ "$1" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
          [[ -n "$ips" ]] && ips+=" "
          ips+="$1"
        else
          [[ -n "$args" ]] && args+=" "
          args+="$1"
        fi
        ;;
    esac
    shift
  done

  for pl in $plookup; do
    [[ -n "$ip_data" ]] && ip_data+=" "
    ip_data+="$(aws-ips --public $ask "$pl" | xargs)"
  done
  for il in $ilookup; do
    [[ -n "$ip_data" ]] && ip_data+=" "
    ip_data+="$(aws-ips --private $ask "$il" | xargs)"
  done

  if [[ -n "$ask" ]]; then
    declare -A ipa; ipa=()
    local i=0
    # shellcheck disable=2013
    for ipd in $(echo "$ip_data" | tr ' ' '\n' | sort); do
      echo "[$i] ${ipd%%~*} ${ipd##*~}"
      ipa[$i]="${ipd##*~}"
      [[ -n "$tmp_ips" ]] && tmp_ips+=" "
      tmp_ips+="${ipd##*~}"
      i=$((i+1))
    done
    echo "Please select servers. Provide a comma-separated list of IDs or empty to select all."
    read -r -p ">> " user_input
    if [[ -z "$user_input" ]]; then
      local ips+="$tmp_ips"
    else
      for i in $(tr ',' ' ' <<<"$user_input"); do
        [[ -n "$ips" ]] && ips+=" "
        ips+="${ipa[$i]}"
      done
    fi
  else
    [[ -n "$ips" ]] && ips+=" "
    ips+="$ip_data"
  fi

  for ip in $ips; do
    [[ -n "$args" ]] && args+=" "
    args+="-h $ip"
  done
  # shellcheck disable=2086
  sshw $args
}
