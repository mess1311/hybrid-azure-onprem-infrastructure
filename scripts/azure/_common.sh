#!/usr/bin/env bash
# Shared helper: loads config.env from the repo root and checks the Azure CLI login.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="${REPO_ROOT}/config.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing ${CONFIG}. Run: cp config.example.env config.env  and fill it in." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a; source "$CONFIG"; set +a

require() {
  for v in "$@"; do
    if [[ -z "${!v:-}" ]]; then
      echo "Set ${v} in config.env before running this script." >&2
      exit 1
    fi
  done
}

if ! az account show >/dev/null 2>&1; then
  echo "Not logged in. Run: az login" >&2
  exit 1
fi
