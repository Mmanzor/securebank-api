# POL-REPO-001: Política de Repositorios Seguros

## 1. Alcance
Esta política aplica a todos los repositorios de código fuente de la organización, con especial enfoque en el proyecto SecureBank API, abarcando a los 40 desarrolladores distribuidos en los 5 equipos de trabajo.

## 2. Roles y Responsabilidades
* **Developer:** Responsable de escribir código seguro en ramas de características (`feature/*`), realizar pruebas locales y solicitar revisiones mediante Pull Requests.
* **Code Owner / Lead Dev:** Responsable de revisar el diseño del código, validar la calidad e integrar los cambios hacia la rama principal.
* **Release Manager:** Encargado exclusivo de la creación y firma de tags de versión para despliegues a entornos productivos.
* **Secret Custodian:** Encargado de la gestión, custodia y rotación periódica de credenciales y llaves secretas.

## 3. Reglas Técnicas Obligatorias
1. **Autenticación Fuerte:** MFA obligatorio para todos los colaboradores del repositorio.
2. **Protección de Rama Principal:** La rama `main` queda inmutable. Se prohíbe el push directo y los `force-push` (`--force`).
3. **Flujo de Pull Requests:** Todo cambio debe ingresar a `main` mediante un Pull Request con al menos 1 aprobación obligatoria de un Code Owner. Las revisiones aprobadas se descartan automáticamente si se suben nuevos commits.
4. **Commits Firmados:** Todo commit debe estar firmado criptográficamente mediante GPG/SSH para garantizar la autoría.
5. **Prevención de Secretos:** Prohibido subir archivos `.env` o credenciales. Se activa escaneo automático de secretos en el pipeline.

## 4. Matriz "Quién puede qué" (Respuesta al Desafío)

| Pregunta / Área | Regla y Control Establecido |
| :--- | :--- |
| **Q1. ¿Quién puede hacer merge?** | Solo desarrolladores autorizados con al menos 1 aprobación previa de un Code Owner. Se prohíbe el auto-merge en dependencias sin revisión previa. |
| **Q2. ¿Quién puede modificar pipelines?** | Cambios en `.github/workflows/` restringidos a los Owners de seguridad/DevOps mediante el archivo `CODEOWNERS`. |
| **Q3. ¿Quién puede crear releases?** | Exclusivo del **Release Manager** utilizando tags firmados (ej. `v1.2.0`) previa aprobación de auditoría. |
| **Q4. ¿Quién puede modificar secretos?** | Acceso restringido a 2 custodia de secretos (Secret Custodians). Separación estricta entre secretos de `dev` y `prod`. |

## 5. Excepciones y Procedimiento de Emergencia
Para correcciones urgentes (`hotfix/*`):
* Se permite un flujo acelerado pero **siempre exigiendo un PR** con la firma del Release Manager.
* Se debe realizar una revisión y auditoría dentro de las 24 horas posteriores al evento.