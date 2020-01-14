#!/usr/bin/env bash
#
# AWS CLI configurations.

export AWS_PS1_CACHE_FILE="$HOME/.aws/.ps1_cache"

# Sources AWS PS1 cache file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
aws_ps1_cache_read() {
  # shellcheck source=/dev/null
  [[ -r "$AWS_PS1_CACHE_FILE" ]] && source "$AWS_PS1_CACHE_FILE"
}

# Clears AWS PS1 cache file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
aws_ps1_cache_clear() {
  [[ -r "$AWS_PS1_CACHE_FILE" ]] && rm -f "$AWS_PS1_CACHE_FILE"
}

# Outputs AWS PS1 informations
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   PS1 informations
aws_ps1() {
  [[ "${AWS_PS1:-on}" == "off" ]] && return 0
  local _clr_red _clr_green _clr_cyan _clr_magenta _clr_reset _expire
  _clr_red="$(tput setaf 1 || echo "\e[31m")"
  _clr_green="$(tput setaf 2 || echo "\e[32m")"
  _clr_cyan="$(tput setaf 6 || echo "\e[36m")"
  _clr_magenta="$(tput setaf 5 || echo "\e[35m")"
  _clr_reset="$(tput sgr0 || echo "\e[0m")"

  [[ -d "$HOME/.aws" ]] && mkdir -p "$HOME/.aws"
  local _ps1_sts _ps1_key _ps1_sep1 _ps1_sep2 _ps1_zone
  aws_ps1_cache_read
  
  # check profile, if specified
  local _profile="${AWS_DEFAULT_PROFILE:-$AWS_PROFILE}"
  
  if [[ -n "$_profile" ]]; then
    if [[ ! -r "$AWS_PS1_CACHE_FILE" \
      || -z "$AWS_PS1_CACHE_PROFILE" \
      || "$AWS_PS1_CACHE_PROFILE" != "$_profile" ]]
    then
      AWS_PS1_CACHE_SESSION="$(aws configure get "$_profile.aws_session_token")"
      AWS_PS1_CACHE_EXPIRE="$(aws configure get "$_profile.aws_session_token_expire")"
      AWS_PS1_CACHE_SRCP="$(aws configure get "$_profile.source_profile")"
      AWS_PS1_CACHE_PROFILE="$_profile"

      if [[ -z "$AWS_PS1_CACHE_EXPIRE" && -n "$AWS_PS1_CACHE_SRCP" ]]; then
        AWS_PS1_CACHE_EXPIRE="$(aws configure get "$AWS_PS1_CACHE_SRCP.aws_session_token_expire")"
      fi

      cat <<EOF >"$AWS_PS1_CACHE_FILE"
export AWS_PS1_CACHE_PROFILE="$AWS_PS1_CACHE_PROFILE"
export AWS_PS1_CACHE_SESSION="$AWS_PS1_CACHE_SESSION"
export AWS_PS1_CACHE_EXPIRE="$AWS_PS1_CACHE_EXPIRE"
export AWS_PS1_CACHE_SRCP="$AWS_PS1_CACHE_SRCP"
EOF
    fi

    _ps1_key="$_profile"
    [[ -n "$AWS_PS1_CACHE_SESSION" ]] && _ps1_sts="*"
    _expire="$AWS_PS1_CACHE_EXPIRE"
  fi

  # check env variables, if specified
  [[ -n "$AWS_SESSION_TOKEN" ]] && _ps1_sts="*"
  [[ -n "$AWS_SESSION_TOKEN_EXPIRE" ]] && _expire="$AWS_SESSION_TOKEN_EXPIRE"
  [[ -n "$AWS_ACCESS_KEY_ID" && -n "$AWS_SECRET_ACCESS_KEY" ]] && _ps1_key="keys"
  [[ -n "$AWS_DEFAULT_REGION" ]] && _ps1_zone="$AWS_DEFAULT_REGION"
  [[ -n "$_ps1_zone" ]] && _ps1_sep1=":"

  if [[ -n "$_expire" ]]; then
    local t="$(($(date -j -f '%Y-%m-%dT%H:%M:%S%z' "${_expire/Z/+0000}" +"%s")-$(date -u +"%s")))"
    if [[ "$t" -gt 0 ]]; then
      local h=$((t/60/60%24))
      local m=$((t/60%60))
      local s=$((t%60))
      _ps1_ttl="$h:$m:$s"
    else
      _ps1_ttl="0:0:0"
    fi
    [[ -n "$_ps1_ttl" ]] && _ps1_sep2=":"
  else
    _ps1_ttl=""
  fi

  [[ -n "$_ps1_key" || -n "$_ps1_zone" ]] \
    && echo "(${_clr_magenta}aws${_clr_reset}|${_clr_green}${_ps1_key}${_clr_reset}${_clr_red}${_ps1_sts}${_clr_reset}${_ps1_sep1}${_clr_cyan}${_ps1_zone}${_clr_reset}${_ps1_sep2}${_clr_red}${_ps1_ttl}${_clr_reset})"
}

aws_ps1_off() {
  export AWS_PS1="off"
}

aws_ps1_on() {
  export AWS_PS1="on"
}

# Set aws environemnt variables
# Globals:
#   None
# Arguments:
#   1: name filter
#   [options]:  See usage below
# Returns:
#   None
awsips() {
  local name_filter
  local ip_type="private"
  local include_names="false"
  while [[ -n "$1" ]]; do
    case "$1" in
      --include-names) include_names="true" ;;
      --private)      ip_type="private" ;;
      --public)       ip_type="public" ;;
      -r|--region)    shift; region="$1" ;;
      -h|--help)      cat <<EOF
usage: awsips [options] name_filter
options:
  --include-names          Include name with IPs.
  --private                Output private IPs.
  --public                 Output public IPs.
  -r, --region <region>    Sets AWS region.
  -h, --help               Prints usage.
dependencies:
  aws (binary)             AWS CLI
  jq  (binary)             JSON query
EOF
        return 0
        ;;
      *) name_filter="$1"
    esac
    shift
  done
  
  local rc
  ! command -v aws &>/dev/null 2>&1 \
    && printf "aws cli binary not found" && rc=1
  ! command -v jq &>/dev/null 2>&1 \
    && printf "jq binary not found" && rc=1
  [[ "$rc" -eq 1 ]] && return 1

  local field="PrivateIpAddress"
  [[ "$ip_type" == "public" ]] && field="PublicIpAddress"
  local jq_query=".Reservations[].Instances[].$field"
  [[ "$include_names" == "true" ]] && jq_query=".Reservations[].Instances[] | (.Tags[] | select(.Key == \"Name\").Value) +\"~\"+ .$field"
  [[ -n "$region" ]] && local region_opt="--region $region"
  
  # shellcheck disable=2086
  aws ec2 describe-instances $region_opt --filters \
    "Name=instance-state-name,Values=running" \
    "Name=tag:Name,Values=*$name_filter*" \
      | jq -r "$jq_query"
}

