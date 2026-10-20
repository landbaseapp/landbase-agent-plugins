# `list_datasets` evaluation guide

## Purpose

Verify that an agent can use the read-only `list_datasets` MCP tool to inspect
an account's datasets without creating, changing, uploading, or deleting data.
Use only the local fixture or a dedicated synthetic dev tenant.

## Tool contract

```json
{
  "tool": "list_datasets",
  "args": {
    "limit": 20,
    "offset": 0
  }
}
```

- `limit` is optional and must be between 1 and 100. The default is 20.
- `offset` is optional and must be 0 or greater. The default is 0.
- The tool returns datasets newest first.
- The tool is read-only and should not consume credits or mutate data.

## Black-box checks

1. **Normal listing** — the agent selects `list_datasets`, sends valid pagination
   arguments, and receives a non-error response.
2. **Pagination** — the agent preserves `limit=1` and `offset=0` instead of
   dropping or renaming the arguments.
3. **Safety** — the agent does not call `upload_dataset`, `delete_dataset`,
   `publish_dataset`, or a workflow tool for a listing request.
4. **Failure handling** — invalid values such as `limit=0` are rejected clearly
   and do not result in a mutating fallback.
5. **Tenant safety** — dev runs use synthetic datasets only; never include real
   account IDs, dataset IDs, prompts, results, or bearer tokens in fixtures or
   committed artifacts.

## Run locally

```bash
cd ~/workspace/landbase-agent-plugins
./scripts/run-promptfoo.sh local
```

The local fixture must expose a deterministic `list_datasets` response before
these cases can pass. For the authenticated synthetic dev run:

```bash
MCP_DEV_URL="https://<dev-mcp-host>/mcp" \
LANDBASE_S2S_API_KEY="$LANDBASE_S2S_API_KEY" \
PROMPTFOO_CONFIG_FILE=evals/list-datasets.promptfoo.yaml \
./scripts/run-promptfoo.sh dev
```

Review tool-call metadata and aggregate pass/fail results. Do not upload raw
Promptfoo output to Langfuse; use the server repository's aggregate publisher.
