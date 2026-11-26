#!/usr/bin/env bash
set -euo pipefail

name=$1
destination=$2
mkdir -p "$destination"
destination=$(realpath "$destination")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

case "$name" in
  cosign)
    url=https://github.com/sigstore/cosign/releases/download/v3.1.6/cosign-linux-amd64
    sha=318a99ade4156a0c4113aa983b46c0a0830fa7896a096c63121ee47b610a94c6
    ;;
  syft)
    url=https://github.com/anchore/syft/releases/download/v1.57.2/syft_1.57.2_linux_amd64.tar.gz
    sha=ad92bd3ec1b94a3df01d4d0aec199afa9c42b72e86da436ff5f837914d32706b
    ;;
  cyclonedx)
    url=https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.33.1/cyclonedx-linux-x64
    sha=bfc8b2538da86fe239bc53658bbb63c1c8c510a293c1e6891aa5bea5d3c58746
    ;;
  kind)
    url=https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-amd64
    sha=aee6151561422756b764a4ae28e7f44cda5af5a9eead3cc9985112b1de8d8e0d
    ;;
  *)
    printf 'Herramienta desconocida: %s\n' "$name" >&2
    exit 2
    ;;
esac

curl -fsSL --max-time 90 "$url" -o "$tmp/download"
printf '%s  %s\n' "$sha" "$tmp/download" | sha256sum --check
if [[ "$name" == syft ]]; then
  tar -xzf "$tmp/download" -C "$tmp" syft
  install -m 0755 "$tmp/syft" "$destination/syft"
else
  install -m 0755 "$tmp/download" "$destination/$name"
fi
