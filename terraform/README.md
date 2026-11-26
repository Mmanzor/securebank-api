# Sesión 11 · Infraestructura como código

Este laboratorio modela la infraestructura AWS de SecureBank. Incluye los
20 elementos principales de la pauta y sus controles y recursos de soporte.
El conteo de Checkov incluye ambos grupos y puede variar según cómo expanda
los recursos de Terraform.

## Resultados de Checkov 3.4.11

| Medición | Línea base | Código corregido |
| --- | ---: | ---: |
| Controles aprobados | 152 | 174 |
| Controles fallidos | 33 | 11 |
| Security Score | 82,16 % | 94,05 % |
| Críticos según la política del laboratorio | 4 | 0 |
| Altos según la política del laboratorio | 18 | 0 |
| Riesgos residuales revisados | 11 | 11 |

Security Score = controles aprobados ÷ (aprobados + fallidos) × 100.
Los escenarios se escanean con la misma versión de Checkov y sin omitir
controles. Checkov se ejecuta en modo local, sin acceso a Prisma Cloud.
Como en ese modo no descarga severidades, `security/s11/gate.py` documenta la
clasificación empleada. El gate también bloquea hallazgos no revisados,
reportes inválidos, controles omitidos y puntajes inferiores al 85 %.

| Hallazgo | Control | Corrección |
| --- | --- | --- |
| SSH permitía conexiones desde cualquier red | CKV_AWS_24 | Se restringió al CIDR interno y las EC2 no reciben IP pública. |
| Los buckets carecían de barreras contra la exposición pública | CKV2_AWS_6, CKV_AWS_53–56 | Se activaron los cuatro controles de bloqueo en ambos buckets. Backups usa SSE-KMS. |
| El almacenamiento de PostgreSQL carecía de cifrado | CKV_AWS_16 | Se habilitó cifrado con KMS y se conservó la instancia en subredes sin acceso público. |
| La política de la función permitía cualquier acción sobre cualquier recurso | CKV_AWS_62 | El acceso quedó limitado a leer objetos de un prefijo y escribir en el grupo de logs de la función. |
| Se podían omitir los registros de auditoría | CKV_AWS_251 | Se habilitaron CloudTrail y VPC Flow Logs, con destinos cifrados. |

Los 11 hallazgos residuales se mantienen visibles en el JSON. Incluyen
SSO para la identidad de referencia, aislamiento y firma de Lambda,
notificaciones y replicación de S3, y controles complementarios de RDS.
El bucket de logs usa SSE-S3 para recibir logs de acceso del ALB. El
resultado se limita a este entorno académico y esta política de riesgo.

## Ejecución

GitHub Actions ejecuta Checkov, bloquea el pipeline si el gate falla y,
con resultado favorable, valida Terraform y ejecuta un plan y un apply
de prueba con `mock_provider "aws"`. No se requieren credenciales ni se
crean recursos, bases de datos o cargos. Los jobs publican los JSON y
las salidas de validación como artefactos vinculados al commit.

En local, desde la raíz, con Terraform 1.17.2, Checkov 3.4.11 y Python 3:

```bash
mkdir -p /tmp/s11-evidence
python3 security/s11/make_baseline.py terraform /tmp/s11-evidence/baseline
checkov --skip-download --skip-results-upload --framework terraform \
  --directory /tmp/s11-evidence/baseline --soft-fail --output json > /tmp/s11-evidence/before.json
checkov --skip-download --skip-results-upload --framework terraform \
  --directory terraform --soft-fail --output json > /tmp/s11-evidence/after.json
python3 security/s11/gate.py /tmp/s11-evidence/before.json
python3 security/s11/gate.py /tmp/s11-evidence/after.json
terraform -chdir=terraform init -backend=false -lockfile=readonly
terraform -chdir=terraform test -no-color
```

El gate devuelve 1 para la línea base y 0 para el código corregido. La línea
base se genera en un directorio temporal y su restricción de versión impide
inicializarla con Terraform.
