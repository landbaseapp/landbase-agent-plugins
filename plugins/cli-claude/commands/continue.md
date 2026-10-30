---
description: Continue a multi-turn Landbase search by session label.
argument-hint: "<session-label> <followup query>"
allowed-tools: Bash(landbase-cli *)
---

At first Landbase use in each AI session, run `landbase-cli init`. Present any enrichment result notices from `init` or subsequent commands to the user, then run the listed acknowledgement commands. Never acknowledge hidden tool output.


Continue a prior Landbase search by reusing its session label.

Parse `$ARGUMENTS`:
- The **first token** (up to the first whitespace) is `<label>` — the session label to resume.
- The **remainder** is `<query>` — the follow-up question to ask within that session.

Example: for `logistics-q1 narrow to Series B or later`, label is `logistics-q1` and query is `narrow to Series B or later`.

**Input validation (security — required, do NOT skip).** Both `<label>` and `<query>` are rendered into the Bash command line as text and the `Bash(landbase-cli *)` allowlist matches the command-line *prefix* (not argv), so shell metacharacters in either field can break out of quoting:

- `<label>` MUST match `^[A-Za-z0-9_-]{1,64}$`. Reject otherwise.
- `<query>` MUST match `^[A-Za-z0-9 .,?!:'/&_+()-]{1,512}$`. Reject otherwise.
- Empty `<query>` is also rejected.

If either fails, refuse to invoke the CLI. Tell the user the correct usage (`/landbase-cli:continue <label> <followup query>`) and what's invalid (label outside `[A-Za-z0-9_-]{1,64}`, query has unsupported characters, etc.). Do NOT attempt to escape, sanitize, or substitute — refuse and stop.

Then invoke the CLI via Bash (the `allowed-tools` frontmatter pre-approves this — no permission prompt):

```
landbase-cli search "<query>" --session=<label> --download=landbase-<label>-<timestamp>-<pid>.jsonl
```

where `<timestamp>` is the current Unix seconds (`date +%s`) and `<pid>` is the shell PID (`$$`). Using both ensures distinct files even across parallel sessions invoking the same label in the same second.

Capture both stdout and stderr, plus the exit code.

**On exit code 0:** parse stdout as JSON. The CLI can exit 0 *without* writing a file — when the agent answers in prose only and produces neither a `dataset_id` nor a `download_url`, the CLI warns on stderr but still returns 0 with valid JSON. Branch on whether a download actually happened:

- **`download_url` is non-null AND the download file exists locally** (check with `[ -f landbase-<label>-<timestamp>-<pid>.jsonl ]` for the path you generated): render:
  1. A one-paragraph summary from the `content` field.
  2. The path to the new download file.
  3. The `session_id` — confirm it's the same as the prior call in that label, or note "new session started under <label>" if the label had no prior mapping.
- **`download_url` is null OR the local file is missing**: do NOT claim a file was downloaded. Render:
  1. The `content` field as a prose answer.
  2. A note that no dataset was produced for this turn — suggest a more specific batch-style follow-up (industry, size, titles).
  3. The `session_id` so subsequent `/landbase-cli:continue <label> ...` calls keep refining.

**On non-zero exit code:** parse the stderr `{"error":{"code":"<CODE>","message":"..."}}` envelope and render the matching action hint — do NOT relay the raw error. Map the `code` field exactly as `/landbase-cli:search` does:

- `AUTH_FAILED` → tell the user to run `/landbase-cli:auth`.
- `RATE_LIMITED` → wait and retry; mention "3 concurrent agent runs" limit.
- `TIMEOUT` → offer to retry with a longer `--timeout`.
- `NETWORK_ERROR` → check connectivity and `LANDBASE_API_BASE_URL` if overridden.
- `API_ERROR` → surface the message verbatim.
- `DOWNLOAD_FAILED` → the agent ran but did not return a `download_url`. Stdout is empty in this case. Tell the user: "The Landbase agent didn't produce a downloadable dataset for this turn. Try a more specific batch-style follow-up (industry, size, titles)." Do NOT auto-retry.
- `INVALID_INPUT` → surface the message verbatim.

Do NOT attempt to re-interpret the JSON schema. Do NOT re-invoke the CLI without user confirmation.
