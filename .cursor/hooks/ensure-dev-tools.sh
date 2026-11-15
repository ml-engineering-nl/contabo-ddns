#!/usr/bin/env bash
# sessionStart: keep the laptop on the repo-pinned Rust toolchain.
set -euo pipefail

input="$(cat)"
root="$(cd "$(dirname "$0")/../.." && pwd)"

# Fail open for non-agent sessions; still run setup when we can.
if ! command -v rustup >/dev/null 2>&1; then
  printf '%s\n' '{"additional_context":"contabo-ddns: rustup not on PATH; skip toolchain ensure."}'
  exit 0
fi

log="$("$root/scripts/ensure-dev-tools.sh" 2>&1)" || {
  # Escape for JSON without requiring jq.
  escaped="$(printf '%s' "$log" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  printf '{"additional_context":"contabo-ddns toolchain ensure failed: %s"}\n' "${escaped:1:${#escaped}-2}"
  exit 0
}

active="$(cd "$root" && rustc -vV | awk '/^release:/{print $2}')"
printf '{"additional_context":"contabo-ddns using Rust %s (rust-toolchain.toml)."}\n' "$active"
exit 0
