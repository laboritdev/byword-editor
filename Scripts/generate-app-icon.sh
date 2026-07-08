#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/assets/scripts/generate-app-icon.sh" "$@"
