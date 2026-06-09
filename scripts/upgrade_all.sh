#!/usr/bin/env bash
# upgrade_all.sh — upgrade every module.
#
# Kept as a thin shim for muscle-memory / automation: `cmd upgrade` (no module
# argument) already upgrades all modules in deployment order. Prefer `cmd upgrade`.

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPTS_DIR/cmd" upgrade "$@"
