"""Prepare the session 10 comparison from Docker and Trivy evidence."""

import argparse
import json
from collections import Counter
from pathlib import Path

SEVERITIES = ("CRITICAL", "HIGH")


def measure(directory, variant):
    inspection = json.loads((directory / f"{variant}-inspect.json").read_text())[0]
    scan = json.loads((directory / f"{variant}-trivy.json").read_text())
    if scan.get("SchemaVersion") != 2 or not scan.get("Results"):
        raise ValueError(f"El reporte de Trivy de {variant} no contiene resultados")

    findings = Counter(
        vulnerability["Severity"]
        for target in scan["Results"]
        for vulnerability in target.get("Vulnerabilities", [])
    )
    packages = (directory / f"{variant}-packages.txt").read_text().splitlines()
    if not packages:
        raise ValueError(f"No hay inventario de paquetes para {variant}")

    return {
        "size": inspection["Size"],
        "packages": len(packages),
        "user": (directory / f"{variant}-user.txt").read_text().strip(),
        "ports": ", ".join(sorted(inspection["Config"]["ExposedPorts"])),
        **{level: findings[level] for level in SEVERITIES},
    }


def reduction(before, after):
    if before == after:
        return "Sin variación"
    if before == 0:
        return f"+{after}"
    delta = after - before
    return f"{delta:+,} ({delta / before:+.1%})"


def comparison(before, after):
    print("| Métrica | `securebank:v1` | `securebank:v2-secure` | Cambio |")
    print("| --- | ---: | ---: | --- |")
    rows = (
        ("Vulnerabilidades críticas", before["CRITICAL"], after["CRITICAL"]),
        ("Vulnerabilidades altas", before["HIGH"], after["HIGH"]),
        ("Total alta + crítica", before["HIGH"] + before["CRITICAL"], after["HIGH"] + after["CRITICAL"]),
        ("Paquetes Debian instalados", before["packages"], after["packages"]),
    )
    for name, first, second in rows:
        print(f"| {name} | {first} | {second} | {reduction(first, second)} |")
    first, second = before["size"], after["size"]
    delta_mb = (second - first) / 1_000_000
    delta_pct = f" ({(second - first) / first:+.1%})" if first else ""
    print(f"| Tamaño local | {first / 1_000_000:.1f} MB | {second / 1_000_000:.1f} MB | {delta_mb:+.1f} MB{delta_pct} |")
    print(f"| Usuario efectivo | {before['user']} | {after['user']} | Menor privilegio |")
    print(f"| Puertos declarados | {before['ports']} | {after['ports']} | Solo HTTP en v2 |")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("evidence", type=Path)
    args = parser.parse_args()
    before = measure(args.evidence, "v1")
    after = measure(args.evidence, "v2-secure")
    comparison(before, after)
    (args.evidence / "metrics.json").write_text(
        json.dumps({"v1": before, "v2-secure": after}, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()
