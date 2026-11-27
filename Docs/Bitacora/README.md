# Bitácora DevSecOps · Sesiones 05 a 13

**Universidad Bernardo O’Higgins** · Sistemas Automatizados DevSecOps\
**Proyecto:** SecurePipeline · SecureBank API

Esta bitácora reúne los objetivos, cambios, pruebas y resultados del
laboratorio. Cada entrada enlaza su implementación, la ejecución que
respalda el resultado o ambas.

| Sesión | Tema | Resultado registrado |
| --- | --- | --- |
| [05](Sesion_05.md) | SAST con Semgrep | De 6 hallazgos bloqueantes a 0 después de fijar las referencias de GitHub Actions. |
| [06](Sesion_06.md) | SCA con Trivy y SBOM | El job de Trivy pasó y publicó los reportes tras corregir la descarga. |
| [07](Sesion_07.md) | Gestión de secretos | Gitleaks bloqueó un caso de prueba y el pipeline final pasó. |
| [08](Sesion_08.md) | DAST con OWASP ZAP | Pipeline exitoso y verificación de autorización documentada. |
| [09](Sesion_09.md) | Security Quality Gate | OPA bloqueó la cobertura insuficiente y permitió generar el candidato cuando se cumplió la política. |
| [10](Sesion_10.md) | Seguridad Docker | La imagen pasó de 441,6 MB a 76,0 MB y de 3 hallazgos críticos a 0. |
| [11](Sesion_11.md) | Seguridad IaC con Checkov | Security Score de 82,16 % a 94,05 %. Plan y aplicación simulados. |
| [12](Sesion_12.md) | Kubernetes endurecido | Dos réplicas listas, Secret cifrado y rechazo de una solicitud de Pod como root. |
| [13](Sesion_13.md) | Cadena de suministro | SBOM de 2.517 componentes, verificación de Cosign y despliegue por digest en Kind. |

## Trazabilidad de la integración

La implementación original de las sesiones 05 a 08 está en el
[PR #3](https://github.com/Mmanzor/securebank-api/pull/3), con las bitácoras
originales del equipo en `feat/sesiones-05-10`. Las sesiones 09 a 13 se
trabajaron en ramas encadenadas para revisión. La documentación de cada
sesión indica su rama y conserva enlaces a las evidencias del laboratorio.

## Complementos de revisión

[Índice de entregables y alcance](REVISION-ENTREGABLES.md) · [Sesión 01: activos y amenazas](../Ciclo_Trabajo/ACTIVOS-AMENAZAS.md) · [S05: clasificación OWASP](Sesion_05_Anexo.md) · [S06: política CVSS](Sesion_06_Anexo.md) · [S07: procedimiento de secretos](../SECRETS.md).

[S08: tabla, mitigación y JSON original](../Evidencias/Sesion_08/ENTREGA.md) · [S11: informe de auditoría](Sesion_11_Informe.md) · [Workflow complementario](../../.github/workflows/complementos-devsecops.yml).
El [workflow complementario exitoso](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584) reprodujo SAST (6 → 0), generó SPDX y auditoría, validó detección de secretos y publicó ambos PDF. Los archivos se conservan en [reports](../../reports/), con sumas SHA-256 y trazabilidad.