# Set aws environemnt variables
# Globals:
#   None
# Arguments:
#   [options]  See usage below
# Returns:
#   None
awsenv() {
  if [[ "$#" -eq 0 ]]; then
    env | grep "AWS_" | sed "s/\(AWS_SECRET_ACCESS_KEY=\).*/\1********/"
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
      -h|--help)     cat <<EOF
usage: awsenv [options]
options:
  -e, --exports            Displays AWS environment commands for cut & paste.
  -p, --profile <profile>  Sets AWS profile.
  -r, --region <region>    Sets AWS region.
  +v, +vars                Set extra AWS environment variables.
  -v, -vars                Cleanup extra AWS environment variables.
  -h, --help               Prints usage.
EOF
        return 0
        ;;
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
  for v in AWS_PROFILE \
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
    for e in $(env | grep "AWS_" | awk -F= '{print $1}' | xargs); do
      case "$e" in
        AWS_DEFAULT_PROFILE|AWS_DEFAULT_REGION) : ;;
        *) unset "$e" ;;
      esac
    done
  fi

  aws_ps1_cache_clear

  if [[ "$print_exports" -eq 1 ]]; then
    printf "set +o history\\n"
    env | grep "AWS_" | sed "s/^/export /g"
    printf "set -o history\\n"
  fi
}

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
    ip_data+="$(awsips --public $ask "$pl" | xargs)"
  done
  for il in $ilookup; do
    [[ -n "$ip_data" ]] && ip_data+=" "
    ip_data+="$(awsips --private $ask "$il" | xargs)"
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

aws-ssh-us() {
  awsenv --region "us-west-2"
  aws_ssh_cssh_helper "$@"
}

