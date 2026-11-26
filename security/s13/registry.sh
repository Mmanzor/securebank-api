#!/usr/bin/env bash
set -euo pipefail

directory=$(realpath -m "$1")
mkdir -p "$directory"
if [[ $# -eq 2 ]]; then
  sudo tar -xzf "$2" -C "$directory"
fi

docker run -d --name securebank-registry \
  -p 127.0.0.1:5001:5000 \
  --volume "$directory:/var/lib/registry" \
  registry:3@sha256:82f6ff4a7f982960c8aa51617fea3aabc485df6e55cce80d22deb1de36f1bc3c
curl --fail --silent --show-error --retry 6 --retry-all-errors --retry-delay 1 http://127.0.0.1:5001/v2/
