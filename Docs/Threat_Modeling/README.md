# Sesión 03 — Threat Modeling y Requisitos de Seguridad

**Proyecto:** SecurePipeline — SecureBank API  
**Asignatura:** Sistemas Automatizados DevSecOps  
**Equipo:** Matías Sepúlveda, Vicente Cosio, Marcela Manzor, Catalina Garrido y Franco Pérez.

Esta carpeta contiene el entregable de la Sesión 03. Se mantiene la organización de responsabilidades definida en la Sesión 01 y la política de repositorios seguros documentada en `Docs/POL-REPO-001.md`.

## Distribución de responsabilidades del equipo

| Integrante | Categoría / fase principal | Responsabilidad en este entregable |
|---|---|---|
| **Matías Sepúlveda** | **Arquitectura y Planificación (Plan)** | DFD, trust boundaries, modelado de amenazas y requisitos de seguridad. |
| **Vicente Cosio** | **Desarrollo y Calidad (Code / Build)** | Desarrollo seguro, validación de código, build y correcciones de implementación. | **Marcela Manzor** | **Pruebas y Aprobación (Test / Release)** | Pruebas de autorización/DAST, criterios de aceptación, trazabilidad de hallazgos y controles de release. |
| **Catalina Garrido** | **Despliegue y Operaciones (Deploy / Operate / Monitor)** | IaC scanning, hardening, gestión de secretos, logging, monitoreo y respuesta operacional. |
| **Franco Pérez** | **Seguridad del Pipeline (Security Test / CI Security)** | Análisis SAST y SCA, secret scanning, revisión de dependencias y validación de controles de seguridad del pipeline. |

> La seguridad es responsabilidad compartida. La categoría indica el foco principal, no una exclusividad.

## Entregables incluidos

1. [DFD de SecureBank](./DFD-SecureBank.md) con las tres fronteras de confianza.
2. [Threat Model](./THREAT-MODEL.md) con 12 amenazas, clasificación STRIDE, riesgo, control y una security story por amenaza.
3. [Backlog de seguridad](./BACKLOG-SEGURIDAD.md) con historias priorizadas.
4. Fecha de próxima revisión del modelo: **30 de octubre de 2026**.

## Relación con sesiones anteriores

- **Sesión 01:** se conserva el ciclo seguro Plan → Code → Build → Test → Release → Deploy → Operate → Monitor y la distribución de categorías de trabajo del equipo.
- **Sesión 02:** se consideran las reglas de repositorio seguro, revisión por Pull Request, CODEOWNERS, protección de secretos, trazabilidad y control de cambios.
- **Sesión 03:** el análisis se realiza antes de implementar controles del pipeline, usando DFD, trust boundaries, STRIDE y security stories.
