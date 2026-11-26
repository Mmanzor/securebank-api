#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Uso: %s findings.json\n' "$0" >&2
  exit 2
fi

policy_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
decision="$(opa eval --fail --format raw --data "$policy_dir/security-policy-v1.rego" \
  --input "$1" 'data.securepipeline.gate.decision')"
jq . <<< "$decision"
jq --exit-status '.allow == true' <<< "$decision" > /dev/null
