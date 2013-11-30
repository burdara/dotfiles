#!/usr/bin/env bash

### ENVIRONMENT VARIABLES
export M2_HOME=/opt/boxen/homebrew/Cellar/maven30/3.0.5/libexec
export SOAPUI_HOME=/Applications/soapUI-4.5.2.app/Contents/java/app
export HCSC_APP_MODE=local

### FUNCTIONS
ssh_bamboo() {
  [[ $# -ne 2 || -z $1 || -z $2 ]] && echo "missing or invalid arguments" && return 1
  hostname=$2
  ssh -i ~/.ssh/elasticbamboo.pk -o StrictHostKeyChecking=no $1@$2
}
ssh_ci() {
  [[ $# -ne 1 || -z $1 ]] && echo "missing or invalid arguments" && return 1
  ssh_bamboo root $1
}
ssh_dev() {
  ssh_bamboo ubuntu dev.hcsc.slalomcloud.com
}

set_mvn_version() {
  [[ $# -ne 1 || -z $1 ]] && echo "missing or invalid arguments" && return 1
  mvn versions:set -DgenerateBackupPoms=false -DnewVersion=$1
}
alias mver='set_mvn_version'

spfvim() {
  [[ -e ~/.vimrc ]] && mv ~/.vimrc ~/.spf13.vimrc && echo "spf 13 [OFF]" && return 0
  [[ -e ~/.spf13.vimrc ]] && mv ~/.spf13.vimrc ~/.vimrc && echo "spf 13 [ON]" && return 0
}

git_diff_cms() {
    [[ $# -ne 3 || -z $1 || -z $2 || -z $3 ]] && echo "missing or invalid arguments" && return 1
    proj=$(echo $1 | awk '{print toupper($0)}'); v1=$2; v2=$3
    case $proj in
        HMC)
            cd /code/hcsc/hmc/
            rel_path=help-me-choose/src/main/resources/cms/static/hmc
            ;;
        SE) 
            cd /code/hcsc/se
            rel_path=subsidy-estimator/src/main/resources/cms/static/se
            ;;
        RSC) 
            cd /code/hcsc/rsc2
            rel_path=retailshoppingcart/src/main/resources/cms/static/rsc
            ;;
        *) echo "invalid project (HMC|SE|RSC)" && return 1
    esac
    git diff $v1 $v2 --minimal --summary --unified=2 --src-prefix=PREV/ --dst-prefix=CURRENT/ --relative=$rel_path ./$rel_path > CMS_Deltas_${proj}_$(date +"%Y%m%d").diff
}
alias cmsdiff='git_diff_cms'

