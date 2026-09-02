# POL-REPO-001 — Política de Repositorios Seguros

**Versión:** 1.0
**Fecha:** Septiembre 2026
**Proyecto:** SecureBank API

---

## § 1 · Alcance

Esta política aplica a todos los repositorios de código productivo y pre-productivo de la organización.

Su objetivo es proteger el código fuente, prevenir modificaciones no autorizadas, evitar la exposición de secretos y asegurar la trazabilidad de los cambios realizados en los repositorios.

---

## § 2 · Roles y responsabilidades

### Developer

Puede crear ramas, desarrollar funcionalidades y crear Pull Requests. No puede realizar cambios directos en la rama `main`.

### Reviewer

Es responsable de revisar los Pull Requests y verificar la calidad y seguridad de los cambios antes de aprobarlos.

### Code Owner

Es responsable de aprobar cambios realizados en archivos o áreas críticas del proyecto, especialmente código sensible y configuraciones del pipeline.

### Release Manager

Es responsable de crear y autorizar releases oficiales del proyecto, verificando que se cumplan los controles establecidos.

### Secret Custodian

Es responsable de administrar, modificar y rotar los secretos utilizados por la aplicación y el pipeline.

---

## § 3 · Reglas técnicas obligatorias

Todos los miembros con acceso al repositorio deberán utilizar **MFA**.

La rama `main` deberá permanecer protegida y no permitirá pushes directos.

Todo cambio deberá realizarse mediante un **Pull Request**.

Cada Pull Request deberá contar con al menos **una aprobación** antes de realizar el merge.

Los cambios realizados en archivos críticos deberán ser aprobados por el **Code Owner** correspondiente.

Los commits deberán estar **firmados** para garantizar la identificación y trazabilidad del autor.

No se permitirá el uso de **force push** ni la eliminación de la rama `main`.

Se deberá ejecutar un **escaneo automático de secretos en cada push**.

Los archivos que contengan secretos, como `.env`, `credentials.json`, certificados o llaves privadas, no deberán almacenarse en el repositorio.

---

## § 4 · Matriz "Quién puede qué"

| Acción               | Quién puede hacerlo            | Condiciones                                     |
| -------------------- | ------------------------------ | ----------------------------------------------- |
| Crear ramas          | Developer                      | Utilizar ramas `feature/*` o `hotfix/*`         |
| Hacer merge a `main` | Developer autorizado / Lead    | Pull Request aprobado y controles superados     |
| Aprobar Pull Request | Reviewer / Code Owner          | Mínimo 1 aprobación                             |
| Modificar pipelines  | Code Owner + Lead de Seguridad | Revisión obligatoria y aprobación adicional     |
| Crear releases       | Release Manager                | Tag firmado y checklist aprobado                |
| Modificar secretos   | Secret Custodian               | Acceso limitado y auditoría                     |
| Merge desde forks    | Lead / Code Owner              | Revisión manual obligatoria                     |
| Hotfix urgente       | Lead / Release Manager         | PR obligatorio y revisión posterior documentada |

### Reglas para Pull Requests

* Todo cambio hacia `main` debe pasar por Pull Request.
* Se requiere mínimo una aprobación.
* Los Pull Requests con cambios en archivos críticos requieren aprobación del Code Owner.
* Los Pull Requests provenientes de forks no pueden acceder automáticamente a los secretos del pipeline.
* Los cambios en dependencias pueden utilizar auto-merge únicamente si los controles automáticos de seguridad son aprobados.

### Modificación de pipelines

Los archivos ubicados en `.github/workflows/` solo podrán ser modificados con revisión del Code Owner y aprobación adicional.

No se permitirán acciones o workflows no verificados.

Todos los cambios realizados al pipeline deberán quedar registrados para fines de auditoría.

### Creación de releases

Solo el Release Manager podrá crear releases oficiales.

Cada release deberá contar con:

* Tag firmado.
* Controles de seguridad aprobados.
* Checklist de validación.
* Registro de los cambios realizados.
* Trazabilidad hacia el Pull Request o ticket correspondiente.

### Gestión de secretos

Los secretos solo podrán ser modificados por las personas autorizadas como Secret Custodian.

Los secretos deberán:

* Estar separados por ambiente (`development` y `production`).
* Rotarse periódicamente.
* Mantener un registro de accesos y modificaciones.
* Ser reemplazados inmediatamente en caso de exposición.

---

## § 5 · Excepciones y revisión

Las excepciones a esta política deberán ser solicitadas y documentadas antes de realizar el cambio.

En casos de emergencia o hotfix crítico, se podrá aplicar un procedimiento excepcional autorizado por el Lead o Release Manager. Posteriormente, el cambio deberá ser revisado y documentado.

Esta política será revisada trimestralmente para verificar que continúe siendo efectiva y aplicable a las necesidades de la organización.

---

**POL-REPO-001 · Política de Repositorios Seguros · Versión 1.0**
