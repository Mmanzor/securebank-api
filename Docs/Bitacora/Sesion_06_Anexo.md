# Sesión 06 · Inventario y política de composición

El manifiesto y lockfile npm declaran la aplicación raíz (securebank-api 1.0.0) y ninguna dependencia externa directa o transitiva. No declaran licencia. El inventario de componentes del sistema operativo y Node.js se aborda en la sesión 10.

| CVSS | Decisión | Responsable de rol |
|---|---|---|
| 9,0–10,0 | Bloquear, corregir y reanalizar | Desarrollo / Seguridad CI |
| 7,0–8,9 | Retener hasta revisión y corrección o cambio de política autorizado | Seguridad CI / Release |
| 0–6,9 | Registrar y priorizar según exposición y uso | Desarrollo / Planificación |
| Sin CVSS | Conservar severidad de fuente; no asumir ausencia de riesgo | Seguridad CI |

El umbral del CI histórico bloquea HIGH y CRITICAL en Trivy. Es una aproximación conservadora basada en severidad; el score CVSS, cuando existe, debe conservarse como dato del informe. La política OPA de la sesión 9 es una política separada, con sus propios umbrales documentados.

El run histórico [44623022636](https://github.com/Mmanzor/securebank-api/actions/runs/44623022636) registró un escaneo de sistema de archivos sin archivos específicos de lenguajes reconocidos (num=0). El resultado no acredita ausencia de vulnerabilidades en todos los componentes. La consulta actual no devuelve los artefactos de ese run; no se reconstruyen sus JSON a partir de los números narrados.

Para cumplir el formato docente se debe conservar un SBOM SPDX 2.3 o CycloneDX 1.5, junto al reporte nativo y un resumen legible de la decisión. El formato 1.7 del informe histórico es una versión distinta de la exigida.

## Nueva evidencia del pipeline

El [run 45944833584](https://github.com/Mmanzor/securebank-api/actions/runs/45944833584) produjo [SPDX 2.3](../../reports/securebank-sbom.spdx.json), [JSON de npm audit](../../reports/securebank-vulns.json) y [reporte legible](../../reports/securebank-vulns.md). Inventario: paquete raíz, PURL y licencia NOASSERTION. Auditoría npm: cero avisos y cero dependencias externas, dentro del alcance del lockfile. La decisión es continuar en ese alcance, sin inferir seguridad del runtime o del sistema operativo.
