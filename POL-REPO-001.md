# POL-REPO-001 — Política de Repositorios Seguros
**Versión:** 1.0  
**Proyecto:** SecureBank API  
**Ámbito:** Empresa fintech con 40 desarrolladores distribuidos en 5 equipos, un Lead de Seguridad, un SRE y dos revisores externos.

## 1. Alcance
Esta política aplica a todos los repositorios de código productivo y pre-productivo de la organización. Su objetivo es proteger el código fuente, mantener la trazabilidad de los cambios y reducir riesgos asociados a accesos indebidos, pérdida de historial, exposición de secretos y modificaciones no autorizadas.

## 2. Roles y responsabilidades
- **Developer:** desarrolla funcionalidades en ramas `feature/*` o `hotfix/*`, crea Pull Requests y no realiza push directo a `main`.
- **Reviewer:** revisa cambios antes del merge, verifica calidad, seguridad y cumplimiento de esta política.
- **Code Owner:** responsable de archivos o áreas críticas; su aprobación es obligatoria cuando un PR modifica rutas bajo su responsabilidad.
- **Lead de Seguridad:** aprueba cambios sensibles de seguridad, especialmente en pipelines, secretos y controles del repositorio.
- **SRE:** valida cambios operacionales y del pipeline que puedan afectar despliegues, disponibilidad o producción.
- **Release Manager:** autoriza y publica releases, verificando checklist, trazabilidad y tags firmados.
- **Secret Custodian:** rol limitado a dos personas autorizadas para administrar secretos de producción y su rotación.
- **Revisor externo:** puede revisar PRs asignados, pero no realizar merge, modificar secretos ni publicar releases.

## 3. Reglas técnicas obligatorias
1. MFA obligatorio para todas las cuentas con acceso al repositorio.
2. La rama `main` debe estar protegida y no aceptar push directo, force-push ni eliminación.
3. Todo cambio hacia `main` debe ingresar mediante Pull Request.
4. Cada PR requiere al menos **1 aprobación**; cambios críticos requieren aprobación adicional del Code Owner o Lead de Seguridad.
5. Se deben descartar aprobaciones anteriores cuando exista un nuevo push al PR.
6. Los commits y tags de release deben estar firmados mediante GPG o SSH cuando la plataforma lo permita.
7. Debe existir archivo `CODEOWNERS` para rutas críticas como `.github/workflows/` y componentes sensibles.
8. Se debe ejecutar escaneo de secretos en cada push y mantener archivos sensibles fuera del repositorio mediante `.gitignore`.
9. Los secretos deben almacenarse en un gestor seguro, por ejemplo GitHub Secrets o Vault, nunca directamente en el código.
10. Los accesos de colaboradores externos deben aplicar mínimo privilegio y revisarse periódicamente.

## 4. Matriz “quién puede qué”

| Acción | Quién puede | Requisitos |
|---|---|---|
| Hacer merge a `main` | Lead, Code Owner o integrante autorizado | PR aprobado; mínimo 1 aprobación. Cambios críticos requieren Code Owner. No se permite merge directo desde forks sin revisión. Hotfix mantiene PR y revisión, aunque sea prioritaria. |
| Modificar pipelines | SRE y responsables de `.github/workflows/` | Aprobación obligatoria del Code Owner y Lead de Seguridad. Acciones externas deben ser verificadas. Todo cambio queda auditado mediante Git. |
| Crear releases | Release Manager | Checklist aprobado, tag firmado, trazabilidad al ticket o PR y publicación dentro de la ventana definida. |
| Modificar secretos | Solo 2 Secret Custodians autorizados | Acceso auditado, separación entre dev y prod, rotación calendarizada y procedimiento de emergencia ante filtraciones. |

Las actualizaciones automáticas de dependencias pueden utilizar auto-merge únicamente si los controles automáticos finalizan correctamente y la actualización no modifica componentes críticos. Los PR provenientes de forks no tendrán acceso automático a secretos del pipeline.

## 5. Cobertura de riesgos y controles

| Riesgo | Control obligatorio |
|---|---|
| Exposición de secretos | Gestor de secretos, `.gitignore` y escaneo automático de secretos. |
| Modificación maliciosa | Code review obligatorio y `CODEOWNERS`. |
| Eliminación de ramas | Protección de branches, sin force-push ni eliminación de `main`. |
| Commits no autorizados | Commits firmados y MFA obligatorio. |
| Colaboradores externos con acceso vigente | Mínimo privilegio, accesos temporales y revisión periódica. |
| Pull Requests hostiles | Reglas de merge, revisión humana, aprobación de workflows y protección de secretos en forks. |
| Pérdida de confianza en el repositorio como activo | Auditoría permanente del historial, controles verificables y trazabilidad de cambios y releases. |

## 6. Excepciones y revisión
Toda excepción debe registrarse mediante un ticket o solicitud formal indicando motivo, alcance, duración y responsable. Debe ser aprobada por el Lead de Seguridad y, cuando afecte producción, también por el SRE o Release Manager.

Los hotfix de emergencia no eliminan los controles mínimos: deben utilizar una rama `hotfix/*`, Pull Request, aprobación y registro de la modificación. Si una exposición de secretos llega al repositorio, el secreto debe rotarse inmediatamente y luego debe limpiarse el historial mediante una herramienta apropiada.

Esta política se revisará trimestralmente y también después de incidentes relevantes, cambios importantes en la plataforma o incorporación de nuevos proveedores externos.
