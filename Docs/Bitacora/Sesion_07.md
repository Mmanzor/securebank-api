# Sesión 07 — Gestión de secretos con Gitleaks

**Proyecto:** SecureBank API\
**Asignatura:** DevSecOps\
**Responsable:** Matías Sepúlveda\
**Rama:** `feat/sesiones-05-10`\
**Estado:** Implementación y validación exitosa

## 1. Objetivo

Implementar mecanismos de detección de secretos y credenciales expuestas en el repositorio, integrando Gitleaks en el entorno local, mediante un hook de pre-commit y en el pipeline de integración continua de GitHub Actions.

## 2. Herramientas utilizadas

- Git y GitHub
- Visual Studio Code
- Gitleaks 8.30.1
- GitHub Actions
- PowerShell
- Archivo de configuración `.gitleaks.toml`
- Hook `.githooks/pre-commit`

## 3. Actividades realizadas

### 3.1. Instalación y configuración de Gitleaks

Se instaló Gitleaks mediante Windows Package Manager (`winget`) y se verificó su funcionamiento utilizando la versión 8.30.1.

Se configuró el archivo `.gitleaks.toml` para mantener las reglas predeterminadas y establecer exclusiones para directorios generados, como `node_modules`, `dist` y `coverage`.

### 3.2. Análisis de archivos locales

Se ejecutó el siguiente comando:

```powershell
gitleaks dir --config .gitleaks.toml --redact --exit-code 1 .
```

**Resultado:** `no leaks found`.

El análisis no detectó secretos según las reglas configuradas.

### 3.3. Análisis del historial Git

Se ejecutó:

```powershell
gitleaks git --config .gitleaks.toml --redact --exit-code 1 .
```

**Resultados:**
- 59 commits analizados.
- Aproximadamente 72,99 KB examinados.
- Ningún secreto detectado.

### 3.4. Implementación del hook pre-commit

Se creó el archivo `.githooks/pre-commit` para ejecutar Gitleaks antes de los commits.

La ruta de hooks se configuró mediante:

```powershell
git config --local core.hooksPath .githooks
```

Se verificó su ejecución manual y posteriormente durante un commit real.

**Resultado:** ejecución automática exitosa, sin secretos detectados.

### 3.5. Prueba controlada de detección y bloqueo

Se creó temporalmente el archivo `prueba-secreto.env` con una contraseña ficticia y se agregó una regla personalizada de prueba a `.gitleaks.toml`.

Durante el análisis se obtuvo:

```text
WRN leaks found: 1
```

Posteriormente, al ejecutar el hook:

```powershell
git hook run pre-commit
```

Se obtuvo:

```text
ERROR: Se detectaron posibles secretos. Commit bloqueado.
```

Esto permitió comprobar que el hook devuelve un error cuando Gitleaks detecta un secreto.

Una vez terminada la prueba, se eliminó el archivo temporal y la regla de prueba.

**Verificación posterior:** `no leaks found`.

### 3.6. Integración en GitHub Actions

Se modificó `.github/workflows/ci.yml` para incorporar el job de detección de secretos con Gitleaks.

Se configuró su ejecución antes de los demás jobs, utilizando dependencias `needs` para condicionar la ejecución de las etapas posteriores.

El pipeline quedó compuesto por:

1. Secret Scan — Gitleaks.
2. build-test.
3. SAST — Semgrep.
4. SCA — Trivy.

## 4. Evidencias y resultados

**Commit de implementación:** `0fb8438`

**Ejecución exitosa:** [GitHub Actions #37](https://github.com/Mmanzor/securebank-api/actions/runs/44631144440)

| Job | Resultado | Duración |
|---|---|---|
| Secret Scan — Gitleaks | Exitoso | 10 s |
| build-test | Exitoso | 9 s |
| SAST — Semgrep | Exitoso | 26 s |
| SCA — Trivy | Exitoso | 13 s |

**Duración total del workflow:** 45 segundos.

**Artefactos generados:** 3.

La ejecución confirmó que los cuatro jobs finalizaron correctamente y que el análisis de secretos se ejecutó antes de las etapas posteriores.

## 5. Observaciones

- Gitleaks no detectó secretos durante los análisis finales del repositorio.
- La prueba controlada confirmó que una regla personalizada puede detectar una credencial ficticia.
- El hook se ejecutó correctamente durante un commit real.
- El pipeline de GitHub Actions terminó exitosamente.
- Se observaron advertencias sobre el uso de Node.js 20 en algunas acciones de GitHub, sin afectar el resultado del workflow.
- La configuración local del hook debe habilitarse individualmente en cada clon del repositorio.

## 6. Conclusión

Durante la sesión 07 se implementó y validó un mecanismo de detección de secretos para SecureBank API mediante Gitleaks.

La integración permite analizar archivos locales, examinar el historial Git y ejecutar verificaciones automáticas antes de los commits y durante la integración continua.

Las pruebas demostraron que el mecanismo detecta patrones de secretos configurados y puede impedir la creación de commits cuando se identifican posibles credenciales expuestas.

La ejecución exitosa del pipeline confirma la incorporación de este control de seguridad al proceso DevSecOps del proyecto.
