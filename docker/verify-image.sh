#!/usr/bin/env bash
set -euo pipefail

variant=$1
evidence=$2
shift 2
image="securebank:$variant"

docker image inspect "$image" > "$evidence/$variant-inspect.json"
docker run --rm --network none --entrypoint dpkg-query "$image" \
  -W -f='${db:Status-Abbrev} ${binary:Package}\n' \
  | awk '$1 == "ii" {print $2}' > "$evidence/$variant-packages.txt"

container=$(docker run --detach --network none "$@" "$image")
trap 'docker rm --force "$container" >/dev/null' EXIT
docker exec "$container" sh -c 'printf "%s (UID %s)\n" "$(whoami)" "$(id -u)"' \
  | tee "$evidence/$variant-user.txt"
docker exec "$container" node -e '
  const assert = require("node:assert/strict");
  async function check() {
    for (let attempt = 0; ; attempt++) {
      const response = await fetch("http://127.0.0.1:3000/health").catch(() => null);
      if (response) {
        assert.equal(response.status, 200);
        const health = await response.json();
        assert.deepEqual(health, { service: "securebank-api", status: "ok" });
        console.log(JSON.stringify(health));
        return;
      }
      if (attempt === 19) throw new Error("El servicio no respondió");
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }
  check();
' | tee "$evidence/$variant-health.json"
