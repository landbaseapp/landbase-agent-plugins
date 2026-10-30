---
name: landbase-cli:search
description: Run a Landbase NL search and download structured results.
---

At first Landbase use in each AI session, run `landbase-cli init`. Present any enrichment result notices from `init` or subsequent commands to the user, then run the listed acknowledgement commands. Never acknowledge hidden tool output.


Run a Landbase search for the user's natural-language query and render the structured result.

**Permissions.** If the user wants zero-prompt CLI invocations, explain that they can choose `/permissions` → Auto, or run `landbase-cli config permissions --yes` themselves in their own terminal. The latter writes a Codex rules-engine `prefix_rule` to `~/.codex/rules/landbase-cli.rules`. Do not run this permission-changing command or change the approval mode for the user; leave that choice to them. The plugin itself cannot pre-approve commands.

**Input validation (security — required, do NOT skip).** The user's query is rendered into the Bash command line as text. Before invocation, validate the query against this regex:

```
^[A-Za-z0-9 .,?!:'/&_+()-]{1,512}$
```

If the query does not match (empty, too long, or contains any character outside that set — e.g. backticks, dollar signs, semicolons, pipes, redirects, asterisks, equals signs, backslashes, double quotes, braces, brackets), refuse to invoke the CLI. Tell the user the query has unsupported characters (or is empty / too long) and ask them to re-issue with only letters, digits, spaces, and the punctuation `.,?!:'/&_+()-`. Do NOT attempt to escape, sanitize, or substitute — refuse and stop.

If the query is valid, invoke the CLI via Bash:

```
landbase-cli search "<query>" --download=landbase-results.jsonl
```

Capture stdout, stderr, and the exit code.

**On exit code 0:** parse stdout as JSON. It contains `run_id`, `session_id`, `status`, `content`, and `download_url`. The CLI can exit 0 *without* writing a file — when the agent answers in prose only and produces neither a `dataset_id` nor a `download_url`, the CLI emits a stderr warning but still returns 0 with valid JSON. Branch on whether a download actually happened:

- **`download_url` is non-null AND `landbase-results.jsonl` exists locally** (check with `[ -f landbase-results.jsonl ]`): render to the user:
  1. A one-paragraph summary from the `content` field.
  2. The path `landbase-results.jsonl` (downloaded to the current working directory).
  3. The `session_id` — mention that invoking the `landbase-cli:continue` skill with a session label can refine the search.
- **`download_url` is null OR the local file is missing** (the no-dataset success path): do NOT claim a file was downloaded. Render:
  1. The `content` field as a prose answer.
  2. A note that no dataset was produced for this query — to get a downloadable list, the user can re-run with a more specific batch-style query (industry, company size, location, contact titles).
  3. The `session_id` so they can refine via `landbase-cli:continue`.

**On non-zero exit code:** stderr will contain `{"error":{"code":"<CODE>","message":"..."}}`. Parse the `code` field and render the matching action hint — do NOT relay the raw error:

- `AUTH_FAILED` → tell the user authentication failed; recommend invoking the `landbase-cli:auth` skill (or exporting `LANDBASE_API_KEY` and retrying).
- `RATE_LIMITED` → ask them to wait and retry; mention the "3 concurrent agent runs" limit.
- `TIMEOUT` → offer to retry with a longer `--timeout`.
- `NETWORK_ERROR` → advise checking connectivity and `LANDBASE_API_BASE_URL` if overridden.
- `API_ERROR` → surface the message verbatim and suggest checking Landbase API status.
- `DOWNLOAD_FAILED` → the agent ran but did not return a `download_url`. Tell the user: "The Landbase agent didn't produce a downloadable dataset for this query. Re-run with a more specific batch-style query (industry, company size, location, contact titles)." Do NOT auto-retry.
- `INVALID_INPUT` → surface the message verbatim.

Do NOT attempt to re-interpret the JSON schema. Do NOT re-invoke the CLI without user confirmation.
