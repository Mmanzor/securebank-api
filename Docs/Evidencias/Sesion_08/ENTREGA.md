# Sesión 08 · Reporte DAST y mitigación

[Salida original del baseline (report.json)](report.json) · [HTML nativo](zap-final.html) · [Salida original OpenAPI](zap-openapi.json).

| Severidad | CWE | URL / ruta | Hallazgo | Evidencia |
|---|---|---|---|---|
| Informativa (confianza media) | 524 | /, /robots.txt, /sitemap.xml | Non-Storable Content | Cache-Control: no-store |

ZAP 2.17.0. El baseline fue generado el 19/11/2026 a las 23:36:36 según el JSON; el plan OpenAPI del 20/11/2026 a las 00:13:14 registró cero alertas. La segunda ejecución tiene alcance distinto; no prueba la eliminación de la alerta informativa. El valor no-store es deliberado para no almacenar respuestas sensibles. No hubo alertas High/Medium de severidad; la confianza Media no es una severidad.

La [bitácora S08](../../Bitacora/Sesion_08.md) registra las pruebas de acceso a recursos propios, ajenos y sin autenticación (200, 403, 401). Los tokens son simulados; no hay cookies de sesión. Mantener la autorización por objeto y las cabeceras; repetir el escaneo tras cambios de rutas y validar las respuestas. Responsables por rol: Backend y QA; revisión en el siguiente ciclo de pruebas.

El comando CI del plan OpenAPI está versionado en [ci.yml](../../../.github/workflows/ci.yml) y [zap-openapi-ci.yaml](../../../zap-openapi-ci.yaml). El comando exacto de la ejecución histórica de baseline no quedó identificado en los reportes originales: no se presenta una reconstrucción como comando ejecutado.

El [complemento de CI](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584) produjo un [PDF de dos páginas](../../../reports/dast/reporte-dast-SecurePipeline.pdf) y una [captura del HTML nativo](../../../reports/dast/zap-dashboard.png). La captura se volvió a renderizar desde el informe real; no representa un nuevo escaneo. El informe se acompaña del JSON original.