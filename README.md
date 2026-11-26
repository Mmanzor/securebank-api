# SecureBank API - Proyecto DevSecOps

[![SecureBank API · CI v1.0](https://github.com/Mmanzor/securebank-api/actions/workflows/ci.yml/badge.svg)](https://github.com/Mmanzor/securebank-api/actions/workflows/ci.yml)

Proyecto transversal **SecurePipeline** de la asignatura Sistemas Automatizados DevSecOps.

## Equipo

- Matías Sepúlveda — Arquitectura y Planificación (**Plan**)
- Vicente Cosio — Desarrollo y Calidad (**Code / Build**)
- Marcela Manzor — Pruebas y Aprobación (**Test / Release**)
- Franco Pérez (**@DonnyA32**) — Seguridad del Pipeline (**Security Test / CI Security**)

## Entregas documentadas

[Bitácora de las sesiones 05 a 13](Docs/Bitacora/README.md).

- **Sesión 01:** `Docs/Ciclo_Trabajo/` — ciclo DevSecOps y distribución de responsabilidades.
- **Sesión 02:** `Docs/POL-REPO-001.md` — política de repositorios seguros.
- **Sesión 03:** `Docs/Threat_Modeling/` — DFD, STRIDE, controles y security stories.
- **Sesión 04:** `Docs/Pipeline_CI/` — arquitectura CI v1.0 y análisis del pipeline inseguro.
- **Sesión 09:** [Security Policy v1.0](security/s09/README.md) — política, consolidación de reportes y pruebas del gate.
- **Sesión 10:** [Seguridad de contenedores y Docker](docker/REPORT.md) — comparación de imágenes y resultados de Trivy.
- **Sesión 11:** [Seguridad de infraestructura como código](terraform/README.md) — Terraform, Checkov y evidencia del gate.
- **Sesión 12:** [Kubernetes y seguridad cloud-native](k8s/README.md) — Deployment endurecido y evidencia en Kind.
- **Sesión 13:** [Seguridad de la cadena de suministro](security/s13/ANALISIS.md) — SBOM, Cosign, Rekor y admisión por digest.

## Pipeline CI v1.0

El workflow `.github/workflows/ci.yml` se ejecuta en pushes a `main` y `feature/**`, y en Pull Requests hacia `main`.

Flujo:

`checkout → install → build → unit tests → artifact`

El build genera `dist/` y GitHub Actions lo publica como artefacto nombrado con el SHA del commit, con retención de 7 días.

Franco Pérez queda a cargo de la **revisión de seguridad del pipeline CI**, incluyendo permisos del workflow, dependencias reproducibles y preparación del futuro job `security-test` de SAST.

> La seguridad es responsabilidad compartida durante todo el SDLC. Las categorías del equipo indican el foco principal de cada integrante.
