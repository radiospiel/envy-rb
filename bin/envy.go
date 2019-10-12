#!/bin/bash
set -eu -o pipefail

newest_file=$(find src/envy/ -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -1 | cut -f2- -d" ")

if [ $newest_file -nt $0.bin ]; then
  echo "> building $0.bin..." >&2
  # go build -ldflags="-s -w" -o $0.bin src/envy/main.go
  go build -o $0.bin src/envy/main.go
fi

exec $0.bin "$@"
