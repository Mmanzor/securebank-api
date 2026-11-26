# Bitácora — Sesión 06: SCA, CVE y SBOM

**Asignatura:** Sistemas Automatizados DevSecOps\
**Universidad:** Universidad Bernardo O'Higgins\
**Proyecto:** SecurePipeline — SecureBank API\
**Repositorio:** https://github.com/Mmanzor/securebank-api\
**Rama de trabajo:** `feat/sesiones-05-10`\
**Fecha de implementación:** 19 de noviembre de 2026

## 1. Objetivo de la sesión

Implementar un proceso automatizado de análisis de composición de software (SCA) mediante Trivy, con el propósito de identificar vulnerabilidades conocidas en las dependencias del proyecto y generar un inventario de componentes de software (SBOM) en formato CycloneDX.

## 2. Actividades realizadas

### 2.1 Revisión de dependencias

Se analizaron los archivos `package.json` y `package-lock.json` del proyecto SecureBank API.

Se comprobó que el proyecto utiliza Node.js y no declara dependencias externas de npm.

El archivo `package-lock.json` utiliza la versión 3 del formato de bloqueo de dependencias.

Esta revisión permitió establecer una línea base para el análisis de componentes.

### 2.2 Integración de Trivy

Se modificó el archivo `.github/workflows/ci.yml` para incorporar un tercer job denominado `sca`.

El pipeline quedó organizado en tres jobs:

- `build-test`: compilación y pruebas unitarias.
- `sast`: análisis estático de seguridad mediante Semgrep.
- `sca`: análisis de composición de software mediante Trivy.

Se configuró Trivy para analizar el sistema de archivos del repositorio y generar reportes automatizados.

### 2.3 Configuración del escaneo de vulnerabilidades

Se incorporó el siguiente comando:

```bash
trivy fs --scanners vuln --severity HIGH,CRITICAL --format json --output trivy-report.json --exit-code 1 .
```

Este comando permite identificar vulnerabilidades conocidas clasificadas con severidad HIGH o CRITICAL.

La opción `--exit-code 1` permite bloquear el job cuando Trivy reporta vulnerabilidades que cumplen los criterios configurados.

### 2.4 Generación del SBOM

Se configuró la generación de un Software Bill of Materials mediante:

```bash
trivy fs --format cyclonedx --output sbom.cdx.json .
```

El SBOM permite documentar los componentes identificados durante el análisis.

Se utilizó el formato CycloneDX 1.7.

### 2.5 Publicación de artefactos

Se configuró GitHub Actions para publicar los reportes generados mediante el artefacto:

`sca-trivy-reports`

El artefacto contiene:

- `trivy-report.json`: resultados del análisis de vulnerabilidades.
- `sbom.cdx.json`: inventario de componentes en formato CycloneDX.

Se configuró una retención de siete días para los artefactos.

## 3. Dificultades encontradas

### 3.1 Error de instalación de Trivy

Durante la primera ejecución, el job `SCA - Trivy` falló al intentar descargar el ejecutable de Trivy.

GitHub Actions mostró el siguiente mensaje:

```text
curl: (22) The requested URL returned error: 404
Error: Process completed with exit code 22.
```

Como consecuencia, el ejecutable no quedó instalado y la generación del SBOM también falló:

```text
trivy: command not found
Error: Process completed with exit code 127.
```

### 3.2 Diagnóstico del error

Se incorporaron mensajes de diagnóstico para identificar qué descarga estaba fallando.

Los registros permitieron confirmar que el error HTTP 404 ocurría durante la descarga del ejecutable de Trivy, antes de intentar descargar el archivo de checksums.

### 3.3 Corrección aplicada

Se actualizó la versión configurada de Trivy desde `0.58.2` a `0.76.2`.

Se mantuvo el procedimiento de descarga y comprobación de integridad mediante SHA-256.

Después de aplicar la corrección, la instalación de Trivy y el job de SCA finalizaron correctamente.

## 4. Resultados y evidencias

- El escaneo con umbral HIGH/CRITICAL terminó sin bloquear el job. El registro informó `num=0` archivos específicos de lenguajes para el análisis. Esto describe el alcance del escaneo en ese commit.
- Se publicaron el reporte de vulnerabilidades y el inventario CycloneDX. El job de inventario y el escaneo de vulnerabilidades son pasos distintos.
- [Ejecución de la corrección](https://github.com/Mmanzor/securebank-api/actions/runs/44623022636) · [Artefacto de Trivy y SBOM](https://github.com/Mmanzor/securebank-api/actions/runs/44623022636/artifacts/14579130708).

## 5. Conclusión

El pipeline quedó configurado para analizar la composición del repositorio y conservar un inventario de componentes. Los resultados corresponden al sistema de archivos del proyecto y al alcance que Trivy reconoció en ese commit.
