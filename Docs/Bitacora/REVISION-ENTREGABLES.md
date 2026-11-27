# Trazabilidad de entregables · revisión complementaria

| Sesión | Complemento y alcance |
|---|---|
| 01 | [Ejercicio de activos, amenazas y vulnerabilidades](../Ciclo_Trabajo/ACTIVOS-AMENAZAS.md). |
| 02 | La API de GitHub indica main protegida en la revisión del commit 8dab202. La integración no tiene permiso administrativo para leer las reglas detalladas; MFA individual no verificado. |
| 05 | [Clasificación y alcance SAST](Sesion_05_Anexo.md). Evidencias históricas referenciadas; no se fabrican reportes. |
| 06 | [Inventario y política CVSS](Sesion_06_Anexo.md). |
| 07 | [Procedimiento formal de secretos](../SECRETS.md). |
| 08 | [Reportes originales ZAP](../Evidencias/Sesion_08/). El baseline del 19 de noviembre de 2026 registra una alerta informativa en tres instancias; OpenAPI del 20 de noviembre registra cero alertas. No equivalen a ausencia total de riesgos. |
| 09 | [Política y pruebas de OPA](../../security/s09/README.md), con runs de bloqueo y aceptación documentados en S09. |
| 11 | [Informe técnico y resultados](../../terraform/README.md). El run positivo registra tres jobs exitosos y conserva el artefacto de Checkov. El PDF y la captura del pipeline son entregables separados. |
| 13 | [Firma y verificación](../../security/s13/ANALISIS.md). Se conserva la arquitectura de laboratorio, no se afirma un despliegue productivo. |

Los resultados de laboratorio históricos se distinguen de los controles propuestos. Esta revisión no atribuye trabajo nuevo a integrantes ni modifica la lista de autores.
## Evidencias complementarias verificadas

- [SAST, SCA, Gitleaks y PDF: ejecución exitosa](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584).
- [S07: bloqueo remoto con empaquetado omitido](https://github.com/Mmanzor/securebank-api/actions/runs/45944913434).
- [CI original verde](https://github.com/Mmanzor/securebank-api/actions/runs/45944833568).
- [Reglas activas de main](https://github.com/Mmanzor/securebank-api/rules/24343037): revisión aprobatoria, firmas, build-test obligatorio, restricciones de borrado y force-push. No se cambian estas reglas; MFA por usuario no verificado.
- [Archivos conservados](../../reports/README.md).
