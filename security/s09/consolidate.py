"""Convert completed scanner reports to the session 9 OPA input."""

import argparse
import json
from collections import Counter
from pathlib import Path

LEVELS = ("critical", "high", "medium")
TRIVY = {level.upper(): level for level in (*LEVELS, "low", "unknown")}
SEMGREP = {
    "CRITICAL": "critical", "HIGH": "high", "MEDIUM": "medium", "LOW": "low",
    "ERROR": "high", "WARNING": "medium", "INFO": "low",
}
ZAP = {"3": "high", "2": "medium", "1": "low", "0": "info"}


def rows(value):
    if not isinstance(value, list) or any(not isinstance(row, dict) for row in value):
        raise ValueError("se esperaba una lista de registros")
    return value


def summarize(values, severity_map):
    counts = Counter(severity_map[value] for value in values)
    return {level: counts[level] for level in LEVELS}


def semgrep(report):
    if rows(report["errors"]):
        raise ValueError("el escaneo informó errores")
    return summarize((row["extra"]["severity"] for row in rows(report["results"])), SEMGREP)


def trivy(report):
    if report["SchemaVersion"] != 2:
        raise ValueError("se requiere SchemaVersion 2")
    results = report.get("Results", []) if report.get("ArtifactType") == "filesystem" else report["Results"]
    findings = (
        item["Severity"]
        for result in rows(results)
        for item in rows(result.get("Vulnerabilities", []))
    )
    return summarize(findings, TRIVY)


def zap(report):
    sites = rows(report["site"])
    if not sites:
        raise ValueError("el reporte no contiene sitios analizados")
    findings = (str(alert["riskcode"]) for site in sites for alert in rows(site["alerts"]))
    return summarize(findings, ZAP)


def gitleaks(report):
    findings = [] if report is None else rows(report)
    if any(not isinstance(item.get("RuleID"), str) or not item["RuleID"] for item in findings):
        raise ValueError("falta el identificador de regla")
    return {"count": len(findings)}


def coverage(report):
    percent = report["total"]["lines"]["pct"]
    if type(percent) not in (int, float) or not 0 <= percent <= 100:
        raise ValueError("se esperaba un porcentaje de cobertura de líneas entre 0 y 100")
    return {"percent": percent}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    formats = {
        "semgrep": ("sast", semgrep),
        "trivy": ("sca", trivy),
        "zap": ("dast", zap),
        "gitleaks": ("secrets", gitleaks),
        "coverage": ("coverage", coverage),
    }
    for name in formats:
        parser.add_argument(f"--{name}", type=Path, required=True)
    parser.add_argument("--exposure", choices=("internal", "public"), required=True)
    args = parser.parse_args()

    findings = {"exposure": args.exposure}
    for name, (field, normalize) in formats.items():
        try:
            with getattr(args, name).open(encoding="utf-8") as stream:
                findings[field] = normalize(json.load(stream))
        except (OSError, ValueError, KeyError, TypeError):
            parser.exit(2, f"Reporte de {name} inválido, incompleto o inaccesible.\n")

    print(json.dumps(findings, indent=2, allow_nan=False))


if __name__ == "__main__":
    main()
