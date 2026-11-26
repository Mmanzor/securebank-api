"""Create the original misconfigured configuration for static scanning only."""

import argparse
import re
from pathlib import Path

BASELINE_VALUES = {
    "block_public_access": "false",
    "encrypt_rds": "false",
    "enable_logging": "false",
    "admin_cidr": '"0.0.0.0/0"',
    "workload_actions": '["*"]',
    "workload_resources": '["*"]',
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    args.destination.mkdir(parents=True, exist_ok=True)

    for path in sorted(args.source.glob("*.tf")):
        content = path.read_text(encoding="utf-8")
        if path.name == "versions.tf":
            for field, value in BASELINE_VALUES.items():
                content, count = re.subn(
                    rf"(?m)^(  {field}\s*=).*$", rf"\1 {value}", content
                )
                if count != 1:
                    raise ValueError(f"No se pudo generar el control inicial {field}")
            content, count = re.subn(
                r'(?m)^(  required_version\s*=).*$', r'\1 "< 0.0.0"', content
            )
            if count != 1:
                raise ValueError("La línea base debe quedar inhabilitada para Terraform")
        (args.destination / path.name).write_text(content, encoding="utf-8")


if __name__ == "__main__":
    main()
