#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${AZURE_TENANT_ID:-}" ]] && [[ -n "${AZURE_CLIENT_ID:-}" ]] && [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-${AZURE_CLIENT_SECRET:-}}" ]]; then
  if [[ -n "${AZURE_ENVIRONMENT:-}" ]]; then
    az cloud set --name "${AZURE_ENVIRONMENT}"
  fi

  if [[ -n "${AZURE_FEDERATED_TOKEN_FILE:-}" ]]; then
    token="$(cat "${AZURE_FEDERATED_TOKEN_FILE}")"
    az login --service-principal --tenant "${AZURE_TENANT_ID}" --user "${AZURE_CLIENT_ID}" --federated-token "${token}"
  elif [[ -n "${AZURE_CLIENT_SECRET:-}" ]]; then
    az login --service-principal --tenant "${AZURE_TENANT_ID}" --user "${AZURE_CLIENT_ID}" --password "${AZURE_CLIENT_SECRET}"
  fi
fi