aws-ssh-eu() {
  awsenv --region "eu-west-1"
  aws_ssh_cssh_helper "$@"
}

# AWS ssm wrapper function.
# Globals:
#   None
# Arguments:
#   @: Options and commands. Refer to usage.
# Returns:
#   None
aws-ssm() {
  local usage
  usage=$(cat <<EOF
usage: ssm [options] [instance-id|ip-address|k8s-node-name]"
options:
  -r, --region <region>    AWS region.
  -l, --list               List available instance IDs.
EOF
  )

  if [[ ! -x /usr/local/bin/session-manager-plugin ]]; then
    echo "AWS SSM plugin not found; attempting to install"
    local download_file="/tmp/sessionmanager-bundle.zip"
    local unzip_dir="/tmp/sessionmanager-bundle"

    # TODO(robbie): add more OS support
    if [[ "$(uname -s)" == "Darwin" ]]; then
      curl -sL -o "$download_file" \
        "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip"
    fi

    if [[ -e "$download_file" ]]; then
      unzip -d /tmp "$download_file"
      sudo "$unzip_dir/install" \
        -i /usr/local/sessionmanagerplugin \
        -b /usr/local/bin/session-manager-plugin
      [[ -d "$unzip_dir" ]] && rm -rf "$unzip_dir"
      rm -f "$download_file"
    fi
  fi

  local list=0
  local region="$AWS_DEFAULT_REGION"
  local input
  while [[ -n "$1" ]]; do
    case "$1" in
      -r|--region) shift; region="$1" ;;
      -l|--list) list=1 ;;
      *) input="$1" ;;
    esac
    shift
  done
  local region_output="AWS REGION: $region"

  [[ -z "$region" ]] && echo "no aws region found or specified" && return 1
  [[ "$list" -eq 1 ]] \
    && echo "$region_output" \
    && aws ssm describe-instance-information --region "$region" --output table \
    && return 0
  [[ -z "$input" ]] && echo "$usage" && return 0

  echo "$region_output"
  local target
  if [[ "$input" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] \
    || [[ "$input" =~ ip-[0-9]{1,3}-[0-9]{1,3}-[0-9]{1,3}-[0-9]{1,3}[a-z0-9.]* ]] \
    || [[ "$input" =~ i-[a-z0-9]+ ]]; then
    target="$(aws ssm describe-instance-information --region "$region" --output text \
      | grep "$input" | awk '{print $5}')"
  else
    echo -e "invalid argument\n$usage" && return 1
  fi

  local found
  found="$(wc -w <<< "$target" | tr -d ' ')"
  [[ "$found" -eq 0 ]] \
    && echo "instance-id not found for $input; please try --list option" \
    && return 1
  [[ "$found" -gt 1 ]] \
    && echo "multiple instance-ids found for $input; please try --list option" \
    && return 1

  aws ssm start-session --region "$region" --target "$target"
}

# AWS MFA wrapper
# Globals:
#   None
# Arguments:
#   [options]: refer to usage
# Returns:
#   Depends on output options
aws-mfa() {
  local mfa_serial_number mfa_code ttl_seconds session_creds_json 
  local mfa_name session_profile_name output_type to_profile
  local default_ttl_seconds="28800"
  local default_output_type="profile"
  local set_output="false"

  ! command -v jq &>/dev/null \
    && echo "jq binary required; please install first" && return 1
  
  local aws_opts=()
  while [[ -n "$1" ]]; do
    case "$1" in
      -c|--code) shift; mfa_code="$1" ;;
      -o|--output) shift; output_type="$1" ;;
      -p|--profile) shift; aws_opts+=("--profile" "$1") ;;
      -s|--serial) shift; mfa_serial_number="$1" ;;
      -t|--ttl) shift; ttl_seconds="$1" ;;
      --set) set_output="true" ;;
      --to-profile) shift; to_profile="$1" ;;
      -h|--help) cat <<EOF
usage: aws-mfa [options]
options:
  -c, --code <mfa>           The  value provided by the MFA device.
  -o, --output <type>        Output types: json, profile, env (default $default_output_type)
  -p, --profile <name>       Profile with default credentials
  -s, --serial <arn>         The identification number of the MFA device that is associated with the IAM user.
  -t, --ttl <secs>           The duration, in seconds, that the credentials should remain valid. (default $default_ttl_seconds)
  --set                      For output type = 'env', export the environment variables
                             For output type = 'profile', create the profile and export environment variable
  --to-profile <name>        For output type = 'profile', use specified name for for profile (default: sts-<username>)
  -h, --help
