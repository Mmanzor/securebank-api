#!/usr/bin/env bash
set -euo pipefail

kubectl -n securebank rollout status deployment/securebank-api --timeout=150s
kubectl -n securebank get pods -o wide

ready=$(kubectl -n securebank get deployment securebank-api -o jsonpath='{.status.readyReplicas}')
test "$ready" = 2
kubectl -n securebank exec deployment/securebank-api -- node -e '
  const assert = require("node:assert/strict");
  const fs = require("node:fs");
  assert.equal(process.getuid(), 10001);
  assert(!fs.existsSync("/var/run/secrets/kubernetes.io/serviceaccount/token"));
  assert(Boolean(process.env.DB_PASSWORD));
  assert.throws(() => fs.writeFileSync("/tmp/s12-write-test", "test"), { code: "EROFS" });
  fetch("http://127.0.0.1:3000/health").then(async (response) => {
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { service: "securebank-api", status: "ok" });
    console.log("HTTP 200, UID 10001, filesystem de solo lectura, Secret presente y token ausente");
  });
'

account=system:serviceaccount:securebank:securebank-api
decision=$(kubectl auth can-i get secrets --namespace securebank --as="$account") || status=$?
test "${status:-0}" = 1
test "$decision" = no
printf 'La ServiceAccount no puede leer Secrets mediante la API\n'

kubectl -n kube-system exec etcd-securebank-control-plane -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/secrets/securebank/securebank-db --print-value-only \
  | python3 -c 'import sys; assert sys.stdin.buffer.read().startswith(b"k8s:enc:aesgcm:v1:securebank-s12:"); print("Secret cifrado con AES-GCM en etcd")'

# Prove admission rejects a pod that requests root without ever starting that pod.
if kubectl -n securebank run reject-root --image=localhost:5001/securebank:lab \
    --dry-run=server --overrides='{"spec":{"securityContext":{"runAsUser":0}}}' > restricted.txt 2>&1; then
  printf 'La admisión aceptó un pod incompatible con Restricted\n' >&2
  exit 1
fi
grep -q 'violates PodSecurity' restricted.txt
printf 'Pod Security Admission rechazó el manifiesto incompatible\n'
