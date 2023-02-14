#!/usr/bin/env bash
mydir="$(cd "$(dirname "$0")" && pwd)"
docker run -v "$mydir/..:/mnt" koalaman/shellcheck-alpine \
  sh -c "find /mnt -name '*.sh' | grep -Ev '[/]+\.[[:alnum:]]' \
    | xargs shellcheck -x --format=gcc"