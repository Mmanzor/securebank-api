# POL-REPO-001: Política de Repositorios Seguros

**Proyecto Transversal:** SecurePipeline — SecureBank API[cite: 2]  
**Asignatura:** Sistemas Automatizados / DevSecOps[cite: 2]  
**Organización:** UBO-DevSecOps[cite: 2]  
**Versión:** 1.0[cite: 2]  
**Integrantes del Equipo:**  
* Matías Sepúlveda  
* Vicente Cosio  
* Marcela Manzor  
* Catalina Garrido

---

## 1. Alcance y Objetivos

* **Alcance:** La presente política aplica a todos los repositorios de código fuente productivos y preproductivos de la organización, con foco especial en la plataforma `securebank-api`[cite: 2].
* **Objetivo:** Establecer los controles técnicos, de acceso y de gobernanza mínimos necesarios para proteger el repositorio como activo crítico del negocio, garantizando la trazabilidad, integridad e inmutabilidad del código fuente[cite: 2].

---

## 2. Roles y Responsabilidades

| Rol | Responsabilidades Clave |
|---|---|
| **Developer** | Escribir código seguro, firmar commits con claves GPG/SSH, solucionar hallazgos de SAST/Secret Scanning y trabajar en ramas `feature/*`[cite: 2]. |
| **Code Owner / Reviewer** | Revisar y aprobar o rechazar Pull Requests sobre componentes específicos, velar por la calidad del código y mantener las reglas en `CODEOWNERS`[cite: 2]. |
| **DevOps / Cloud Engineer** | Gestionar los archivos de flujo de trabajo CI/CD (`.github/workflows/`), automatizaciones del pipeline y reglas de infraestructura[cite: 2]. |
| **Release Manager** | Autorizar y generar tags semánticos (`vX.Y.Z`) firmados, validar el inventario SBOM y orquestar despliegues a producción[cite: 2]. |
| **Secret Custodian** | Administrar y auditar el acceso a credenciales, tokens y variables en entornos seguros (Vault / GitHub Secrets)[cite: 2]. |

---

## 3. Matriz "Quién Puede Qué" (Resolución del Desafío)

### Q1: ¿Quién puede hacer merge a ramas protegidas (`main` / `develop`)?
* **Regla General:** El push directo a `main` está **estrictamente prohibido** para todos los miembros, incluidos administradores[cite: 2]. Todo cambio debe ingresar mediante Pull Request (PR)[cite: 2].
* **Condiciones para Merge:**
  1. Mínimo **1 aprobación obligatoria** de un Code Owner[cite: 2].
  2. Aprobación exitosa de los escaneos automáticos del pipeline CI (Tests unitarios, SAST y Secrets Scanning sin fallos)[cite: 2].
  3. No se permite auto-merge en dependencias sin revisión del equipo de seguridad[cite: 2].
* **Excepción para Hotfix urgente:** Se permite la fusión rápida mediante la rama `hotfix/*` que requiera la aprobación rápida de al menos 1 Release Manager o Lead Developer, manteniendo la ejecución previa de las pruebas automáticas del CI[cite: 2].

### Q2: ¿Quién puede modificar los pipelines CI/CD (`.github/workflows/`)?
* **Propiedad Restringida:** La modificación de archivos dentro de `.github/workflows/` requiere la revisión y aprobación explícita de los **Code Owners de DevOps/Seguridad**[cite: 2].
* **Controles:** Bloqueo de ejecuciones de scripts o acciones de GitHub no verificadas[cite: 2]. Los PRs provenientes de un *fork* externo no tendrán acceso a los secretos del entorno de producción sin aprobación previa de ejecución[cite: 2].

### Q3: ¿Quién puede crear releases y etiquetar versiones?
* **Roles Autorizados:** Exclusivo del **Release Manager** o **Lead Developer**[cite: 2].
* **Requisitos Técnicos:**
  * Toda versión requiere un **Tag firmado** con GPG/SSH siguiendo el estándar SemVer (`MAJOR.MINOR.PATCH`)[cite: 2].
  * Generación y adjunto obligatorio del inventario de software (**SBOM**) y la firma del artefacto[cite: 2].
  * Trazabilidad directa de cada release contra un ticket o historia de usuario[cite: 2].

### Q4: ¿Quién puede gestionar y modificar secretos?
* **Custodia de Secretos:** Acceso restringido a un máximo de 2 personas nombradas (*Secret Custodians* / SRE)[cite: 2].
* **Controles:**
  * Separación estricta de variables de entorno entre los entornos de Desarrollo, Staging y Producción[cite: 2].
  * Prohibición total de subir archivos `.env` o credenciales en texto plano al historial[cite: 2].
  * Rotación calendarizada de credenciales y auditoría de accesos[cite: 2].

---

## 4. Matriz de Cobertura de Riesgos vs. Controles Técnicos

| Riesgo Técnico Identificado | Control Técnico Implementado |
|---|---|
| **R.01 Exposure of Secrets:** Claves en texto plano en el repositorio[cite: 2]. | Uso de `.gitignore`, ejecuciones de **Gitleaks/TruffleHog** en cada commit/push y uso de HashiCorp Vault / GitHub Secrets[cite: 2]. |
| **R.02 Malicious Code Modification:** Inyección de puertas traseras[cite: 2]. | **Code Review obligatorio**, asignación por `CODEOWNERS` y ejecuciones de análisis estático (SAST)[cite: 2]. |
| **R.03 Branch Deletion:** Borrado accidental o malicioso de ramas[cite: 2]. | **Branch Protection Rules** en `main`: desactivación de `Allow force pushes` y `Allow deletions`[cite: 2]. |
| **R.04 Unauthorized Commits:** Suplantación de identidad en commits[cite: 2]. | Exigencia de **commits firmados** criptográficamente (GPG/SSH) y **MFA obligatorio** para todos los colaboradores[cite: 2]. |
| **R.05 External Collaborator Risks:** Accesos retenidos por ex-integrantes[cite: 2]. | Principio de mínimo privilegio, revisión trimestral de accesos y *offboarding* inmediato[cite: 2]. |
| **R.06 Hostile Pull Requests:** Workflows maliciosos o dependencias alteradas[cite: 2]. | Bloqueo de acceso a secretos desde PRs de *forks*, resolución obligatoria de conversaciones y revisiones del pipeline[cite: 2]. |
| **R.07 Meta-risk:** Desconfianza en el repositorio[cite: 2]. | Auditoría permanente mediante `git log` inmutable, trazabilidad total de PRs y releases etiquetados[cite: 2]. |

---

## 5. Procedimiento ante Excepciones e Historial de Git

1. **Compromiso Accidental de Secretos:** 
   * Borrar un archivo comprometido mediante un nuevo commit **no elimina el secreto del historial** (el historial de Git es inmutable)[cite: 2].
   * En caso de fuga: 
     1. **Rotar de inmediato la clave/secreto expuesto** (considerándolo comprometido)[cite: 2].
     2. Sanitizar el historial utilizando herramientas como `git filter-repo` o `BFG Repo-Cleaner`[cite: 2].
2. **Revisión de la Política:** Esta política se revisará formalmente al inicio de cada ciclo de desarrollo o de forma semestral[cite: 2].
