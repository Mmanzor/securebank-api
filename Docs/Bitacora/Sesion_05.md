# Bitácora — Sesión 05: SAST (Static Application Security Testing)

**Asignatura:** Sistemas Automatizados DevSecOps\
**Universidad:** Universidad Bernardo O'Higgins\
**Proyecto:** SecurePipeline — SecureBank API\
**Repositorio:** https://github.com/Mmanzor/securebank-api\
**Rama de trabajo:** `feat/sesiones-05-10`\
**Fecha de implementación:** 19 de noviembre de 2026

## 1. Objetivo de la sesión

Implementar análisis estático de seguridad (SAST) mediante Semgrep en el pipeline de integración continua de SecureBank API, permitiendo detectar vulnerabilidades y configuraciones inseguras antes de integrar cambios a la rama principal.

## 2. Actividades realizadas

### 2.1 Revisión del pipeline existente

Se revisó el archivo `.github/workflows/ci.yml`, que contenía las etapas de instalación de dependencias, compilación, pruebas unitarias y publicación de artefactos.

Se mantuvo el job `build-test` y se agregó soporte para ejecutar el workflow desde ramas `feat/**`.

### 2.2 Integración de Semgrep

Se incorporó un job independiente llamado `sast`, encargado de ejecutar Semgrep en GitHub Actions.

El análisis se configuró mediante el siguiente comando:

```bash
semgrep scan --config auto --error --json --output semgrep-report.json
```

Se configuró también la publicación del archivo `semgrep-report.json` como artefacto para conservar evidencia del análisis.

### 2.3 Primera ejecución y hallazgos

La primera ejecución del pipeline detectó seis hallazgos bloqueantes asociados a la regla `github-actions-mutable-action-tag`.

Los hallazgos estaban relacionados con referencias de GitHub Actions mediante etiquetas de versión modificables, como `@v4` y `@v5`.

**Resultados de la primera ejecución:**

- Archivos analizados: 17.
- Reglas ejecutadas: 242.
- Hallazgos bloqueantes: 6.
- Estado del job SAST: fallido por hallazgos de seguridad.

### 2.4 Corrección de vulnerabilidades

Se reemplazaron las seis referencias modificables de GitHub Actions por identificadores SHA completos de 40 caracteres.

Las acciones corregidas fueron:

- `actions/checkout`
- `actions/setup-node`
- `actions/setup-python`
- `actions/upload-artifact`

Esta modificación permite fijar las acciones a versiones específicas, reduciendo el riesgo de cambios inesperados en dependencias del pipeline.

### 2.5 Segunda ejecución

Después de aplicar las correcciones, se ejecutó nuevamente GitHub Actions.

**Resultados observados:**

- Job `build-test`: exitoso.
- Job `SAST - Semgrep`: exitoso.
- Estado general del workflow: exitoso.

La ejecución confirma que el análisis SAST se completó sin provocar el bloqueo del pipeline. El registro de la segunda ejecución confirmó 0 hallazgos, incluidos 0 bloqueantes, al ejecutar 242 reglas sobre 17 archivos.

## 3. Dificultades encontradas

Durante la implementación se presentaron dificultades relacionadas con la indentación YAML del nuevo job `sast`.

Se corrigió la estructura para ubicar `sast` al mismo nivel que `build-test`, dentro de `jobs`.

Posteriormente, Semgrep detectó seis referencias modificables en el workflow. Estas fueron corregidas mediante identificadores SHA completos y validadas con una segunda ejecución exitosa.

## 4. Evidencias y trazabilidad

**Commits:**

- `8f06088` — Integración inicial de Semgrep al pipeline CI.
- `02aa462` — Corrección de referencias de GitHub Actions mediante SHA.

**Ejecuciones:**

- Primera ejecución (6 hallazgos): https://github.com/Mmanzor/securebank-api/actions/runs/44609621715
- Segunda ejecución (exitosa): https://github.com/Mmanzor/securebank-api/actions/runs/44611602673

**Artefactos:**

- `semgrep-report.json` de la primera ejecución.
- [Reporte de la segunda ejecución](https://github.com/Mmanzor/securebank-api/actions/runs/44611602673/artifacts/14571598191).

## 5. Conclusión

Se integró Semgrep al pipeline CI/CD de SecureBank API, permitiendo automatizar el análisis estático de seguridad.

La primera ejecución identificó seis configuraciones inseguras relacionadas con referencias modificables de GitHub Actions. Tras corregirlas, se obtuvo una ejecución exitosa de los jobs de compilación, pruebas y análisis SAST.

Esta implementación constituye la base para incorporar posteriormente SCA, análisis de secretos, DAST y políticas automatizadas de seguridad.
