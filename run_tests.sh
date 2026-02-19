#!/usr/bin/env bash
set -euo pipefail

SCRATCH_PATH="${SCRATCH_PATH:-/tmp/oneminutecolor-build}"
MODULE_CACHE="${MODULE_CACHE:-/tmp/swift-module-cache}"

env \
  SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE" \
  CLANG_MODULE_CACHE_PATH="$MODULE_CACHE" \
  swift test --disable-sandbox --scratch-path "$SCRATCH_PATH"
