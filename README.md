# SecureBank API - Proyecto DevSecOps

[![SecureBank API · CI v1.0](https://github.com/Mmanzor/securebank-api/actions/workflows/ci.yml/badge.svg)](https://github.com/Mmanzor/securebank-api/actions/workflows/ci.yml)

Proyecto transversal **SecurePipeline** de la asignatura Sistemas Automatizados DevSecOps.

## Equipo

- Matías Sepúlveda — Arquitectura y Planificación (**Plan**)
- Vicente Cosio — Desarrollo y Calidad (**Code / Build**)
- Marcela Manzor — Pruebas y Aprobación (**Test / Release**)
- Catalina Garrido — Despliegue y Operaciones (**Deploy / Operate / Monitor**)

## Entregas documentadas

- **Sesión 01:** `Docs/Ciclo_Trabajo/` — ciclo DevSecOps y distribución de responsabilidades.
- **Sesión 02:** `Docs/POL-REPO-001.md` — política de repositorios seguros.
- **Sesión 03:** `Docs/Threat_Modeling/` — DFD, STRIDE, controles y security stories.
- **Sesión 04:** `Docs/Pipeline_CI/` — arquitectura CI v1.0 y análisis del pipeline inseguro.

## Pipeline CI v1.0

El workflow `.github/workflows/ci.yml` se ejecuta en pushes a `main` y `feature/**`, y en Pull Requests hacia `main`.

Flujo:

`checkout → install → build → unit tests → artifact`

El build genera `dist/` y GitHub Actions lo publica como artefacto nombrado con el SHA del commit, con retención de 7 días.

> La seguridad es responsabilidad compartida durante todo el SDLC. Las categorías del equipo indican el foco principal de cada integrante.
