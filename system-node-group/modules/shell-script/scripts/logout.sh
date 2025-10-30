#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${AZURE_TENANT_ID:-}" ]] && [[ -n "${AZURE_CLIENT_ID:-}" ]] && [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-${AZURE_CLIENT_SECRET:-}}" ]]; then
  az logout --username "${AZURE_CLIENT_ID}" || true
fi