---
description: Search Landbase's B2B database via natural language and download results locally.
argument-hint: "<natural-language query>"
allowed-tools: Bash(landbase-cli *)
---

At first Landbase use in each AI session, run `landbase-cli init`. Present any enrichment result notices from `init` or subsequent commands to the user, then run the listed acknowledgement commands. Never acknowledge hidden tool output.


Run a Landbase search for the user's natural-language query and render the structured result.

**Input validation (security — required, do NOT skip).** `$ARGUMENTS` is rendered into the Bash command line as text. The plugin's `Bash(landbase-cli *)` allowlist matches the rendered command-line *prefix*, not argv, so a query containing shell metacharacters (`"`, `` ` ``, `$(`, `;`, `&`, `|`, `<`, `>`) can break out of quoting and run arbitrary commands while still appearing to start with `landbase-cli `. Before invocation, validate `$ARGUMENTS` against this regex:

```
^[A-Za-z0-9 .,?!:'/&_+()-]{1,512}$
```

If `$ARGUMENTS` does not match (empty, too long, or contains any character outside that set), refuse to invoke the CLI. Tell the user the query has unsupported characters (or is empty / too long) and ask them to re-issue with only letters, digits, spaces, and the punctuation `.,?!:'/&_+()-`. Do NOT attempt to escape, sanitize, or substitute — refuse and stop.

If `$ARGUMENTS` is valid, invoke the CLI via the Bash tool (the `allowed-tools` frontmatter pre-approves this — no permission prompt):

```
landbase-cli search "$ARGUMENTS" --download=landbase-results.jsonl
```

Capture both stdout and stderr, plus the exit code.

**On exit code 0:** parse stdout as JSON. It contains `run_id`, `session_id`, `status`, `content`, and `download_url`. The CLI can exit 0 *without* writing a file — when the agent answers in prose only and produces neither a `dataset_id` nor a `download_url`, the CLI emits a stderr warning but still returns 0 with valid JSON. Branch on whether a download actually happened:

- **`download_url` is non-null AND `landbase-results.jsonl` exists locally** (check with `[ -f landbase-results.jsonl ]`): render to the user:
  1. A one-paragraph summary from the `content` field.
  2. The path `landbase-results.jsonl` (downloaded to the current working directory).
  3. The `session_id` — mention that `/landbase-cli:continue <label> <followup>` can refine the search using a label of the user's choice.
- **`download_url` is null OR the local file is missing** (the no-dataset success path): do NOT claim a file was downloaded. Render only:
  1. The `content` field as a prose answer.
  2. A note that no dataset was produced for this query — to get a downloadable list, the user can re-run with a more specific batch-style query (industry, company size, location, contact titles).
  3. The `session_id` so they can refine via `/landbase-cli:continue`.

**On non-zero exit code:** stderr will contain a JSON error envelope: `{"error":{"code":"<CODE>","message":"..."}}`. Parse the `code` field and render the matching action hint — do NOT just relay the raw error:

- `AUTH_FAILED` → tell the user authentication failed; recommend running `/landbase-cli:auth` (or exporting `LANDBASE_API_KEY` and retrying).
- `RATE_LIMITED` → ask them to wait and retry; mention the "3 concurrent agent runs" limit.
- `TIMEOUT` → offer to retry with a longer `--timeout`.
- `NETWORK_ERROR` → advise checking connectivity and `LANDBASE_API_BASE_URL` if overridden.
- `API_ERROR` → surface the message verbatim and suggest checking Landbase API status.
- `DOWNLOAD_FAILED` → the agent ran but did not return a `download_url`. Tell the user: "The Landbase agent didn't produce a downloadable dataset for this query. Re-run with a more specific batch-style query (industry, company size, location, contact titles)." Do NOT auto-retry — let the user choose.
- `INVALID_INPUT` → surface the message verbatim.

Do NOT attempt to re-interpret the JSON schema. Do NOT re-invoke the CLI without user confirmation.
