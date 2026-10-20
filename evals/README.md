# MCP evaluations

This directory contains sanitized Promptfoo cases for the Landbase MCP
integration. The checked-in cases use only the deterministic local fixture;
additional dev cases must use the dedicated synthetic/test tenant.

Never add production prompts, tool arguments, tool results, bearer tokens,
customer names, account IDs, dataset IDs, or other customer identifiers to this
repository or to uploaded evaluation artifacts.

## Local run

Start the MCP protocol fixture from `landbase-mcp-server` first, then run:

```bash
cd ../landbase-agent-plugins
./scripts/run-promptfoo.sh local
```

The local target defaults to `http://127.0.0.1:8081/mcp` and runs the checked-in
`fixture_ping` and unavailable-tool cases.

## Dev run

Use only a dedicated dev tenant containing synthetic or explicitly scrubbed
records:

```bash
MCP_DEV_URL=https://<dev-mcp-host>/mcp \
MCP_TOKEN="$LANDBASE_MCP_DEV_TOKEN" \
./scripts/run-promptfoo.sh dev
```

The token is read from the environment and must never be committed. Dev
results may be retained for regression comparisons only after removing raw
prompts, tool arguments, tool results, and identifiers.

## CI and Langfuse

Promptfoo's JSON output is a diagnostic artifact, not a production-data store.
Convert it to an aggregate result contract before publishing. The server
repository provides a validator/publisher:

```bash
python ../landbase-mcp-server/scripts/publish-langfuse-eval.py \
  eval-result.json
```

The input must contain `dataset_revision`, `server_revision`, `environment`,
`task_scores`, `tool_call_counts`, `latency_ms`, and `cost_usd`. The publisher
rejects prompts, tool arguments, tool results, tokens, secrets, account IDs, and
dataset IDs before sending metadata to Langfuse. Set `LANGFUSE_HOST`,
`LANGFUSE_PUBLIC_KEY`, and `LANGFUSE_SECRET_KEY` only in CI secret bindings.

Export failures must be visible, but they must not silently turn a failed
evaluation green.
