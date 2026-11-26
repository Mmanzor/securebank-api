# Sesión 10 · Seguridad de contenedores y Docker

**Proyecto:** SecurePipeline · SecureBank API · Universidad Bernardo O’Higgins

Comparamos dos imágenes de Linux AMD64 construidas a partir del mismo código
y con Node.js 24.22.3. Ambas ejecutaron el mismo `GET /health` y devolvieron HTTP 200.
La imagen de referencia se ejecutó en un contenedor aislado para el laboratorio.

## Resultados medidos

| Métrica | `securebank:v1` | `securebank:v2-secure` | Cambio |
| --- | ---: | ---: | --- |
| Vulnerabilidades críticas | 3 | 0 | -3 (-100.0%) |
| Vulnerabilidades altas | 192 | 51 | -141 (-73.4%) |
| Total alta + crítica | 195 | 51 | -144 (-73.8%) |
| Paquetes Debian instalados | 455 | 78 | -377 (-82.9%) |
| Tamaño local | 441.6 MB | 76.0 MB | -365.6 MB (-82.8%) |
| Usuario efectivo | root (UID 0) | appuser (UID 10001) | Menor privilegio |
| Puertos declarados | 22/tcp, 3000/tcp | 3000/tcp | Solo HTTP en v2 |

Medimos el tamaño local de Docker en MB decimales. Contamos los paquetes Debian
instalados con `dpkg-query` y las filas de vulnerabilidades altas y críticas
reportadas por Trivy. Una misma CVE puede afectar a más de un paquete. Ambas
imágenes se analizaron con Trivy 0.76.2 y la misma base de vulnerabilidades.
Los puertos de la tabla corresponden a `EXPOSE`, que documenta puertos sin
publicarlos en el host.

## Qué cambió

| Práctica | Cómo se aplicó |
| --- | --- |
| Base y tamaño | La referencia usa la imagen completa de Node.js. La versión endurecida usa Debian 13 slim y copia solo el ejecutable de Node desde una etapa intermedia. |
| Menos software | El runtime endurecido no instala dependencias del sistema ni incluye npm, Yarn, herramientas de compilación o sus cachés. La API de prueba usa la biblioteca estándar de Node.js. |
| Mínimo privilegio | El proceso de v2 se ejecuta con `appuser` y UID 10001. El código se copia como archivos propiedad de root que el proceso puede leer. |
| Reproducibilidad | Las imágenes base se fijan por etiqueta y digest SHA-256. El escáner también está fijado por digest. |
| Contexto y secretos | `.dockerignore` permite solo los archivos necesarios y excluye explícitamente archivos de entorno y claves. El Dockerfile no incluye credenciales. |
| Puertos e inmutabilidad | La referencia declara 22 y 3000. No ejecuta SSH. La imagen v2 declara solo 3000 y respondió con sistema de archivos de solo lectura, sin capacidades adicionales y con `no-new-privileges`. |
| Escaneo automatizado | El workflow construye ambas versiones, guarda sus reportes y falla si Trivy detecta alguna vulnerabilidad crítica en v2. |

## Evidencia y reproducción

- [Ejecución de GitHub Actions del 25 de noviembre de 2026](https://github.com/Mmanzor/securebank-api/actions/runs/45725209090)
- [Artefacto con los resultados de Trivy de ambas imágenes](https://github.com/Mmanzor/securebank-api/actions/runs/45725209090/artifacts/15073778227)
- [Commit medido](https://github.com/Mmanzor/securebank-api/commit/0391305ced2b394fa9814715eaba5ea2a3a009eb)

El artefacto contiene `v1-trivy.json` y `v2-secure-trivy.json`, sus salidas
de tabla para severidades HIGH y CRITICAL, el inventario de paquetes, las
respuestas HTTP, la identidad efectiva y el cálculo de la comparación.

Desde la raíz del repositorio, con Docker y Trivy:

```bash
docker build -f docker/Dockerfile.v1 -t securebank:v1 .
docker build -f docker/Dockerfile.v2 -t securebank:v2-secure .
trivy image --scanners vuln --severity HIGH,CRITICAL securebank:v1
trivy image --scanners vuln --severity HIGH,CRITICAL securebank:v2-secure
docker run --rm --network none --read-only --cap-drop ALL \
  --security-opt no-new-privileges --entrypoint whoami securebank:v2-secure
```

## Riesgos residuales

La imagen endurecida conservó **51 hallazgos altos**. Trivy siguió detectando
hallazgos en paquetes de la base Debian como `util-linux` y componentes de OpenSSL.
El umbral de esta entrega bloquea hallazgos críticos. Para mantener la imagen,
se deben revisar las altas, actualizar los digests cuando haya parches y
volver a ejecutar el escaneo. La revisión de CVE del sistema operativo debe
complementarse con el seguimiento de avisos de Node.js, porque en v2 el
ejecutable se copia directamente desde la imagen oficial.

En esta sesión se comprobó el servicio de prueba en GitHub Actions. El uso
posterior de la imagen requiere aplicar también las restricciones de ejecución
del laboratorio, los permisos mínimos y la configuración de red del entorno.