EOF
      return 0
    esac
    shift
  done

  # If empty attempt discovery or prompt
  [[ -z "$mfa_serial_number" ]] \
    && mfa_serial_number="$(aws "${aws_opts[@]}" iam list-mfa-devices | jq -r '.MFADevices[0].SerialNumber')" \
    && echo "# MFA Serial: $mfa_serial_number"
  [[ -z "$mfa_code" ]] \
    && read -r -p "# Enter MFA code: " mfa_code

  # Double check emptiness
  [[ -z "$mfa_serial_number" ]] \
    && >&2 echo "[error] mfa_serial_number not specified or empty." && return 1
  [[ -z "$mfa_code" ]] \
    && >&2 echo "mfa_code not specified or empty." && return 1

  # Retrieve session credentials
  session_creds_json="$(aws "${aws_opts[@]}" sts get-session-token \
    --serial-number "$mfa_serial_number" \
    --token-code "$mfa_code" \
    --duration-seconds "${ttl_seconds:-$default_ttl_seconds}")" \
    || { >&2 echo "failed to get session token" && return "$?" ;}

  local aws_access_key_id aws_secret_access_key aws_session_token aws_session_token_expire
  aws_access_key_id="$(echo "$session_creds_json" | jq -r .Credentials.AccessKeyId)"
  aws_secret_access_key="$(echo "$session_creds_json" | jq -r .Credentials.SecretAccessKey)"
  aws_session_token="$(echo "$session_creds_json" | jq -r .Credentials.SessionToken)"
  aws_session_token_expire="$(echo "$session_creds_json" | jq -r .Credentials.Expiration)"
  case "${output_type:-$default_output_type}" in
    profile)
      mfa_name="${mfa_serial_number##*/}"
      session_profile_name="${to_profile:-sts-${mfa_name}}"
      if [[ "$set_output" == "true" ]]; then
        aws configure --profile "$session_profile_name" set aws_access_key_id "$aws_access_key_id"
        aws configure --profile "$session_profile_name" set aws_secret_access_key "$aws_secret_access_key"
        aws configure --profile "$session_profile_name" set aws_session_token "$aws_session_token"
        aws configure --profile "$session_profile_name" set aws_session_token_expire "$aws_session_token_expire"
        [[ -n "$AWS_DEFAULT_PROFILE" ]] && unset AWS_DEFAULT_PROFILE
        export AWS_PROFILE="$session_profile_name"
        aws_ps1_cache_clear
      fi
      cat <<EOF
aws configure --profile "$session_profile_name" set aws_access_key_id "$aws_access_key_id"
aws configure --profile "$session_profile_name" set aws_secret_access_key "$aws_secret_access_key"
aws configure --profile "$session_profile_name" set aws_session_token "$aws_session_token"
aws configure --profile "$session_profile_name" set aws_session_token_expire "$aws_session_token_expire"
[[ -n "\$AWS_DEFAULT_PROFILE" ]] && unset AWS_DEFAULT_PROFILE
export AWS_PROFILE="$session_profile_name"
EOF
      ;;
    env) 
      if [[ "$set_output" == "true" ]]; then
        export AWS_ACCESS_KEY_ID="$aws_access_key_id"
        export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
        export AWS_SESSION_TOKEN="$aws_session_token"
        export AWS_SESSION_TOKEN_EXPIRE="$aws_session_token_expire"
        [[ -n "$AWS_DEFAULT_PROFILE" ]] && unset AWS_DEFAULT_PROFILE
        [[ -n "$AWS_PROFILE" ]] && unset AWS_PROFILE
        aws_ps1_cache_clear
      fi
      cat <<EOF
export AWS_ACCESS_KEY_ID="$aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
export AWS_SESSION_TOKEN="$aws_session_token"
export AWS_SESSION_TOKEN_EXPIRE="$aws_session_token_expire"
[[ -n "\$AWS_DEFAULT_PROFILE" ]] && unset AWS_DEFAULT_PROFILE
[[ -n "\$AWS_PROFILE" ]] && unset AWS_PROFILE
EOF
      ;;
    json) echo "$session_creds_json" ;;
    *) >&2 echo "invalid output type" && return 1 ;;
  esac
}