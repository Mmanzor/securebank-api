package securepipeline.gate

import rego.v1

default allow := false

scanners := ["sast", "sca", "dast"]
severities := ["critical", "high", "medium"]
exposures := {"internal", "public"}

nonnegative_integer(value) if {
	is_number(value)
	value >= 0
	value == floor(value)
}

valid_count(scanner, severity) if {
	nonnegative_integer(input[scanner][severity])
}

deny contains reason if {
	some scanner in scanners
	some severity in severities
	not valid_count(scanner, severity)
	reason := sprintf("Falta un conteo válido para %s.%s", [scanner, severity])
}

valid_secret_count if {
	nonnegative_integer(input.secrets.count)
}

deny contains "Falta un conteo válido para secrets.count" if {
	not valid_secret_count
}

valid_coverage if {
	is_number(input.coverage.percent)
	input.coverage.percent >= 0
	input.coverage.percent <= 100
}

deny contains "Falta un porcentaje de cobertura válido (0 a 100)" if {
	not valid_coverage
}

valid_exposure if {
	input.exposure in exposures
}

deny contains "exposure debe ser internal o public" if {
	not valid_exposure
}

total(severity) := sum([count |
	some scanner in scanners
	count := input[scanner][severity]
	nonnegative_integer(count)
])

deny contains "Se detectaron secretos" if {
	valid_secret_count
	input.secrets.count > 0
}

deny contains "Se detectaron hallazgos críticos" if {
	total("critical") > 0
}

deny contains "Hay más de 2 hallazgos de severidad alta" if {
	total("high") > 2
}

deny contains "Hay más de 10 hallazgos de severidad media" if {
	total("medium") > 10
}

deny contains "La cobertura de pruebas es inferior al 80%" if {
	valid_coverage
	input.coverage.percent < 80
}

deny contains "Un servicio público admite como máximo 5 hallazgos de severidad media" if {
	input.exposure == "public"
	total("medium") > 5
}

allow if {
	count(deny) == 0
}

decision := {"allow": allow, "reasons": sort(deny)}
