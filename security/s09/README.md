# Sesión 9 · Security Policy v1.0 de SecureBank API

OPA recibe un reporte consolidado y aplica la política versionada en `security-policy-v1.rego`.
El resultado registra si el cambio puede avanzar y todos los motivos del bloqueo.

| Control | Umbral | Justificación |
| --- | --- | --- |
| Hallazgos críticos | 0 | Se corrigen antes de promover el cambio por su impacto potencial. |
| Hallazgos altos | Hasta 2 en total | Admite una cantidad acotada de hallazgos para su revisión. Incluye los CVE altos de SCA. |
| Hallazgos medios | Hasta 10 en total | Limita la acumulación de hallazgos durante el desarrollo. |
| Exposición pública | Hasta 5 hallazgos medios | Un servicio accesible desde Internet tiene mayor exposición. Este límite se aplica junto al general. |
| Secretos detectados | 0 | Un secreto en el repositorio puede dar acceso a servicios o datos. |
| Cobertura | Al menos 80 % | Los cambios deben conservar una base de pruebas automatizadas. |

## Entrada del gate

`findings.json` incluye los conteos `critical`, `high` y `medium` de SAST, SCA y DAST.
La política suma los conteos por severidad. También recibe `secrets.count`,
`coverage.percent` y `exposure` (`internal` o `public`). Un conteo debe ser un
entero no negativo. Un reporte faltante o inválido bloquea el cambio.

El consolidado usa Semgrep JSON, Trivy JSON v2, ZAP Traditional JSON,
Gitleaks JSON y un resumen Istanbul (por ejemplo, `coverage-summary.json`
de c8 con el reporter `json-summary`). Las etiquetas históricas de Semgrep
`ERROR` y `WARNING` se interpretan como alta y media. En ZAP se cuenta una
alerta por regla y sitio. Usa reportes del mismo commit y redacta los secretos detectados al exportar Gitleaks. Conserva los reportes redactados
como evidencia en el CI y conserva únicamente los conteos para evaluar.

```bash
python3 security/s09/consolidate.py \
  --semgrep semgrep.json --trivy trivy.json --zap zap.json \
  --gitleaks gitleaks.json --coverage coverage-summary.json --exposure public \
  > findings.json &&
  bash security/s09/evaluate.sh findings.json
```

El CI base compila y ejecuta pruebas unitarias. La API de este repositorio
exporta funciones de Node.js y aún carece de un servicio HTTP para el que
generar un reporte DAST. Los JSON de `fixtures/` son datos de prueba.
El workflow de esta sesión valida la política con esos casos. Para usar el
gate como requisito de promoción, primero deben existir los jobs que producen
los reportes completos y el job de promoción debe depender de su resultado.

## Evidencia reproducible

Con Python 3, OPA 1.4.2 y jq instalados, ejecutar desde la raíz del repo:

```bash
python3 -B -m unittest discover -s security/s09
opa test --verbose security/s09
bash security/s09/evaluate.sh security/s09/fixtures/pass/findings.json
bash security/s09/evaluate.sh security/s09/fixtures/block/findings.json
```

El caso verde tiene 2 hallazgos altos, 5 medios en un servicio público y 80 % de
cobertura. El gate devuelve `allow: true` y código de salida 0. El caso rojo
tiene 1 crítico, 3 altos, 6 medios en un servicio público y 79 % de cobertura.
El gate devuelve `allow: false`, enumera los cuatro motivos y termina con código 1.

GitHub Actions ejecuta las pruebas y conserva ambos resultados como artefacto
de la ejecución asociada al commit.
