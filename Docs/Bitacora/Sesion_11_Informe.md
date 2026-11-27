# Sesión 11 · Informe de auditoría de infraestructura

Checkov 3.4.11 evaluó el módulo Terraform reconstruido para representar los veinte elementos principales de la pauta y recursos auxiliares. Se aplicó la misma versión del analizador a la línea base y al módulo corregido.

| Métrica | Antes | Después |
|---|---:|---:|
| Aprobados | 152 | 174 |
| Fallidos | 33 | 11 |
| Críticos según política local | 4 | 0 |
| Altos según política local | 18 | 0 |
| Security Score | 82,16 % | 94,05 % |

Security Score = aprobados / (aprobados + fallidos) × 100. El resultado supera el mínimo del 85 %. Los once riesgos residuales siguen documentados; no se excluyeron controles del análisis. La clasificación es local, no una clasificación descargada de Prisma Cloud.

| Hallazgo prioritario | Corrección |
|---|---|
| CKV_AWS_24 · SSH expuesto | Restricción al CIDR interno, EC2 sin IP pública |
| CKV2_AWS_6 / CKV_AWS_53–56 · S3 | Bloqueo de acceso público en ambos buckets y SSE-KMS en backups |
| CKV_AWS_16 · PostgreSQL | Cifrado con KMS y subredes privadas |
| CKV_AWS_62 · IAM | Permisos limitados a prefijo de objetos y grupo de logs |
| CKV_AWS_251 · Auditoría | CloudTrail y VPC Flow Logs con destinos cifrados |

El gate rechaza informes incompletos, controles omitidos, hallazgos graves o sin clasificar y puntuaciones inferiores al 85 %. [Run negativo](https://github.com/Mmanzor/securebank-api/actions/runs/45726588055). [Run positivo](https://github.com/Mmanzor/securebank-api/actions/runs/45727010153): scan/gate, plan y apply simulado terminaron con éxito. [Artefacto nativo de Checkov](https://github.com/Mmanzor/securebank-api/actions/runs/45727010153/artifacts/15074019156).

La ejecución utiliza mock_provider de AWS; no se aprovisionó infraestructura real. Los detalles de reproducción están en [terraform/README.md](../../terraform/README.md). El cuadro de resultados describe la ejecución histórica; la captura original del pipeline debe conservarse como evidencia independiente, sin simular una pantalla.