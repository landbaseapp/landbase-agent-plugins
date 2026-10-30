---
name: contacts-import
description:
  Import contacts into the Execution platform via landbase-cli contacts-import —
  covers building and validating an AI-driven header mapping, tracking an import
  to completion, and repairing failures using the server's authoritative header
  list.
when_to_use:
  when importing contacts into the Execution platform via contacts-import,
  building or repairing a header mapping, or reporting dropped columns / mapping
  failures after an import
version: 1.0.0
---

# Contacts Import (Execution platform) with AI header mapping

Import a dataset's contacts into the current account on the Execution platform
(where campaigns run). NEVER run a bare `contacts-import start` — default header
resolution drops every column it can't match. The drop is reported in the final
status, not silent, but the user's data is still not imported. Build a mapping
first. Violating the letter of these rules is violating their spirit.

Prereqs: `landbase-cli auth login`, then `landbase-cli account set` (or
`--account=<id>`). You need a dataset id from a prior search/agent run or
`upload` — those commands print `dataset_id`; pass that same value as
`datasetId` (camelCase) in the start body.

Mechanics (command list, body/response shapes, phases, polling) live in
`landbase-cli contacts-import --help`. This skill is the authority on when to
stop, what to repair, and what to report to the user.

## Red Flags — STOP

- About to run `contacts-import start` without a `mapping` in the body
- About to guess a field from its header name alone ("Contact", "Info", "ID")
  instead of checking sample values via `datasets peek`
- About to read the local CSV for headers when a `datasetId` exists — build
  headers from `datasets fields` (step 1); upload/publish can change the columns
- About to map a raw `datasets fields` name (`email`) instead of its import
  header (`LB_email`) — `start` fails with `header_not_in_file`
- About to `start` while `resolve` still reports `invalidMappingEntries`,
  `missingRequired`, or `violatedRowRules`
- About to proceed with non-empty `unmappedHeaders` without the user's explicit
  OK to drop those columns
- About to import test contacts to see how the import behaves — they land in the
  user's real account and the CLI cannot delete them

## The mapping flow

1. Headers come from the DATASET, not your local file. Take
   `landbase-cli datasets fields <datasetId>` and rename each field the way the
   import sees it: `CLI_<name>` → `<name>`; every other field → `LB_<name>`. An
   upload that skipped `workflow onboard` has no `CLI_` fields, so ALL its
   columns arrive `LB_`-prefixed (`email` → `LB_email`). Map to these renamed
   headers and pass them as `headers` to `resolve`. For ambiguous header names,
   check sample values:
   `landbase-cli datasets peek <datasetId> --sql "SELECT * FROM input_dataset LIMIT 3"`.
2. `landbase-cli contacts-import schema` — match each column to a catalog field
   by its `description` and by comparing sample values to `examples`/`format`.
   `rowRules` in the response is the authoritative list of `required` fields and
   `atLeastOneOf` groups (server-owned; never hardcode the rules).
3. Preflight: `landbase-cli contacts-import resolve --json -` on
   `{ "headers": [...], "mapping": { "company": {...}, "contact": {...} } }`.
   Stop conditions — fix, re-`resolve`, only then start:
   - `invalidMappingEntries`: `unknown_field` → use its `didYouMean`;
     `header_not_in_file` → use its `suggestion`. `resolve` tolerates unknown
     field names; `start` rejects them outright.
   - `missingRequired` / `violatedRowRules` non-empty → the import WILL fail.
   - `unmappedHeaders` non-empty → those columns will NOT be imported — remap
     them or confirm the loss with the user.
4. Start with the same mapping and watch to terminal:
   `echo '{"datasetId":"<id>","tagName":"<tag>","mapping":{...}}' | landbase-cli contacts-import start --json - --watch`
   (or poll `status <importId>` / block with `wait <importId>`).

## Existing contacts

A row that matches a contact already in the account updates it: `onDuplicate`
defaults to `"update"`, so non-blank values from the file overwrite name, email,
phone and LinkedIn (contacts in an active campaign only get empty fields
filled). To correct a contact, re-import its row with the right values. A
contact already in a scheduled, live or paused campaign cannot be corrected this
way — tell the user to fix it in the web app. Re-import also cannot correct the
LinkedIn URL of a contact matched by email: a row whose email matches but whose
LinkedIn differs only fills that contact's empty fields — tell the user to fix
the LinkedIn URL in the web app. Pass `"onDuplicate": "keep"` only when the user
wants existing values preserved.

## Email verification status

Contact enrichment writes each email's status to `contact_email_address_status`
(`LB_contact_email_address_status` among the import headers). Map it to
`contact.email_verification_status`. `deliverable` marks the contact's email
Verified for this account — for new contacts, and for existing ones whose email
matches the file or is replaced by it. An email replaced by a non-deliverable
one loses its old Verified status. Every other status (`catch_all_safe`,
`undeliverable`, ...) still imports and the email stays in the campaign; the
status does not change what you do.

When you build the import file yourself from enrichment output (joining, adding
copy columns), keep the status column next to the email. Dropping it imports new
or replaced emails as unverified.

## Reading the terminal status — what to report

- `unmapped.total > 0` → name the non-imported columns to the user
  (`unmapped.headers` caps at the first 50; `total` is the real count — say so
  when the list is truncated).
- `failed` with non-null `mappingErrors` → resolution failed BEFORE any rows
  ran. The repair source is `fileHeaders` in the SAME status — the server-side
  header list, authoritative over your local parse (first 50; `totalFileHeaders`
  is the real count). Rebuild the mapping against it, re-`resolve`, re-`start`.
- `partial` → some rows landed (`counts` shows what), `error` says why the rest
  didn't.
- On `completed`, report `counts` (imported/merged/skipped/invalid). `imported`
  is every contact the import tagged; `merged` is the part of it that already
  existed in the account and was updated (new = imported − merged). `merged` is
  normal, not a warning — those contacts are in the tag, updated as described in
  "Existing contacts". `imported` below `total` means rows in the file were the
  same person (same email, LinkedIn or phone) and were combined. These counts
  are contacts imported, not who a campaign will reach.

`LB_*` headers map like any other header. `unmapped` / `unmappedHeaders` skip
every `LB_*` header, so they can read 0 while `LB_*` columns you needed were
dropped — check that `applied` covers every column you meant to import.

## Failure modes

- `CONFLICT` on `start` — that importId is already enqueued; don't retry, poll
  `status <importId>`.
- `NOT_FOUND` on `schema`/`resolve` can mean the server predates these
  endpoints; route-level 404s are normalized even when an older deployment
  returns no error envelope.
- `TIMEOUT` on `wait`/`--watch` after 30min — the import keeps running; resume
  with `status <importId>` (the id rides in the error's `meta.importId`).
- `VALIDATION_ERROR` on `start` — usually a datasetId unknown or not accessible
  to this account.

## Integration

**Called by:** `dataset-pipeline`, which hands off here before importing
contacts. Return to the calling skill only after the import reaches a terminal
phase and the outcome (counts + any dropped columns) has been reported to the
user.
