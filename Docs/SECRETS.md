# Sesión 07 · Procedimiento de gestión y rotación de secretos

SecurePipeline · SecureBank API. Política del laboratorio. Los roles expresan responsabilidades del procedimiento, no asignaciones personales no verificadas.

## 1. Inventario y custodia

| Tipo | Uso y estado | Almacenamiento |
|---|---|---|
| Tokens de autorización de prueba | Identidades ficticias, sin acceso a servicios reales | Datos de prueba declarados en el servidor; no usar en producción |
| Token de GitHub Actions | Identidad temporal del job | Emitido por GitHub, permisos limitados a la operación |
| Identidad de firma Cosign | OIDC del workflow de la sesión 13 | Credencial efímera, sin clave privada persistente del equipo |
| Secret del laboratorio Kubernetes | Valor temporal de la sesión 12 | Creación en ejecución, Secret cifrado en etcd |
| Credenciales de AWS y de servicio bancario | No usadas en el despliegue real; IaC usa proveedor simulado | Gestor de secretos por ambiente en un despliegue autorizado |

## 2. Alternativas de almacenamiento

Variables de entorno locales para secretos de desarrollo no versionados; GitHub Secrets para credenciales imprescindibles de CI con alcance mínimo; OIDC preferente para evitar claves persistentes. Para producción, Vault o gestor cloud con control de acceso y auditoría. Kubernetes Secret requiere cifrado en reposo, RBAC y rotación; Base64 no es cifrado. Vault es una alternativa propuesta, no una instalación comprobada.

## 3. Detección

La configuración [Gitleaks](../.gitleaks.toml) mantiene reglas predeterminadas y exclusiones de archivos generados. El [hook](../.githooks/pre-commit) analiza el directorio local; se activa por clon con git config --local core.hooksPath .githooks. El [CI](../.github/workflows/ci.yml) analiza el historial Git y falla si detecta un secreto. La [bitácora S07](Bitacora/Sesion_07.md) registra 59 commits analizados sin hallazgos y una prueba local con marcador ficticio que bloqueó el hook. El [run positivo](https://github.com/Mmanzor/securebank-api/actions/runs/44631144440) no demuestra por sí mismo un bloqueo remoto.

## 4. Política de rotación

| Credencial | Frecuencia propuesta | Responsable de rol | Verificación |
|---|---|---|---|
| GITHUB_TOKEN y OIDC | Por job; revocar sesiones ante incidente | Seguridad CI | Permisos mínimos y expiración |
| Secret temporal de Kind | Por clúster / ejecución | Operaciones | Nuevo despliegue disponible, valor anterior descartado |
| Clave de servicio futura | Cada 90 días o inmediatamente ante exposición | Custodio del servicio | Cliente autorizado funciona con el reemplazo y la clave anterior se rechaza |
| Credencial cloud futura | Preferir sesiones efímeras; revisar confianza cada trimestre | Operaciones / Seguridad CI | Emisor, audiencia y alcance revisados |

La API actual no dispone de un mecanismo de emisión y rotación de sesiones reales. En una implementación posterior, el custodio crea el reemplazo en el gestor, distribuye por ambiente, reinicia o recarga consumidores, comprueba salud y revoca el anterior. No se publican valores de secretos ni claves en evidencias.

## 5. Respuesta ante exposición

Detectar y registrar tipo, fecha y revisión; revocar inmediatamente en el proveedor; rotar y verificar consumidores; coordinar limpieza de historial, clones, cachés y artefactos; notificar al responsable de seguridad y a los afectados; documentar el cierre. Eliminar un archivo no revoca una credencial.

## 6. Evidencia y límites

El ensayo local de Gitleaks está documentado en S07. La [prueba de detección y control limpio](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584) devolvió un hallazgo y luego cero. En la [ejecución negativa aislada](https://github.com/Mmanzor/securebank-api/actions/runs/45944913434), Gitleaks falló y el empaquetado quedó omitido. La rama evidencia/s07-bloqueo emplea un marcador inerte, no una credencial real. Los reportes redactados se conservan en [reports/secrets](../reports/secrets/). El procedimiento de rotación de credenciales reales es una política propuesta; no se declara ejecutado en producción.