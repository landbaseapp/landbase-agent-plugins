---
name: contact-enrich
description:
  Async batch email and phone enrichment for individual leads via workflow
  contact-enrich — not the same as workflow enrich which adds company/person
  attributes.
when_to_use:
  when the user needs email addresses or phone numbers for a list of people,
  enriching a dataset of contacts, checking the status of a contact enrichment
  run, or resuming a timed-out enrichment request
version: 1.3.0
user-invocable: true
allowed-tools:
  - Bash
  - AskUserQuestion
---

# Contact Enrich

Async batch email and phone enrichment: takes people, finds their contact
details.

This is different from `workflow enrich` — that command adds company/person
attributes (industry, size, description) from the Landbase graph.

## Enrich a dataset (`workflow contact-enrich`)

Before submission, tell the user that results may arrive after the wait ends.
When background recovery is enabled, later results are linked to the original
request and announced on a subsequent CLI command. Delivered enrichments may be
charged later to the original account; the same provider batches are not charged
twice. A separate enrichment run is a separate paid request: check the original
run's recovery status before recommending one.

```bash
# From a file: upload → onboard → contact-enrich. Each step emits a NEW
# dataset id — enrich the onboarded child, not the uploaded id.
landbase-cli upload ./leads.csv                    # → { "id": "ds-UPLOADED" }
landbase-cli workflow onboard ds-UPLOADED --wait   # → poll.run.output_dataset_id = "ds-ONBOARDED"
landbase-cli workflow contact-enrich ds-ONBOARDED --wait   # email + phone (default)
landbase-cli workflow contact-enrich ds-ONBOARDED --enrich-phone --wait   # phone ONLY
```

A positive `--enrich-email`/`--enrich-phone` switches to opt-in: the named one
runs and the other does not. Both run when neither is passed.
`--overwrite-existing` replaces existing
`contact_email_address`/`contact_phone_number` values with only this run's
results; the default preserves an existing value when this run finds nothing, so
re-running never wipes data.

Two children are registered: the enriched dataset (with a per-row
`contact_enrichment_status` of `enriched` / `not_enriched` / `failed` /
`pending` / `skipped`) and a 1-row `contact_enrich_report`.

**This output does not download directly (`PUBLISH_REQUIRED`).** Run
`workflow publish <ds-id> --wait`, then download that run's `output_dataset_id`.

### Time limit and `pending` rows

A run waits up to **1 hour** for the provider. Rows not returned by then are
`pending`: the run still **SUCCEEDS** with every finished row, and pending rows
are not charged. The run FAILS (`Contact enrichment timed out`) only when no row
finished in time.

`poll.run.contact_enrichment.pending_leads` counts the pending rows, and
`--wait` / `workflow status <run-id>` print a stderr notice. Do not report the
list as complete while pending rows remain. Check the original request first: if
recovery is linked, wait for its result instead of starting another paid run. A
separate run can charge for outstanding rows even if recovery later delivers
them too. If the user chooses a new run, use the **output** dataset and the same
channel flags:

```bash
landbase-cli workflow contact-enrich ds-ENRICHED --wait   # add --enrich-email or --enrich-phone if the first run used it
```

Rows that already have a value keep it and are not charged again; only the
missing rows go back to the provider. Never add `--overwrite-existing` here. Use
the same flags: with a different channel set the values are still kept, but
`contact_enrichment_status` reflects only the re-run's channels (an email-only
re-run marks a row with only a phone `not_enriched`).

### Monitor or resume a run

For interactive agent sessions, trigger without `--wait`, capture the returned
`workflow_run_id`, and use the `workflow-monitor` skill for live progress. If a
`--wait` invocation times out, the workflow keeps running; resume inspection
with the original input dataset id and run id:

```bash
landbase-cli workflow status ds-INPUT --run=dataset-contact-enrich-...
```

On `SUCCEEDED`, check `contact_enrichment.pending_leads` (above), then chain
`output_dataset_id` forward. On `CANCELLED`, use it if it is non-null. Stop on
`FAILED`.

### Slice an input (`--row-slice`)

Not needed for size: one run of any size keeps every row that finished. Use a
slice to enrich part of a dataset, or to split a very large input into runs that
each finish inside the time limit.

```bash
# Two serial slices, then recombine.
for s in 0:5000 5000:10000; do
  landbase-cli workflow contact-enrich ds-XXXX --row-slice=$s --wait
done

# Collect the child dataset ids (one per slice, named "... rows 0-4999" etc.)
landbase-cli datasets lineage ds-XXXX --direction=children --workflow=contact_enrich

# Recombine. No --dedupe-keys: the slices are disjoint, so a union keeps every row.
landbase-cli workflow union ds-SLICE0 ds-SLICE1 --wait
```

Rules:

- **Run slices serially, not in parallel.** Slicing buys runs that finish, not
  throughput.
- **Credits are charged per slice, so slicing costs the same as one big run.**
- A last slice running past the final row is fine — it returns the remaining
  rows and the child records the window it actually holds.
- **Recombine without `--dedupe-keys`.** Never key on `contact_email_address`:
  rows that did not enrich all carry an empty email (`''`), so they collapse
  into one and are silently dropped. Verify the union's `row_count` equals the
  sum of the slices'.

## Required signals per person

Each person needs `linkedin_url` **OR** (`first_name` + `last_name` +
`company`/`company_domain`) as columns in the dataset. Providing both name
signals and LinkedIn URL improves match rate materially.
