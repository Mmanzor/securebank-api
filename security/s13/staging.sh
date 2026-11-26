#!/usr/bin/env bash
set -euo pipefail

image=$1
workdir=$2
[[ "$image" =~ ^localhost:5001/securebank@sha256:[0-9a-f]{64}$ ]]
mkdir -p "$workdir"
bash k8s/lab/start-kind.sh "$workdir/kind"
kubectl apply -f k8s/hardened/namespace.yaml
kubectl label namespace securebank securebank.ubo/signed-images=required

secret=$(mktemp "$workdir/db.XXXXXX")
trap 'rm -f "$secret"' EXIT
openssl rand -hex 32 > "$secret"
kubectl -n securebank create secret generic securebank-db --from-file=password="$secret"
rm -f "$secret"

sed "s|VERIFIED_IMAGE|$image|g" security/s13/admission.yaml > "$workdir/admission.yaml"
kubectl apply -f "$workdir/admission.yaml"

cat > "$workdir/unsigned-pod.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: digest-no-verificado
  namespace: securebank
spec:
  automountServiceAccountToken: false
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: probe
      image: localhost:5001/securebank:v1
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: [ALL]
YAML

for attempt in {1..15}; do
  if ! kubectl create --dry-run=server -f "$workdir/unsigned-pod.yaml" > "$workdir/denied.txt" 2>&1 \
      && grep -q 'Solo se admite el digest verificado por Cosign' "$workdir/denied.txt"; then
    break
  fi
  sleep 2
done
grep 'Solo se admite el digest verificado por Cosign' "$workdir/denied.txt"

mkdir -p "$workdir/deploy"
cp k8s/hardened/*.yaml "$workdir/deploy/"
sed -i -E "s|localhost:5001/securebank@sha256:[0-9a-f]{64}|$image|g" \
  "$workdir/deploy/deployment.hardened.yaml"
kubectl apply -f "$workdir/deploy/"
kubectl -n securebank rollout status deployment/securebank-api --timeout=150s
test "$(kubectl -n securebank get deployment securebank-api -o jsonpath='{.spec.template.spec.containers[0].image}')" = "$image"
kubectl -n securebank exec deployment/securebank-api -- node -e '
  fetch("http://127.0.0.1:3000/health").then(async (response) => {
    require("node:assert/strict").equal(response.status, 200);
    console.log(await response.text());
  });
'
