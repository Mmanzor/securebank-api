#!/usr/bin/env bash
set -euo pipefail

release=$1
output=$2
mkdir -p "$output"
digest=$(jq -er '.digest | select(test("^sha256:[0-9a-f]{64}$"))' "$release/build.json")
image="localhost:5001/securebank@$digest"
identity="https://github.com/$GITHUB_WORKFLOW_REF"
issuer=https://token.actions.githubusercontent.com
auth=(
  --allow-http-registry
  --certificate-identity "$identity"
  --certificate-oidc-issuer "$issuer"
)

curl --fail --silent --show-error --head \
  -H "Accept: application/vnd.oci.image.manifest.v1+json" \
  "http://127.0.0.1:5001/v2/securebank/manifests/$digest" > "$output/manifest-headers.txt"

set +e
cosign verify "${auth[@]}" "$image" \
  > "$output/signature.json" 2> "$output/cosign-verify.log"
status=$?
set -e
cat "$output/cosign-verify.log"
if [[ "$status" -ne 0 ]]; then
  echo "::error::Cosign rechazó $image. Se bloquea staging."
  exit "$status"
fi

cosign verify-attestation "${auth[@]}" --type cyclonedx "$image" \
  > "$output/attestation.jsonl" 2> "$output/cosign-attestation.log"
cat "$output/cosign-attestation.log"
jq -e -s --arg digest "${digest#sha256:}" --slurpfile inventory "$release/sbom.cdx.json" '
  any(.[]; .payload | @base64d | fromjson
    | (.predicate == $inventory[0]) and any(.subject[]; .digest.sha256 == $digest))
' "$output/attestation.jsonl" > /dev/null
jq -e '[.verificationMaterial.tlogEntries[].logIndex] | length > 0' \
  "$release/signature.bundle.json" > /dev/null
jq -r '.verificationMaterial.tlogEntries[].logIndex | "Rekor logIndex: " + tostring' \
  "$release/signature.bundle.json" | tee "$output/rekor.txt"
printf 'Firma y atestación CycloneDX verificadas para %s\n' "$image"
printf 'image=%s\n' "$image" >> "$GITHUB_OUTPUT"
