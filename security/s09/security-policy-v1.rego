package securepipeline.gate

import rego.v1

default allow := false

allow if {
    input.sast.critical == 0
}
