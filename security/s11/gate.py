"""Evaluate the reviewed offline severity policy against Checkov Terraform JSON."""

import argparse
import json
from collections import Counter
from pathlib import Path

CRITICAL = {"CKV_AWS_24", "CKV_AWS_62", "CKV2_AWS_6"}
HIGH = {
    "CKV_AWS_16", "CKV_AWS_17", "CKV_AWS_53", "CKV_AWS_54", "CKV_AWS_55",
    "CKV_AWS_56", "CKV_AWS_63", "CKV_AWS_251", "CKV_AWS_286", "CKV_AWS_287",
    "CKV_AWS_288", "CKV_AWS_289", "CKV_AWS_290", "CKV_AWS_355", "CKV2_AWS_40",
}
RESIDUAL = {
    ("CKV_AWS_273", "aws_iam_user.ci"),
    ("CKV_AWS_117", "aws_lambda_function.api"),
    ("CKV_AWS_173", "aws_lambda_function.api"),
    ("CKV_AWS_116", "aws_lambda_function.api"),
    ("CKV_AWS_272", "aws_lambda_function.api"),
    ("CKV2_AWS_62", "aws_s3_bucket.backups"),
    ("CKV2_AWS_62", "aws_s3_bucket.logs"),
    ("CKV2_AWS_69", "aws_db_instance.postgres"),
    ("CKV_AWS_144", "aws_s3_bucket.backups"),
    ("CKV_AWS_144", "aws_s3_bucket.logs"),
    ("CKV_AWS_145", "aws_s3_bucket.logs"),
}
REQUIRED_CHECKS = {
    ("CKV_AWS_24", "aws_security_group.app"),
    ("CKV2_AWS_6", "aws_s3_bucket.backups"),
    ("CKV2_AWS_6", "aws_s3_bucket.logs"),
    ("CKV_AWS_16", "aws_db_instance.postgres"),
    ("CKV_AWS_62", "aws_iam_role_policy.workload"),
    ("CKV_AWS_251", "aws_cloudtrail.main"),
}


def classify(check):
    item = (check["check_id"], check["resource"])
    if check.get("severity") == "CRITICAL" or item[0] in CRITICAL:
        return "CRITICAL"
    if check.get("severity") == "HIGH" or item[0] in HIGH:
        return "HIGH"
    return "MEDIUM" if item in RESIDUAL else "UNREVIEWED"


def evaluate(report):
    summary = report["summary"]
    results = report["results"]
    passed = summary["passed"]
    failed = summary["failed"]
    total = passed + failed
    if (report["check_type"] != "terraform" or summary["parsing_errors"] != 0
            or summary["skipped"] != 0 or total == 0
            or len(results["passed_checks"]) != passed
            or len(results["failed_checks"]) != failed):
        raise ValueError("Reporte incompleto, con omisiones o con errores de análisis.")

    evaluated = {
        (row["check_id"], row["resource"])
        for outcome in ("passed_checks", "failed_checks")
        for row in results[outcome]
    }
    if not REQUIRED_CHECKS <= evaluated:
        raise ValueError("El reporte no evaluó todos los controles obligatorios.")

    findings = [
        {"id": row["check_id"], "resource": row["resource"], "severity": classify(row)}
        for row in results["failed_checks"]
    ]
    severities = Counter(row["severity"] for row in findings)
    score = 100 * passed / total
    allow = passed * 100 >= total * 85 and not any(
        severities[level] for level in ("CRITICAL", "HIGH", "UNREVIEWED")
    )
    return {
        "allow": allow,
        "resources": summary["resource_count"],
        "passed": passed,
        "failed": failed,
        "score": round(score, 2),
        "severities": {
            level: severities[level] for level in ("CRITICAL", "HIGH", "MEDIUM", "UNREVIEWED")
        },
        "findings": findings,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    try:
        result = evaluate(json.loads(args.report.read_text(encoding="utf-8")))
    except (OSError, KeyError, TypeError, ValueError) as exc:
        parser.exit(2, f"Checkov: {exc}\n")
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["allow"] else 1)


if __name__ == "__main__":
    main()
