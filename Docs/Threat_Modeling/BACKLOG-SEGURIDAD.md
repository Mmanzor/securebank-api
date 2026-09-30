# Backlog de Security Stories — SecureBank API

Priorización derivada del Threat Model de la Sesión 03.

| Prioridad | ID | Security story | Criterio de aceptación | Responsable principal | Amenaza |
|---|---|---|---|---|---|
| **P0** | SS-01 | La aplicación debe rechazar toda transferencia cuyo `originAccount` no pertenezca al usuario autenticado. | Si `userId JWT != owner(originAccount)`, responder **403 Forbidden** y registrar el intento. | Vicente Cosio — Code / Build | TM-06 |
| **P0** | SS-02 | Todos los endpoints que reciben un identificador de cuenta o usuario deben validar autorización a nivel de objeto. | Pruebas positivas y negativas demuestran que un cliente no accede a recursos ajenos. | Vicente Cosio — Code / Build | TM-07 |
| **P0** | SS-03 | Ningún secreto debe almacenarse en el código ni en archivos versionados. | Secret scanning pasa sin hallazgos; secretos se cargan desde un gestor seguro. | Franco Pérez — Security Test / CI Security | TM-09 |
| **P0** | SS-04 | Las consultas SQL deben ser parametrizadas. | SAST y pruebas de inyección no detectan concatenación insegura en consultas. | Vicente Cosio — Code / Build | TM-08 |
| **P1** | SS-05 | Toda transferencia debe generar un registro de auditoría trazable. | El log incluye usuario, timestamp, operación, resultado y correlation ID sin exponer secretos. | Catalina Garrido — Deploy / Operate / Monitor | TM-03 |
| **P1** | SS-06 | El login y endpoints sensibles deben resistir fuerza bruta y abuso automatizado. | Rate limiting activo; eventos repetidos generan alerta y no degradan el servicio. | Catalina Garrido — Deploy / Operate / Monitor | TM-01 / TM-05 |
| **P1** | SS-07 | Los JWT deben validarse completamente antes de aceptar una solicitud. | Firma, algoritmo, expiración, issuer y audience son validados; tokens inválidos reciben 401. | Marcela Manzor — Test / Release | TM-02 |
| **P1** | SS-08 | El contenedor debe ejecutarse sin privilegios de root. | El Dockerfile define usuario no-root y el escaneo de imagen no reporta ejecución privilegiada. | Catalina Garrido — Deploy / Operate / Monitor | TM-10 |
| **P2** | SS-09 | El build debe controlar dependencias vulnerables. | SCA genera reporte/SBOM y bloquea vulnerabilidades sobre el umbral acordado. | Franco Pérez — Security Test / CI Security | TM-11 |
| **P2** | SS-10 | La release debe ser trazable y verificable. | PR aprobado, checks exitosos, tag/artefacto firmado y vínculo al cambio entregado. | Marcela Manzor — Test / Release | TM-12 |
| **P2** | SS-11 | Las respuestas y logs deben minimizar información sensible. | Pruebas verifican ausencia de credenciales/tokens/datos innecesarios en logs y respuestas. | Marcela Manzor — Test / Release | TM-04 |

## Criterio de prioridad

- **P0:** riesgo crítico para autorización, integridad o secretos; debe resolverse antes de continuar con el pipeline.
- **P1:** controles necesarios antes de una release funcional.
- **P2:** endurecimiento y trazabilidad que debe quedar integrado al pipeline y proceso de release.

## Dueño del backlog

La priorización es responsabilidad de **Arquitectura y Planificación**, con validación de los responsables de Code/Build, Test/Release, Deploy/Operate/Monitor y Security Test/CI Security.
