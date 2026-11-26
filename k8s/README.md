# Sesión 12 · Kubernetes y seguridad cloud-native

El entregable es [deployment.hardened.yaml](hardened/deployment.hardened.yaml).
Levanta dos réplicas del servidor de prueba de SecureBank en un namespace con
Pod Security Admission en modo `restricted`. El Service es interno
(`ClusterIP`) y el ConfigMap solo contiene configuración pública.

| Manifiesto | Cambio y razón |
| --- | --- |
| M1 · [Frontend](exercise/frontend-deployment.yaml) | Ejemplo sin `privileged`; usa el digest OCI verificado para fijar la imagen. |
| M2 · [API](hardened/deployment.hardened.yaml) | UID y GID 10001, `runAsNonRoot`, seccomp `RuntimeDefault`, sin escalamiento y con todas las capabilities retiradas. |
| M3 · [Secret](exercise/db-secret.yaml) | El valor se crea en tiempo de ejecución y la API lo referencia mediante `secretKeyRef`. El cluster de prueba cifra Secrets con AES-GCM y se verifica el prefijo del valor almacenado en etcd. |
| M4 · [Worker](exercise/worker-deployment.yaml) | Define solicitudes y límites de CPU, memoria y almacenamiento efímero, y monta la raíz en solo lectura. |
| M5 · [ServiceAccount](hardened/serviceaccount.yaml) | No tiene RoleBinding. Se desactiva el montaje automático del token en la ServiceAccount y en el Pod, y se prueba que esa identidad no puede leer Secrets. |

El frontend y el worker son manifiestos de práctica para validación en seco;
ambos reutilizan la imagen de prueba.
El Secret contiene un valor temporal de laboratorio. La API de este ejercicio sirve el endpoint de salud.

## Comprobaciones

- `kube-score` evalúa el Deployment y sus objetos asociados. Kubesec analiza
  los tres Deployments del ejercicio como código local.
- GitHub Actions crea un cluster Kind temporal, carga la imagen desde un
  registro limitado a loopback y comprueba el rollout y las dos réplicas.
- La prueba verifica `GET /health`, UID 10001, raíz de solo lectura, Secret
  inyectado, token ausente y permisos RBAC. La admisión rechaza en seco una
  solicitud de Pod como root.
- Las NetworkPolicies declaran denegación por defecto y una entrada acotada.
  El Job del laboratorio prueba HTTP y DNS con el Service desde un cliente
  autorizado. Su aplicación efectiva en otro cluster requiere un CNI que las implemente.

- [Ejecución de GitHub Actions](https://github.com/Mmanzor/securebank-api/actions/runs/45728589475)
- [Artefacto OCI, digest y reportes](https://github.com/Mmanzor/securebank-api/actions/runs/45728589475/artifacts/15075027547)

Kubesec asignó 10 puntos al Deployment de la API. El manifiesto en esta
rama fija el digest de la imagen de ese artefacto. El CI vuelve a materializar
el digest de la imagen construida para cada ejecución.

## Repetir el laboratorio con la misma imagen

Descarga el artefacto del workflow y extrae `securebank-s12.oci.tar`.
Los manifiestos incluidos en `deploy/` y `client.yaml` apuntan al digest de esa imagen.
Con Docker, Kind v0.33.0, kubectl y Skopeo, desde un checkout de esta rama:

```bash
docker run -d -p 127.0.0.1:5001:5000 --name securebank-registry registry:3
skopeo copy --preserve-digests --dest-tls-verify=false \
  oci-archive:securebank-s12.oci.tar docker://localhost:5001/securebank:lab
bash k8s/lab/start-kind.sh "$(mktemp -d)"
kubectl apply -f k8s/hardened/namespace.yaml
password_file=$(mktemp)
openssl rand -hex 32 > "$password_file"
kubectl -n securebank create secret generic securebank-db --from-file=password="$password_file"
rm -f "$password_file"
kubectl apply -f deploy/
bash k8s/lab/verify.sh
kubectl apply -f client.yaml
kubectl -n securebank wait --for=condition=complete job/securebank-probe --timeout=70s
kind delete cluster --name securebank
docker rm -f securebank-registry
```

El cluster y su clave son temporales. El artefacto conserva la imagen OCI,
los manifiestos aplicados, los resultados de los escáneres y la evidencia
de ejecución, sin incluir valores del Secret ni la clave de cifrado.
