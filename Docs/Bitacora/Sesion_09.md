# Bitácora · Sesión 09 — Security Quality Gate

**Proyecto:** SecurePipeline · SecureBank API\
**Rama:** `feature/security-gate-s09`

## Objetivo

Usar los resultados de los controles de seguridad para decidir automáticamente si un cambio puede generar un candidato de staging.

## Actividades

- Definimos la política Rego con cero hallazgos críticos, cero secretos y cobertura mínima de 80 %. Se configuraron también los límites para hallazgos altos y medios, con un umbral más estricto cuando la exposición es pública.
- Consolidamos los reportes de Gitleaks, Semgrep, Trivy, ZAP y cobertura en `findings.json`. ZAP revisó pasivamente el endpoint `/health` del servidor de prueba.
- Integramos OPA en GitHub Actions. El candidato de staging depende de que el gate apruebe la evaluación.

## Dificultad y solución

El comando que guardaba la decisión de OPA con `tee` podía ocultar su código de salida. Ajustamos el paso de Bash para propagar el fallo y verificamos el comportamiento con dos commits.

## Resultados y evidencias

- La cobertura inferior al 80 % provocó un bloqueo. GitHub Actions omitió la generación del candidato. [Caso bloqueado](https://github.com/Mmanzor/securebank-api/actions/runs/45724242168).
- Con las pruebas HTTP agregadas, el gate aprobó el cambio y GitHub generó el artefacto de staging. [Caso aprobado](https://github.com/Mmanzor/securebank-api/actions/runs/45724313392).
- [Política, archivos y umbrales](../../security/s09/README.md) · [PR #4](https://github.com/Mmanzor/securebank-api/pull/4).

## Conclusión

La decisión queda vinculada al commit y a sus reportes. Una condición de seguridad incumplida evita que se genere el candidato dentro de GitHub Actions.
