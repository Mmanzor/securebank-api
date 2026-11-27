# Sesión 01 · Activos, amenazas y vulnerabilidades

SecurePipeline · SecureBank API. El siguiente ejercicio complementa el [ciclo DevSecOps](CicloDevsecops.drawio.pdf) y el [modelo STRIDE](../Threat_Modeling/THREAT-MODEL.md). Describe riesgos del escenario bancario, no incidentes reales.

| Activo | Amenaza | Vulnerabilidad del escenario | Control y fase |
|---|---|---|---|
| Credenciales y sesiones | Suplantación | Falta de MFA o validación de tokens | Autenticación robusta, rate limiting; Plan / Code / Test |
| Saldos y transferencias | Débito de cuenta ajena | Autorización por objeto insuficiente | Verificar identidad y propiedad; Code / Test |
| Base de datos | Alteración o divulgación | Consultas concatenadas | Parametrización y SAST; Code / Test |
| Repositorio y CI | Modificación no autorizada | Acciones mutables, permisos excesivos | PR, CODEOWNERS, SHA y mínimo privilegio; Code / Build |
| Secretos | Exposición en Git | Credenciales versionadas | Gitleaks, custodia y rotación; Code / Operate |
| Imagen y servicio | Ejecución privilegiada o alteración de imagen | Root, dependencias y tags mutables | Trivy, usuario no root, firma por digest; Build / Release / Deploy |
| Registros de auditoría | Repudio | Evidencia insuficiente o alterable | Registro protegido y alertas; Operate / Monitor |

Descubrir un defecto crítico inmediatamente antes de producción exige detener la promoción y volver a evaluar la corrección. Shift-left reduce el costo de corregir al incorporar controles desde Plan y Code, sin reemplazar monitoreo y respuesta en ejecución.

La API actual es un laboratorio de autorización con usuarios y tokens ficticios, no una implementación bancaria de producción. Las medidas de arquitectura que no están implementadas se mantienen como riesgos o requisitos del modelo.