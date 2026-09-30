# Análisis del pipeline inseguro — Sesión 04

El ejercicio de la Sesión 04 presenta cuatro riesgos en un workflow heredado. Se documentan aquí con su impacto, categoría STRIDE y corrección concreta.

| ID | Riesgo | Por qué es peligroso | STRIDE | Corrección |
|---|---|---|---|---|
| **R1** | `permissions: write-all` | El token del job obtiene permisos administrativos innecesarios; si se compromete, un atacante podría modificar contenido o publicar artefactos/releases. | **Elevation of Privilege** | Aplicar mínimo privilegio, por ejemplo `permissions: contents: read`. |
| **R2** | `curl http://.../setup.sh \| sudo bash` | Ejecuta código remoto por HTTP, sin firma ni checksum, con privilegios elevados. | **Tampering** | Evitar scripts remotos no verificados; usar acciones oficiales/versionadas y verificar integridad. |
| **R3** | `npm install express body-parser jsonwebtoken` | Instala versiones flotantes y no respeta un lockfile, aumentando el riesgo de supply-chain. | **Tampering** | Versionar `package-lock.json` y utilizar `npm ci`; posteriormente añadir auditoría/SCA. |
| **R4** | Contraseña escrita directamente en YAML | El secreto permanece en el historial Git y puede quedar expuesto a colaboradores o forks. | **Information Disclosure** | Guardar el valor en GitHub Secrets/Vault y consumirlo como `${{ secrets.DB_PASSWORD }}`. |

## Aplicación en nuestro pipeline

El workflow `.github/workflows/ci.yml` evita estos cuatro patrones:

1. Define permisos mínimos con `contents: read`.
2. Utiliza acciones oficiales de GitHub para checkout, Node y artefactos.
3. Ejecuta `npm ci` sobre un `package-lock.json` versionado.
4. No contiene credenciales ni valores sensibles.

## Responsabilidad por categoría

- **Plan — Matías Sepúlveda:** identifica dependencias y riesgos arquitectónicos.
- **Code / Build — Vicente Cosio:** asegura reproducibilidad de dependencias y build.
- **Test / Release — Marcela Manzor:** comprueba que el pipeline falle cuando una puerta de calidad no se cumple.
- **Deploy / Operate / Monitor — Catalina Garrido:** valida mínimo privilegio, trazabilidad y prácticas seguras de ejecución.

Este análisis se conecta directamente con el Threat Model de la Sesión 03 y deja preparado el pipeline para los controles SAST/SCA/DAST de las siguientes sesiones.
