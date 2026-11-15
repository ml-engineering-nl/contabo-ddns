#!/usr/bin/env bash
# Install the repo-pinned Rust toolchain/components and cargo-llvm-cov when missing.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

if ! command -v rustup >/dev/null 2>&1; then
  echo "rustup is required (https://rustup.rs)" >&2
  exit 1
fi

channel="$(
  sed -n 's/^channel *= *"\([^"]*\)".*/\1/p' rust-toolchain.toml | head -1
)"
if [[ ! "$channel" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "could not read channel from rust-toolchain.toml" >&2
  exit 1
fi

# Directory overrides beat rust-toolchain.toml; drop a stale local pin.
if rustup override list 2>/dev/null | awk -v root="$root" '$1 == root { found=1 } END { exit !found }'; then
  echo "removing rustup directory override for ${root} (rust-toolchain.toml wins)"
  rustup override unset
fi

echo "ensuring Rust ${channel} from rust-toolchain.toml"
rustup show active-toolchain >/dev/null

if ! command -v cargo-llvm-cov >/dev/null 2>&1; then
  echo "installing cargo-llvm-cov"
  cargo install cargo-llvm-cov --locked
fi

echo "active: $(rustc -vV | awk '/^release:/{print $2}')"
echo "cargo-llvm-cov: $(cargo llvm-cov --version)"
