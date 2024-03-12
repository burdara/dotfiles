#!/usr/bin/env sh
#
# Configure verison managers.

test -d "$HOME/.local/bin" && add_paths "$HOME/.local/bin"

# Ruby Environment
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# Node environment
command -v nodenv >/dev/null 2>&1 && eval "$(nodenv init -)"

# Python environment
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null 2>&1; then 
  add_paths --prepend "$PYENV_ROOT/bin"
  eval "$(pyenv init -)"
fi

# java versions
! test -d "$HOME/.jenv/bin" && mkdir -p "$HOME/.jenv/bin"
add_paths "$HOME/.jenv/bin"
command -v jenv >/dev/null 2>&1 && eval "$(jenv init -)"
find /Library/Java/JavaVirtualMachines -type d -name "Home" > /tmp/jvm
while IFS= read -r jhome; do
  jenv add "$jhome" >/dev/null
done < /tmp/jvm
rm -f /tmp/jvm

# Version manager init processes don't manage paths well
# Just in case this runs several times, we will remove deplicates from PATH
dedupe_path