# Sesión 05 · Clasificación SAST y alcance de la corrección

El análisis histórico de Semgrep encontró seis referencias mutables en GitHub Actions. La corrección fijó las referencias a SHA completos. No se confunden estos hallazgos con los cinco defectos del escenario docente.

| Caso de la consigna | OWASP / severidad docente | Evaluación de la base disponible | Patrón seguro para una implementación futura |
|---|---|---|---|
| SQL Injection en login | A03 / crítica | No existe endpoint login ni acceso SQL en el servidor de laboratorio | Consultas parametrizadas |
| Command Injection en exportador | A03 / crítica | No existe exportador de reportes en la API | Ejecutable conocido y argumentos separados |
| XSS en bienvenida | A03 / alta | El servidor responde JSON, sin plantilla HTML | Codificar salida según contexto |
| MD5 en contraseñas | A02 / alta | No hay almacenamiento de contraseñas; tokens ficticios de laboratorio | Hash de contraseña robusto con sal y parámetros adecuados |
| eval en cálculo | A03 / crítica | No existe calculadora de tasas ni eval en las rutas del servidor | Validación y operaciones explícitas |

Los seis hallazgos reales correspondieron a una debilidad de integridad de la cadena de suministro (OWASP A08:2021 como categoría de referencia; no se afirma que fueran seis vulnerabilidades de la API). La severidad original se conserva como bloqueante según la bitácora histórica.

- [Commit inicial](https://github.com/Mmanzor/securebank-api/commit/8f06088847edd2b313b74f10296e7b12550b1347).
- [Commit de corrección](https://github.com/Mmanzor/securebank-api/commit/02aa4626a8dff8a564351dd00914326d3779dcb6).
- [Diff exacto](https://github.com/Mmanzor/securebank-api/compare/8f06088...02aa462).
- [Run inicial](https://github.com/Mmanzor/securebank-api/actions/runs/44609621715) y [run posterior](https://github.com/Mmanzor/securebank-api/actions/runs/44611602673).

El artefacto original ya no aparece en la consulta de artefactos de esos runs. Una reproducción posterior debe identificar las revisiones, fecha, versión de Semgrep y reglas; los conteos no tienen por qué coincidir con los históricos. No se convierten resultados narrados en SARIF ficticios.

## Reproducción del 27/11/2026

Semgrep 1.187.0, con reglas auto y los dos commits históricos, reprodujo 6 hallazgos iniciales y 0 finales. Se conservan [sast-before.sarif](../../reports/sast/sast-before.sarif), [sast-after.sarif](../../reports/sast/sast-after.sarif) y [revisiones.txt](../../reports/sast/revisiones.txt). [Run exitoso](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584). La versión 1.145.0 del primer intento no inició por incompatibilidad con Pydantic; se reemplazó por 1.187.0, validada en el CI original.
