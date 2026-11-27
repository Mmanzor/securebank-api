# Evidencias DevSecOps archivadas

Los informes se conservan sin alterar las salidas de las herramientas. SHA256SUMS permite verificar los archivos. Las rutas de origen se indican en esta tabla.

| Evidencia | Fuente |
|---|---|
| [SARIF antes/después](sast/) | [Run 45944833584](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584/artifacts/15173674280), Semgrep 1.187.0, commits históricos |
| [SBOM SPDX](securebank-sbom.spdx.json), [auditoría](securebank-vulns.json), [decisión](securebank-vulns.md) | [Run 45944833584](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584/artifacts/15173863716) |
| [Gitleaks](secrets/) | [Control verde](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584/artifacts/15173888548) y [bloqueo real esperado](https://github.com/Mmanzor/securebank-api/actions/runs/45944913434/artifacts/15174656474) |
| [DAST](dast/) | [PDF y JSON](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584/artifacts/15174516011); el JSON del baseline procede del informe archivado en Docs |
| [IaC](iac/) | [PDF y captura](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584/artifacts/15174516011) y [reportes nativos Checkov](https://github.com/Mmanzor/securebank-api/actions/runs/45727010153/artifacts/15074019156) |

Los escaneos y la infraestructura simulada corresponden a un entorno académico. La evidencia no constituye certificación de seguridad productiva.