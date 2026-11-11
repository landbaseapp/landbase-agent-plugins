# Capability boundaries

- Counts describe observed records. Count distinct current people, define role
  membership, and deduplicate company identities. An observed zero does not prove
  absence; keep unknown separate from zero.
- Ratios need a denominator and defined behavior for zero or missing values.
  Distributions need the statistic's definition and usable sample size.
- Historical comparisons need dated observations in comparable windows.
  Retrospective start dates do not reconstruct what was known earlier; job
  postings are not hires; fresh web evidence is not a historical snapshot. If
  the data cannot support the metric, explain the limit and offer an explicit
  alternative without silently changing the metric.
- Sources include company, person, job posting, local business, and supported
  owned datasets. Inspect actual fields before promising coverage.
- Owned-data joins need a registered dataset ID and usable identity keys. Upload
  supplied files with `upload_dataset` when needed. Keep source identifiers,
  avoid duplicate-domain fan-out, and preserve unmatched rows when extending a
  list. An upload is a snapshot, not a live CRM sync.
- Alumni connections are distinct from semantic similarity. For lookalikes use
  `run_workflow(workflow="similar_company_expansion")`; its bounded candidate pool
  can miss qualifying companies.
- A small output limit does not imply a cheap or exhaustive scan. Rely on the
  returned estimate and status; do not promise latency, completeness, or purchase
  intent.
