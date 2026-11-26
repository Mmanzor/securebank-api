import unittest

from consolidate import coverage, gitleaks, semgrep, trivy, zap


class ConsolidationTests(unittest.TestCase):
    def test_semgrep_maps_severities_and_rejects_scan_errors(self):
        results = [{"extra": {"severity": level}} for level in ("CRITICAL", "ERROR", "WARNING")]
        self.assertEqual(semgrep({"errors": [], "results": results}), {"critical": 1, "high": 1, "medium": 1})

        with self.assertRaises(ValueError):
            semgrep({"errors": [{"message": "scan error"}], "results": []})

    def test_trivy_and_zap_count_findings(self):
        trivy_report = {
            "SchemaVersion": 2,
            "Results": [{"Vulnerabilities": [{"Severity": "HIGH"}, {"Severity": "LOW"}]}, {}],
        }
        zap_report = {"site": [{"alerts": [{"riskcode": "3"}, {"riskcode": "2"}, {"riskcode": "0"}]}]}

        self.assertEqual(trivy(trivy_report), {"critical": 0, "high": 1, "medium": 0})
        self.assertEqual(zap(zap_report), {"critical": 0, "high": 1, "medium": 1})

        self.assertEqual(
            trivy({"SchemaVersion": 2, "ArtifactType": "filesystem"}),
            {"critical": 0, "high": 0, "medium": 0},
        )

        with self.assertRaises(ValueError):
            zap({"site": []})

    def test_secret_count_and_line_coverage(self):
        self.assertEqual(gitleaks(None), {"count": 0})
        self.assertEqual(gitleaks([{"RuleID": "test-rule"}]), {"count": 1})
        self.assertEqual(coverage({"total": {"lines": {"pct": 80}}}), {"percent": 80})

        with self.assertRaises(ValueError):
            coverage({"total": {"lines": {"pct": True}}})


if __name__ == "__main__":
    unittest.main()
