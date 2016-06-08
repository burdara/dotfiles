#!/usr/bin/env bash
#
# aws bashlib

########################################
# Print aws configuration requirements
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
print_aws_requirements() {
  cat <<EOF
Prerequisites:
  - awscli installed and added to PATH
  - aws env profiles created

Commands to setup environement profiles:
  aws configure --profile PROFILE_NAME

EOF
}

#######################################
# Check for aws binary and config files
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
check_aws_config() {
  which aws &>/dev/null 2>&1 \
    && [[ -e "$HOME/.aws/credentials" ]] \
    && [[ -e "$HOME/.aws/config" ]] \
    && return
  print_aws_requirements && return 1
}

#######################################
# Prints aws environment commands
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
print_aws_commands() {
  printf "set +o history"
  env | grep "AWS_" | sed "s/^/export /g"
  printf "set -o history"
}

#######################################
# Set aws environemnt variables
# Globals:
#   None
# Arguments:
#   -c  print out aws env commands (optional)
#   $1  profile_name (default to 'default' profile)
#   $2  region override (optional)
# Returns:
#   None
#######################################
awsenv() {
  [[ "$1" == "-c" ]] && local printc=1 && shift
  if [[ -z "$1" ]]; then
    printf "aws_profile: ${AWS_DEFAULT_PROFILE:-none}"
    printf "aws_region: $AWS_REGION"
    [[ "$printc" -eq 1 ]] && print_aws_commands
    return 0
  fi
  check_aws_config || return $?
  export AWS_DEFAULT_PROFILE="$1"
  export AWS_REGION="${2:-$(aws configure get $AWS_DEFAULT_PROFILE.region)}"
  export AWS_ACCESS_KEY_ID="$(aws configure get $AWS_DEFAULT_PROFILE.aws_access_key_id)"
  export AWS_SECRET_ACCESS_KEY="$(aws configure get $AWS_DEFAULT_PROFILE.aws_secret_access_key)"
  export AWS_DEFAULT_REGION="$AWS_REGION"
  [[ "$printc" -eq 1 ]] && print_aws_commands
}
