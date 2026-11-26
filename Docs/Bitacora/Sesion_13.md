# Bitácora · Sesión 13 — Seguridad de la cadena de suministro

**Proyecto:** SecurePipeline · SecureBank API\
**Rama:** `feature/supply-chain-s13`

## Objetivo

Verificar la identidad, integridad e inventario de la imagen antes de autorizar su despliegue.

## Actividades

- Construimos `securebank:v1` y registramos el digest SHA-256 en el pipeline. Publicamos la imagen en un registro OCI temporal del laboratorio.
- Syft generó el SBOM CycloneDX de 2.517 componentes. Cosign firmó el digest mediante OIDC de GitHub Actions y adjuntó el SBOM como atestación.
- Exigimos que la firma corresponda al workflow esperado, que tenga evidencia en Rekor y que la atestación coincida con el SBOM y el digest. En Kind, la política de admisión usó el digest aprobado por esa verificación.

## Resultados y evidencias

- Sin firma, Cosign bloqueó staging. [Caso bloqueado](https://github.com/Mmanzor/securebank-api/actions/runs/45729834629).
- Con firma y atestación válidas, staging quedó habilitado. Kind rechazó un Pod que usaba el tag y la API admitida respondió HTTP 200. [Caso aprobado](https://github.com/Mmanzor/securebank-api/actions/runs/45729941786).
- [Análisis del caso](../../security/s13/ANALISIS.md) · [Prueba de verificación y Rekor](https://github.com/Mmanzor/securebank-api/actions/runs/45729941786/artifacts/15076461872) · [PR #8](https://github.com/Mmanzor/securebank-api/pull/8).

## Conclusión

El despliegue del laboratorio solo recibe el digest aprobado por el gate. La firma y el SBOM permiten comprobar qué artefacto se admitió y vincularlo con su ejecución de origen.
