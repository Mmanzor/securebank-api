# Bitácora · Sesión 11 — Terraform y seguridad IaC

**Proyecto:** SecurePipeline · SecureBank API\
**Rama:** `feature/iac-security-s11`

## Objetivo

Detectar configuraciones inseguras de infraestructura como código antes de ejecutar las etapas de Terraform.

## Actividades

- Modelamos la infraestructura AWS del laboratorio y generamos una línea base para análisis estático. La línea base quedó configurada para que Terraform no pueda inicializarla.
- Corregimos la exposición de SSH, los controles de acceso de S3, el cifrado de RDS, los permisos IAM y la auditoría de CloudTrail y VPC Flow Logs.
- Configuramos Checkov y un gate que exige un mínimo de 85 %, bloquea hallazgos críticos, altos o sin clasificar y valida que el reporte esté completo. Las severidades corresponden a la política local del laboratorio.

## Resultados y evidencias

| Medición | Línea base | Módulo corregido |
| --- | ---: | ---: |
| Security Score | 82,16 % | 94,05 % |
| Controles aprobados | 152 | 174 |
| Hallazgos críticos / altos según la política local | 4 / 18 | 0 / 0 |

- [Caso bloqueado](https://github.com/Mmanzor/securebank-api/actions/runs/45726588055) · [Caso aprobado y reportes JSON](https://github.com/Mmanzor/securebank-api/actions/runs/45727010153) · [Informe técnico y reproducción](../../terraform/README.md) · [PR #6](https://github.com/Mmanzor/securebank-api/pull/6).

## Conclusión

La línea base bloqueó plan y aplicación. El módulo corregido completó ambas etapas con AWS simulado y sin aprovisionamiento. El reporte mantiene visibles los 11 hallazgos residuales.
