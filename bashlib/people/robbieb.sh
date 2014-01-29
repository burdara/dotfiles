#!/usr/bin/env bash

### Aliases
# md5
alias md5="md5 -r"
alias md5sum="md5 -r"

# Node Version Manager
[[ -s $HOME/.nvm/nvm.sh ]] && source $HOME/.nvm/nvm.sh

# Groovy Home
[[ -d /opt/boxen/homebrew/opt/groovy/libexec ]] && export GROOVY_HOME=/opt/boxen/homebrew/opt/groovy/libexec
