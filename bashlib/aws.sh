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
  printf "set +o history\n"
  env | grep "AWS_" | sed "s/^/export /g"
  printf "set -o history\n"
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
    printf "aws_profile: ${AWS_DEFAULT_PROFILE:-none}\n"
    printf "aws_region: ${AWS_DEFAULT_REGION:-none}\n"
    [[ "$printc" -eq 1 ]] && print_aws_commands
    return 0
  fi
  check_aws_config || return $?
  local profile="$1"
  export AWS_DEFAULT_PROFILE="$profile"
  # role arn?
  export AWS_ROLE_ARN="$(aws configure get $profile.role_arn)"
  # src profile?
  export AWS_SRC_PROFILE=$(aws configure get $profile.source_profile)
  [[ -n "$AWS_SRC_PROFILE" ]] && local profile="$AWS_SRC_PROFILE"
  # set standards
  export AWS_DEFAULT_REGION="${2:-$(aws configure get $profile.region)}"
  export AWS_ACCESS_KEY_ID="$(aws configure get $profile.aws_access_key_id)"
  export AWS_SECRET_ACCESS_KEY="$(aws configure get $profile.aws_secret_access_key)"
  # Non-standard env variables
  export AWS_REGION="$AWS_REGION"
  export AWS_PROFILE="$AWS_DEFAULT_PROFILE"
  # Cleanup empty variables
  for v in AWS_DEFAULT_PROFILE \
           AWS_ROLE_ARN \
           AWS_SRC_PROFILE \
           AWS_DEFAULT_REGION \
           AWS_ACCESS_KEY_ID \
           AWS_SECRET_ACCESS_KEY \
           AWS_REGION \
           AWS_PROFILE; do
    [[ -z "${!v}" ]] && unset "$v"
  done
  [[ "$printc" -eq 1 ]] && print_aws_commands
}
