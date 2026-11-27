"""Summarize real npm audit output without inventing CVSS values."""
import json
import sys
from pathlib import Path

folder = Path(sys.argv[1])
audit = json.loads((folder / "securebank-vulns.json").read_text())
if "error" in audit or "metadata" not in audit:
    raise SystemExit("npm audit no devolvió un informe válido")
counts = audit["metadata"]["vulnerabilities"]
if not all(isinstance(counts.get(s), int) for s in ("critical", "high", "moderate", "low", "info")):
    raise SystemExit("Conteos de auditoría inválidos")
sbom = json.loads((folder / "securebank-sbom.spdx.json").read_text())
if sbom.get("spdxVersion") != "SPDX-2.3":
    raise SystemExit("Formato SPDX inesperado")
rows = ["# SCA: informe de componentes vulnerables", "",
        "Fuente: npm audit --omit=dev --json; alcance: lockfile npm de producción.",
        "Los componentes del sistema y runtime se evalúan por separado.", "",
        "| Severidad npm | Conteo |", "|---|---:|"]
rows += [f"| {severity} | {counts[severity]} |" for severity in ("critical", "high", "moderate", "low", "info")]
rows += ["", "| Paquete | Rango afectado | Aviso / CVE si consta | CVSS | Decisión |", "|---|---|---|---|---|"]
block = bool(counts["critical"] or counts["high"])
for package, finding in audit.get("vulnerabilities", {}).items():
    for via in finding.get("via", []):
        if not isinstance(via, dict):
            continue
        score = via.get("cvss", {}).get("score")
        severity = via.get("severity", finding.get("severity", "unknown"))
        decision = "Bloquear/revisar" if severity in ("critical", "high") or isinstance(score, (int, float)) and score >= 7 else "Registrar"
        block |= decision == "Bloquear/revisar"
        rows.append(f"| {package} | {via.get('range', finding.get('range', 'no indicado'))} | {via.get('url', via.get('title','no indicado'))} | {score if score is not None else 'no informado'} | {decision} |")
if not audit.get("vulnerabilities"):
    rows.append("| Ninguno informado | — | — | — | Continuar en este alcance |")
rows += ["", "Decisión: " + ("RETENER para corrección o revisión." if block else "CONTINUAR en este alcance."),
         "La ausencia de avisos no demuestra ausencia total de vulnerabilidades."]
(folder / "securebank-vulns.md").write_text("\n".join(rows)+"\n", encoding="utf-8")
raise SystemExit(1 if block else 0)
