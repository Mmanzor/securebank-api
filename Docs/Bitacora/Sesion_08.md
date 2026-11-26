
# Sesión 08 — DAST con OWASP ZAP y pruebas BOLA

## 1. Objetivo

Implementar pruebas dinámicas de seguridad (DAST) sobre SecureBank API utilizando OWASP ZAP, incorporando validaciones de autorización para prevenir vulnerabilidades de tipo Broken Object Level Authorization (BOLA).

## 2. Herramientas utilizadas

- OWASP ZAP ejecutado mediante Docker.
- Docker Desktop para levantar la API localmente.
- Node.js para implementar el servidor HTTP.
- OpenAPI 3.0.3 para documentar los endpoints.
- GitHub Actions para automatizar el análisis.
- Git y GitHub para el control de versiones.

## 3. Implementación

### 3.1 API de laboratorio

Se implementó un servidor HTTP en `src/server.js` con los siguientes endpoints:

- `GET /`: información general del servicio.
- `GET /health`: verificación de disponibilidad.
- `GET /users/{id}`: consulta de usuarios protegida por autorización.

Se incorporaron cabeceras HTTP de seguridad y se utilizó un mecanismo de autenticación simulado mediante tokens ficticios, exclusivamente para fines académicos.

### 3.2 Protección contra BOLA

Se implementó la función `canAccessUser()` para verificar que el usuario autenticado solamente pueda consultar su propio recurso.

Se definieron tres escenarios:

| Escenario | Código esperado |
|---|---|
| Solicitud sin autenticación | 401 Unauthorized |
| Acceso a datos de otro usuario | 403 Forbidden |
| Acceso autorizado a datos propios | 200 OK |

La prueba manual de acceso indebido confirmó la respuesta `403 Forbidden`.

Además, las pruebas automatizadas de Node.js finalizaron con siete pruebas aprobadas.

### 3.3 Escaneo dinámico con OWASP ZAP

Se ejecutó OWASP ZAP mediante Docker para analizar la API en funcionamiento.

Inicialmente se utilizó ZAP Baseline para revisar las respuestas HTTP y sus cabeceras de seguridad.

Posteriormente se incorporó una especificación `openapi.yaml` para importar las rutas de la API.

El archivo `zap-openapi.yaml` permitió automatizar:

1. La importación de endpoints OpenAPI.
2. Las solicitudes HTTP de autorización.
3. La espera del análisis pasivo.
4. La generación de un reporte JSON.

ZAP informó la importación de tres URLs y finalizó el plan de automatización correctamente.

### 3.4 Integración continua

Se incorporó el trabajo `DAST - OWASP ZAP` al archivo `.github/workflows/ci.yml`.

El pipeline construye la imagen Docker de la API, inicia el contenedor, comprueba su disponibilidad y ejecuta el plan de ZAP adaptado al entorno de GitHub Actions.

Finalmente, publica el reporte como artefacto `dast-zap-reports`.

## 4. Resultados

- API ejecutada correctamente mediante Docker.
- Siete pruebas automatizadas de Node.js aprobadas.
- Acceso horizontal no autorizado rechazado con HTTP 403.
- Plan OpenAPI de ZAP ejecutado correctamente.
- Reporte JSON generado en GitHub Actions.
- Cero alertas registradas en el reporte DAST del pipeline.
- Pipeline de GitHub Actions completado exitosamente.

Durante la validación del pipeline, Semgrep detectó tres hallazgos relacionados con enlaces HTTP presentes en un reporte HTML generado por ZAP.

Se incorporó `.semgrepignore` para excluir estos reportes generados del análisis SAST, manteniendo el escaneo del código fuente.

Una nueva ejecución de Semgrep finalizó con cero hallazgos.

## 5. Evidencias

- `Docs/Evidencias/Sesion_08/zap-final.html`
- `Docs/Evidencias/Sesion_08/zap-final.json`
- `Docs/Evidencias/Sesion_08/zap-openapi.json`
- Artefacto `dast-zap-reports` de GitHub Actions.
- Pruebas automatizadas en `tests/index.test.js` y `tests/api.test.js`.
- Configuración de CI en `.github/workflows/ci.yml`.
- [Ejecución final con DAST](https://github.com/Mmanzor/securebank-api/actions/runs/44647102958) y [reportes originales del laboratorio](https://github.com/Mmanzor/securebank-api/tree/3121d97422a440418ddc3d5417619b8cae9515b3/Docs/Evidencias/Sesion_08).

## 6. Limitaciones

La autenticación mediante tokens fijos corresponde únicamente a un laboratorio académico y no debe utilizarse en producción.

El análisis realizado con OpenAPI y ZAP incluye solicitudes HTTP y análisis pasivo. No constituye una evaluación activa exhaustiva de vulnerabilidades.

La ausencia de alertas en el reporte no garantiza que el sistema esté libre de vulnerabilidades.

## 7. Conclusión

Se implementó satisfactoriamente una etapa de análisis dinámico de seguridad para SecureBank API.

La combinación de OWASP ZAP, pruebas de autorización BOLA y GitHub Actions permitió automatizar verificaciones sobre la API en ejecución y conservar evidencias de los resultados.

Esta implementación fortalece el pipeline DevSecOps y proporciona una base para establecer criterios de calidad y seguridad en las siguientes sesiones.
