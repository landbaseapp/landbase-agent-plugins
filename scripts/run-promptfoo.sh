#!/usr/bin/env bash
set -euo pipefail

PROMPTFOO_VERSION="${PROMPTFOO_VERSION:-0.124.1}"
: "${PROMPTFOO_VERSION:?PROMPTFOO_VERSION must not be empty}"

environment="${1:?usage: run-promptfoo.sh local|dev}"
if [[ -n "${LANDBASE_S2S_API_KEY:-}" && -z "${MCP_TOKEN:-}" ]]; then
  export MCP_TOKEN="$LANDBASE_S2S_API_KEY"
fi
case "$environment" in
  local) export MCP_URL="${MCP_URL:-http://127.0.0.1:8081/mcp}" ;;
  dev) export MCP_URL="${MCP_DEV_URL:?MCP_DEV_URL is required for dev evaluations}" ;;
  *) echo "usage: $0 local|dev" >&2; exit 2 ;;
esac

results_dir="${PROMPTFOO_RESULTS_DIR:-promptfoo-results/$environment}"
config_file="${PROMPTFOO_CONFIG_FILE:-.promptfoo.yaml}"
mkdir -p "$results_dir"

npx --yes "promptfoo@${PROMPTFOO_VERSION}" eval \
  --config "$config_file" \
  --no-cache \
  --output "$results_dir/latest.json"
