# Bitácora · Sesión 10 — Seguridad de contenedores y Docker

**Proyecto:** SecurePipeline · SecureBank API\
**Rama:** `feature/docker-hardening-s10`

## Objetivo

Reducir el tamaño, los privilegios y los hallazgos de seguridad de la imagen de SecureBank, manteniendo operativo el endpoint `/health`.

## Actividades

- Construimos una imagen de referencia y una endurecida con el mismo código y la misma versión de Node.js. La imagen endurecida usa Debian slim y copia solo el ejecutable de Node.js.
- Fijamos las imágenes base por digest, limitamos el contexto con `.dockerignore` y configuramos el usuario `appuser` con UID 10001. La imagen endurecida declara el puerto HTTP 3000.
- GitHub Actions comprobó ambas respuestas HTTP y ejecutó Trivy con la misma base de vulnerabilidades. También verificó que la imagen endurecida funciona con la raíz en solo lectura y sin capacidades adicionales.

## Resultados y evidencias

| Medición | Referencia | Endurecida |
| --- | ---: | ---: |
| Hallazgos críticos | 3 | 0 |
| Hallazgos altos | 192 | 51 |
| Tamaño | 441,6 MB | 76,0 MB |
| Paquetes Debian | 455 | 78 |

- [Informe comparativo](../../docker/REPORT.md) · [Ejecución y salidas de Trivy](https://github.com/Mmanzor/securebank-api/actions/runs/45725209090) · [PR #5](https://github.com/Mmanzor/securebank-api/pull/5).

## Conclusión

La imagen endurecida pasó el umbral de cero hallazgos críticos. Los 51 hallazgos altos permanecen visibles en el informe y forman parte del riesgo residual del laboratorio.
