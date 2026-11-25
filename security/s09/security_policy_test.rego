package securepipeline.gate_test

import data.securepipeline.gate
import rego.v1

test_public_service_passes_at_thresholds if {
	result := gate.decision with input as data.fixtures.pass
	result == {"allow": true, "reasons": []}
}

test_policy_reports_all_blocking_reasons if {
	result := gate.decision with input as data.fixtures.block
	not result.allow
	count(result.reasons) == 4
	"Se detectaron hallazgos críticos" in result.reasons
	"Hay más de 2 hallazgos de severidad alta" in result.reasons
	"La cobertura de pruebas es inferior al 80%" in result.reasons
	"Un servicio público admite como máximo 5 hallazgos de severidad media" in result.reasons
}

test_secret_blocks_build if {
	findings := object.union(data.fixtures.pass, {"secrets": {"count": 1}})
	result := gate.decision with input as findings
	result == {"allow": false, "reasons": ["Se detectaron secretos"]}
}

test_internal_medium_limit if {
	findings := object.union(data.fixtures.pass, {
		"exposure": "internal",
		"dast": {"critical": 0, "high": 0, "medium": 6},
	})
	gate.allow with input as findings
	excess := object.union(findings, {"dast": {"critical": 0, "high": 0, "medium": 7}})
	result := gate.decision with input as excess
	result == {"allow": false, "reasons": ["Hay más de 10 hallazgos de severidad media"]}
}

test_missing_or_invalid_report_blocks_build if {
	findings := object.union(object.remove(data.fixtures.pass, ["dast"]), {"coverage": {"percent": 101}})
	result := gate.decision with input as findings
	not result.allow
	count(result.reasons) == 4
	"Falta un conteo válido para dast.critical" in result.reasons
	"Falta un porcentaje de cobertura válido (0 a 100)" in result.reasons
}

test_empty_report_does_not_pass if {
	result := gate.decision with input as {}
	not result.allow
	count(result.reasons) == 12
	"Falta un conteo válido para secrets.count" in result.reasons
}
