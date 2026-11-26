# Sesión 13 · Firma, digest y admisión

**Caso.** Si el tag `securebank:v1` pasa a apuntar a otra imagen, esta tiene
un digest SHA-256 distinto. El workflow usa el digest como referencia
inmutable, registra el commit en `build.json` y entrega a staging solo la
referencia que superó las verificaciones. Las dos ejecuciones del laboratorio
construyeron el mismo digest.

**Detección.** Cosign verifica la firma keyless contra la identidad exacta del
workflow, el emisor OIDC de GitHub Actions y el registro de transparencia
Rekor. Si la firma falta, es inválida o proviene de otra identidad, el job
falla y staging queda omitido. El pipeline también comprueba que la
atestación firmada corresponda a ese digest y que su contenido coincida
con el SBOM CycloneDX publicado por Syft.

**Admisión.** Tras pasar el gate, el workflow instala en Kind una política
que admite solo el digest verificado. Un Pod que usó el tag mutable fue
rechazado por la política. La imagen admitida arrancó y respondió a
`/health`. El registro OCI y el clúster son temporales, dentro del runner.

## Evidencia

- [Caso rojo](https://github.com/Mmanzor/securebank-api/actions/runs/45729834629): Cosign devolvió `no signatures found` y el job de staging quedó omitido.
- [Caso verde](https://github.com/Mmanzor/securebank-api/actions/runs/45729941786): SBOM CycloneDX de 2.517 componentes, firma y atestación verificadas, y staging completado.
- [Imagen OCI, SBOM y bundles firmados](https://github.com/Mmanzor/securebank-api/actions/runs/45729941786/artifacts/15076023744).
- [Verificación e índice de Rekor 4114759370](https://github.com/Mmanzor/securebank-api/actions/runs/45729941786/artifacts/15076461872).

Digest de la imagen medida:

`sha256:6b0c81d914209caada8084eb5d8f1b7e8bbdc3274b854db74c6fbb81dad31100`
