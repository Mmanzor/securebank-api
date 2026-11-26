#!/usr/bin/env bash
set -euo pipefail

workdir=$(realpath "$1")
umask 077
mkdir -p "$workdir"
key=$(openssl rand -base64 32)

cat > "$workdir/encryption.yaml" <<CONFIG
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources: [secrets]
    providers:
      - aesgcm:
          keys:
            - name: securebank-s12
              secret: $key
      - identity: {}
CONFIG
unset key

cat > "$workdir/kind.yaml" <<CONFIG
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.36.4@sha256:099e049362a1526b2db71494e1947aae99bd16290d7c895f2b7ea312e3cbfaed
    extraMounts:
      - hostPath: "$workdir/encryption.yaml"
        containerPath: /etc/kubernetes/securebank-encryption.yaml
        readOnly: true
kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta4
    kind: ClusterConfiguration
    apiServer:
      extraArgs:
        - name: encryption-provider-config
          value: /etc/kubernetes/securebank-encryption.yaml
      extraVolumes:
        - name: securebank-encryption
          hostPath: /etc/kubernetes/securebank-encryption.yaml
          mountPath: /etc/kubernetes/securebank-encryption.yaml
          readOnly: true
          pathType: File
CONFIG

kind create cluster --name securebank --config "$workdir/kind.yaml" --wait 2m
docker network connect kind securebank-registry
docker exec securebank-control-plane mkdir -p /etc/containerd/certs.d/localhost:5001
cat <<HOSTS | docker exec -i securebank-control-plane cp /dev/stdin /etc/containerd/certs.d/localhost:5001/hosts.toml
[host."http://securebank-registry:5000"]
HOSTS
