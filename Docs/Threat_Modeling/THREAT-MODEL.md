# Threat Model — SecureBank API

**Metodología:** DFD + STRIDE  
**Criterio de riesgo:** Probabilidad × Impacto, usando escala Baja / Media / Alta.  
**Próxima revisión:** 30 de octubre de 2026.

## Registro de amenazas

| ID | Flujo / activo | Amenaza y vulnerabilidad | STRIDE | P | I | Riesgo | Control principal | Security story | Categoría responsable |
|---|---|---|---|---|---|---|---|---|---|
| TM-01 | Login / identidad | Un atacante usa credenciales robadas o fuerza bruta para suplantar a un cliente. Falta de MFA y rate limiting. | **S — Spoofing** | Alta | Alto | **Alto** | MFA, rate limiting, bloqueo progresivo y monitoreo de intentos. | Como sistema, debo exigir MFA y limitar intentos para reducir la suplantación de usuarios. | Deploy / Operate / Monitor |
| TM-02 | JWT / sesión | Manipulación de claims o uso de token con firma/algoritmo no validado. | **T — Tampering** | Media | Alto | **Alto** | Validar firma, algoritmo, expiración, issuer y audience del JWT. | La API debe rechazar todo JWT cuya firma o claims no cumplan la política configurada. | Code / Build |
| TM-03 | Transferencias | Un usuario niega haber realizado una transferencia y no existen logs suficientes. | **R — Repudiation** | Media | Alto | **Alto** | Logs de auditoría con usuario, fecha, cuenta origen/destino, resultado y correlation ID. | Toda transferencia debe generar un registro auditable que permita atribuir la acción al usuario autenticado. | Deploy / Operate / Monitor |
| TM-04 | Datos personales / saldos | Respuestas o logs exponen información financiera innecesaria. | **I — Information Disclosure** | Media | Alto | **Alto** | Minimización de datos, masking, TLS y política de logs sin datos sensibles. | La API debe devolver y registrar solo los datos estrictamente necesarios para la operación. | Test / Release |
| TM-05 | Login / API pública | Bots saturan endpoints con solicitudes masivas y degradan el servicio. | **D — Denial of Service** | Alta | Medio | **Alto** | Rate limiting, límites de payload, timeouts, WAF y alertas. | La API debe limitar solicitudes por cliente/IP y responder de forma controlada ante abuso. | Deploy / Operate / Monitor |
| TM-06 | POST /transfer | BOLA: un cliente indica como `originAccount` una cuenta ajena y el backend confía en el body. | **E — Elevation of Privilege** | Alta | Alto | **Alto** | Extraer `userId` del JWT, consultar dueño y responder 403 si no coincide; registrar intento. | La aplicación debe rechazar toda transferencia cuya cuenta origen no pertenezca al usuario autenticado. | Code / Build |
| TM-07 | Perfil / cuenta | Un atacante cambia el identificador de recurso en la URL o body para acceder a información de otro cliente. | **E — Elevation of Privilege** | Alta | Alto | **Alto** | Autorización a nivel de objeto en cada endpoint (BOLA/IDOR). | Cada consulta de cuenta o perfil debe validar que el recurso pertenece al usuario o que el rol autoriza su acceso. | Code / Build |
| TM-08 | Base de datos | SQL Injection mediante parámetros no sanitizados o consultas concatenadas. | **T — Tampering** | Alta | Alto | **Alto** | Queries parametrizadas, validación de entrada, SAST y pruebas de inyección. | Ninguna consulta SQL debe construirse concatenando directamente datos controlados por el usuario. | Code / Build |
| TM-09 | Secretos / repositorio | Credenciales, tokens o claves quedan expuestos en código, commits o configuración. | **I — Information Disclosure** | Media | Alto | **Alto** | GitHub Secrets/Vault, `.gitignore`, secret scanning y rotación inmediata ante filtración. | Los secretos deben almacenarse fuera del código y el pipeline debe bloquear nuevos secretos detectados. | Security Test / CI Security |
| TM-10 | Contenedor / runtime | El contenedor corre como root; una explotación de la app obtiene privilegios mayores. | **E — Elevation of Privilege** | Media | Alto | **Alto** | Usuario no-root, imagen mínima, capabilities reducidas y escaneo de imagen. | El contenedor de SecureBank debe ejecutarse con un usuario sin privilegios y configuración endurecida. | Deploy / Operate / Monitor |
| TM-11 | Dependencias | Una librería con CVE conocido compromete integridad o confidencialidad. | **T / I** | Media | Alto | **Alto** | SCA, actualización controlada, bloqueo por severidad y SBOM. | El build debe fallar cuando una dependencia supere el umbral de severidad definido. | Security Test / CI Security |
| TM-12 | Pipeline / release | Un cambio malicioso llega a producción sin revisión o se altera un artefacto. | **T / R** | Media | Alto | **Alto** | PR obligatorio, CODEOWNERS, checks, artefactos/tags firmados y trazabilidad de release. | Ningún artefacto debe publicarse sin revisión, checks exitosos y trazabilidad hacia el PR aprobado. | Test / Release |

## Cobertura STRIDE

- **S — Spoofing:** TM-01.
- **T — Tampering:** TM-02, TM-08, TM-11, TM-12.
- **R — Repudiation:** TM-03, TM-12.
- **I — Information Disclosure:** TM-04, TM-09, TM-11.
- **D — Denial of Service:** TM-05.
- **E — Elevation of Privilege:** TM-06, TM-07, TM-10.

## Caso obligatorio: POST /transfer

La API no debe confiar únicamente en `originAccount` recibido en el body. El backend debe:

1. Extraer `userId` desde un JWT válido y firmado.
2. Consultar en base de datos al propietario de `originAccount`.
3. Comparar `userId` con el propietario.
4. Si no coinciden, responder **403 Forbidden**.
5. Registrar el intento en el sistema de auditoría.

Este escenario corresponde principalmente a **Elevation of Privilege** y materializa un problema BOLA si la propiedad del objeto no se valida.

## Participantes y categorías

- **Matías Sepúlveda — Arquitectura y Planificación (Plan):** mantiene DFD, trust boundaries, amenazas y requisitos.
- **Vicente Cosio — Desarrollo y Calidad (Code / Build):** implementa y verifica controles preventivos en código/build.
- **Marcela Manzor — Pruebas y Aprobación (Test / Release):** valida criterios de aceptación, autorización, DAST y trazabilidad de release.
- **Catalina Garrido — Despliegue y Operaciones (Deploy / Operate / Monitor):** aplica hardening, protección operacional, secretos, logging y monitoreo.
- **Franco Pérez (@DonnyA32) — Seguridad del Pipeline (Security Test / CI Security):** revisa SAST/SCA, secret scanning, dependencias y controles de seguridad del pipeline.

La asignación es principal; el modelo sigue el principio DevSecOps de responsabilidad compartida.
