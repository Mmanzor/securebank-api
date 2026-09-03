# POL-REPO-001: Política de Repositorios Seguros

**Proyecto Transversal:** SecurePipeline — SecureBank API  
**Asignatura:** Sistemas Automatizados / DevSecOps  
**Organización:** UBO-DevSecOps  
**Versión:** 1.0  
**Integrantes del Equipo:**  
* Matías Sepúlveda  
* Vicente Cosio  
* Marcela Manzor  
* Catalina  

---

## 1. Alcance y Objetivos

* **Alcance:** La presente política aplica a todos los repositorios de código fuente productivos y preproductivos de la organización, con foco especial en la plataforma `securebank-api`.
* **Objetivo:** Establecer los controles técnicos, de acceso y de gobernanza mínimos necesarios para proteger el repositorio como activo crítico del negocio, garantizando la trazabilidad, integridad e inmutabilidad del código fuente.

---

## 2. Roles y Responsabilidades

| Rol | Responsabilidades Clave |
|---|---|
| **Developer** | Escribir código seguro, firmar commits con claves GPG/SSH, solucionar hallazgos de SAST/Secret Scanning y trabajar en ramas `feature/*`. |
| **Code Owner / Reviewer** | Revisar y aprobar o rechazar Pull Requests sobre componentes específicos, velar por la calidad del código y mantener las reglas en `CODEOWNERS`. |
| **DevOps / Cloud Engineer** | Gestionar los archivos de flujo de trabajo CI/CD (`.github/workflows/`), automatizaciones del pipeline y reglas de infraestructura. |
| **Release Manager** | Autorizar y generar tags semánticos (`vX.Y.Z`) firmados, validar el inventario SBOM y orquestar despliegues a producción. |
| **Secret Custodian** | Administrar y auditar el acceso a credenciales, tokens y variables en entornos seguros (Vault / GitHub Secrets). |

---

## 3. Matriz "Quién Puede Qué" (Resolución del Desafío)

### Q1: ¿Quién puede hacer merge a ramas protegidas (`main` / `develop`)?
* **Regla General:** El push directo a `main` está **estrictamente prohibido** para todos los miembros, incluidos administradores. Todo cambio debe ingresar mediante Pull Request (PR).
* **Condiciones para Merge:**
  1. Mínimo **1 aprobación obligatoria** de un Code Owner.
  2. Aprobación exitosa de los escaneos automáticos del pipeline CI (Tests unitarios, SAST y Secrets Scanning sin fallos).
  3. No se permite auto-merge en dependencias sin revisión del equipo de seguridad.
* **Excepción para Hotfix urgente:** Se permite la fusión rápida mediante la rama `hotfix/*` que requiera la aprobación rápida de al menos 1 Release Manager o Lead Developer, manteniendo la ejecución previa de las pruebas automáticas del CI.

### Q2: ¿Quién puede modificar los pipelines CI/CD (`.github/workflows/`)?
* **Propiedad Restringida:** La modificación de archivos dentro de `.github/workflows/` requiere la revisión y aprobación explícita de los **Code Owners de DevOps/Seguridad**.
* **Controles:** Bloqueo de ejecuciones de scripts o acciones de GitHub no verificadas. Los PRs provenientes de un *fork* externo no tendrán acceso a los secretos del entorno de producción sin aprobación previa de ejecución.

### Q3: ¿Quién puede crear releases y etiquetar versiones?
* **Roles Autorizados:** Exclusivo del **Release Manager** o **Lead Developer**.
* **Requisitos Técnicos:**
  * Toda versión requiere un **Tag firmado** con GPG/SSH siguiendo el estándar SemVer (`MAJOR.MINOR.PATCH`).
  * Generación y adjunto obligatorio del inventario de software (**SBOM**) y la firma del artefacto.
  * Trazabilidad directa de cada release contra un ticket o historia de usuario.

### Q4: ¿Quién puede gestionar y modificar secretos?
* **Custodia de Secretos:** Acceso restringido a un máximo de 2 personas nombradas (*Secret Custodians* / SRE).
* **Controles:**
  * Separación estricta de variables de entorno entre los entornos de Desarrollo, Staging y Producción.
  * Prohibición total de subir archivos `.env` o credenciales en texto plano al historial.
  * Rotación calendarizada de credenciales y auditoría de accesos.

---

## 4. Matriz de Cobertura de Riesgos vs. Controles Técnicos

| Riesgo Técnico Identificado | Control Técnico Implementado |
|---|---|
| **R.01 Exposure of Secrets:** Claves en texto plano en el repositorio. | Uso de `.gitignore`, ejecuciones de **Gitleaks/TruffleHog** en cada commit/push y uso de HashiCorp Vault / GitHub Secrets. |
| **R.02 Malicious Code Modification:** Inyección de puertas traseras. | **Code Review obligatorio**, asignación por `CODEOWNERS` y ejecuciones de análisis estático (SAST). |
| **R.03 Branch Deletion:** Borrado accidental o malicioso de ramas. | **Branch Protection Rules** en `main`: desactivación de `Allow force pushes` y `Allow deletions`. |
| **R.04 Unauthorized Commits:** Suplantación de identidad en commits. | Exigencia de **commits firmados** criptográficamente (GPG/SSH) y **MFA obligatorio** para todos los colaboradores. |
| **R.05 External Collaborator Risks:** Accesos retenidos por ex-integrantes. | Principio de mínimo privilegio, revisión trimestral de accesos y *offboarding* inmediato. |
| **R.06 Hostile Pull Requests:** Workflows maliciosos o dependencias alteradas. | Bloqueo de acceso a secretos desde PRs de *forks*, resolución obligatoria de conversaciones y revisiones del pipeline. |
| **R.07 Meta-risk:** Desconfianza en el repositorio. | Auditoría permanente mediante `git log` inmutable, trazabilidad total de PRs y releases etiquetados. |

---

## 5. Procedimiento ante Excepciones e Historial de Git

1. **Compromiso Accidental de Secretos:** 
   * Borrar un archivo comprometido mediante un nuevo commit **no elimina el secreto del historial** (el historial de Git es inmutable).
   * En caso de fuga: 
     1. **Rotar de inmediato la clave/secreto expuesto** (considerándolo comprometido).
     2. Sanitizar el historial utilizando herramientas como `git filter-repo` o `BFG Repo-Cleaner`.
2. **Revisión de la Política:** Esta política se revisará formalmente al inicio de cada ciclo de desarrollo o de forma semestral.
