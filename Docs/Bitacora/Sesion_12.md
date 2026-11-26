# Bitácora · Sesión 12 — Kubernetes y seguridad cloud-native

**Proyecto:** SecurePipeline · SecureBank API\
**Rama:** `feature/kubernetes-hardening-s12`

## Objetivo

Desplegar SecureBank en un clúster local aplicando mínimo privilegio y validar los controles en ejecución.

## Actividades

- Creamos un Deployment con dos réplicas e imagen fijada por digest. Configuramos UID 10001, seccomp, raíz de solo lectura, límites de recursos y retiro de todas las capabilities.
- Referenciamos la credencial temporal mediante `secretKeyRef`. La ServiceAccount no monta token y su identidad no puede leer Secrets por la API de Kubernetes.
- Ejecutamos kube-score y Kubesec y validamos los manifiestos complementarios del ejercicio. GitHub Actions levantó un clúster Kind temporal e hizo el despliegue real de la API de prueba.

## Resultados y evidencias

- Las dos réplicas quedaron listas. El cliente autorizado obtuvo HTTP 200 por el Service interno.
- Se comprobó que el Secret quedó cifrado con AES-GCM en etcd y que la admisión rechazó la solicitud de un Pod con UID 0.
- [Ejecución y artefactos](https://github.com/Mmanzor/securebank-api/actions/runs/45728589475) · [Guía y manifiestos](../../k8s/README.md) · [PR #7](https://github.com/Mmanzor/securebank-api/pull/7).

## Conclusión

Los controles quedaron verificados en Kind. El frontend y el worker fueron ejemplos de práctica validados en seco. La API fue el Deployment que se ejecutó y probó.
