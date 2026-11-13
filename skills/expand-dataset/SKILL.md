---
name: expand-dataset
description: Expand the usefulness or coverage of a Landbase dataset with derived signals, team metrics, career-history connections, owned-data joins, or a new audience branch. Use when the user asks how to extend a list, add cross-record calculations, or broaden an audience using existing results. Standalone searches, market or competitor questions that start without a list, per-row research, qualification, contact lookup, and dataset administration belong to their dedicated Landbase skills.
---

# Expand a Landbase dataset

Add depth (signals or calculations) or breadth (a related audience) to the user's
list. Start from an existing dataset or the audience being built; preserve the
original result and identify the expanded output.

Use this skill for the expansion decision and its dataset lineage. Use
`build-prospect-list` for a standalone search, `research-accounts` for standard
attributes or a per-row fact, `qualify-list` for yes/no filtering, and
`manage-datasets` for status, discovery, cancellation, or deletion. Use
`market-insights` for a market, competitor or talent question that starts without a
list, for example "Where do product managers from big tech companies go next?". Use
`import-and-match` to prepare an uploaded list before extending it. A request only
for lookalikes belongs to `find-lookalike-companies`; use that skill for an
accepted similar-company expansion within a broader expansion task.

## Propose an expansion

Preserve the requested audience, exclusions, size, and fields. When discussing
expansion, offer at most one addition before the run and one after results.
Make at most one optional proposal across the skills involved at each stage.
Name the exact field or calculation, the decision it supports, and that it has not
run. Explain which observed values would change a row's priority and why for this
user's purpose. If that connection is weak, choose another signal or omit the offer. Phrase it as an offer, never a
commitment: “I can also add current RevOps headcount to help rank these accounts.”
Define any comparison window or denominator and condition the offer on the
required observations being available. Keep it out of the query until accepted;
continue the original request without waiting for an optional answer.

For example, a leadership change in the past 90 days can prioritize a renewal
account for a fresh stakeholder check, if dated role history is available.

When the user asks how to improve or extend a result, include one supported
expansion tied to their stated purpose. Keep it separate from missing-data
caveats. A field missing from the preview does not mean it cannot be derived
or researched. Skip offers when the user wants an exact query,
speed, or no extras, already declined, or nothing useful fits. For unattended
runs, list useful follow-ups in the result instead.

Include calculations the user already requested. Clarify only ambiguity that
materially changes the result; otherwise state a reasonable definition. Return
supporting counts, denominators, windows, or evidence for derived signals.

## Choose a relevant capability

These families combine freely; they do not guarantee field coverage.

| Family | Relevant request or addition |
| --- | --- |
| Career history | Find current sales managers whose previous role descriptions show first-sales-hire experience; include the matching past role. |
| Custom company signals | Count distinct current RevOps people with tenure under a year; filter or rank by the count. |
| Team distributions | Select companies by median or 90th-percentile engineering tenure; include the sample size. |
| Change over time | Compare AI job-posting counts in two explicit windows; distinguish postings from hires and check dated data availability. |
| Team mix and ratios | Compare observed engineering and security counts; show both counts and handle zero or unknown denominators. |
| Connections through people | Find companies with several current executives who previously worked at specified seed companies; include the shared-alumni count. |
| Your accounts plus Landbase | Join an owned account dataset to company/person records and add regional team counts or custom flags; preserve input identities and unmatched rows. |

For temporal, coverage-sensitive, or semantic/seed requests, read
[capability boundaries](references/capability-boundaries.md).

## Execute the expansion

Use `search(mode="research")` when the expansion needs calculations across
related records, career-history conditions, or joins to the wider Landbase data.
Use `transform_dataset` when the source rows already contain all required inputs.
Follow the tools' polling contract. When research mode returns a proposal, check
that its logic and columns match the request, then confirm it at once with its
returned `session_id` in the same research mode. Do not ask the user to approve
the cost. If the proposal does not match, refine it first; changed work needs an
updated proposal.
Inspect the completed result before reuse and use a successful workflow's
`output_dataset_id` for the next step.

Run the paid steps that the user asked for with `confirm=true` on the first call,
in interactive and unattended runs. Landbase deducts the credits when a step runs;
do not ask the user to approve the cost. If the user asks to see the cost first,
call the tool without `confirm`, show the quote, and wait for their answer. Never
run an optional addition that the user did not accept. If Landbase tools are
unavailable, provide the proposed query and explain the missing connection.

## Preserve sources and branches

An expansion can combine several signal families and downstream operations, or
branch from a usable earlier dataset. If the user requested the full chain,
continue across its steps without stopping for credit approval; stop only at
review checkpoints that the user asked for. If the user requested only one operation, deliver it before offering
an optional expansion; an offer does not authorize another step.

- Choose each step's input deliberately. A filtered result is useful for targeted
  research; its broader parent is useful for a different segment or comparison.
  Returning to a parent does not require rebuilding it or discarding its children.
- Keep a compact record of dataset IDs, purposes, parent IDs, relevant filters,
  and completed operations. Use those IDs rather than assuming “latest” is the
  intended input. Recover earlier work with `list_datasets` and
  `get_dataset_lineage` (`direction="parents"` or `"children"`); lineage returns
  direct neighbors, so follow links as needed. Clarify only if the intended
  earlier dataset remains ambiguous after inspection.
- Inspect an earlier dataset's status, fields and coverage before reuse. Branch
  by supplying that dataset ID to the next tool and record its new output ID.
  Before combining branches, check join keys, duplicate handling and missing rows; use
  `search(mode="research")` for supported multi-dataset joins. A single-dataset transform
  cannot read arbitrary sibling datasets.
- Report which dataset each branch used and where its outputs are. Reusing an
  earlier snapshot preserves its original coverage and age; obtain fresh data
  only when the request requires it.

## Deliver the expanded result

Return the dataset ID, observed size, requested fields, and material coverage or
calculation limits. Route accepted follow-ups by their required data:

- Good-fit examples selected by the user: offer similar-company expansion using
  a dataset of those seeds, via `run_workflow(workflow="similar_company_expansion")`.
- Useful accounts missing prioritization data: offer derived columns through
  research-mode search referencing the dataset ID, or `enrich_dataset` for stored
  attributes. Use `research_dataset` for new per-row evidence, and
  `qualify_dataset` for yes/no checks.
- Existing rows already contain the inputs: use `transform_dataset` for SQL over
  that dataset. It cannot query the wider company/person population by itself.

Run a paid follow-up only after the user accepts it, then start it with
`confirm=true` without a separate cost-approval step. When a user accepts an
addition before the initial build, include it in that build rather than silently
launching a separate paid workflow.
After launch, wait for the original result to be ready, then apply the accepted
addition as a follow-up on that dataset using the relevant capability above.
Preserve the original dataset and return the new output ID and its source; do
not restart the population search or imply that the launched build was amended.
