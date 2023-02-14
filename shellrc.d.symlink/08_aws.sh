#!/usr/bin/env sh
#
# AWS CLI configurations.
export AWS_SDK_LOAD_CONFIG=1

export AWSP_SELF_OVERRIDE="awsp"
awsp() {
  ! hash awsph && echo >&2 "awsph script not found" && return 1
  awsph "$@"
  eval "$(awsph --set)"
}