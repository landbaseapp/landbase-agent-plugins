---
name: find-lookalike-companies
description: Find companies that are similar to a set of example companies, for example the user's best customers. Use when the user asks for lookalikes, "more companies like these", "companies similar to our customers" or to grow a target account list from examples.
---

# Find lookalike companies

The `similar_company_expansion` workflow starts from a dataset of example
companies (the seed) and makes a new dataset of similar companies. It uses
credits. The result can have thousands of companies.

## Steps

1. **Preview the direction.** Call `search` with a request such as
   "companies similar to acme.com and example.com". Show 10 rows with
   `preview_dataset`. Ask the user if the companies are the correct type. If
   they are not, ask the user for better examples.
2. **Make the seed dataset.** Use one of these:
   - A list from the user: use the `import-and-match` skill.
   - An earlier search or dataset: use its dataset ID.

   If the user has more than one account, pass the same `account_id` on every
   call.
3. **Write the guidance (optional).** If the seed companies are mixed (for
   example different industries or sizes), write short instructions in
   `firmographics_guidance`, for example "only B2B SaaS companies in the US with
   50-500 employees".
4. **Ask how many companies the user wants.** Tell the user that a full run can
   return a large number of companies.
5. **Get a quote.** Call `run_workflow` with
   `workflow="similar_company_expansion"`, the seed `dataset_id` and
   `params={"firmographics_guidance": "..."}`, without `confirm`. Show the quote
   to the user and ask for approval.
6. **Run.** After the user agrees, call `run_workflow` again with the same
   arguments and `confirm=true`. Call `get_workflow_run` until the status is
   `SUCCEEDED`. The new companies are in the `output_dataset_id`.
7. **Show the result.** Call `get_dataset` and `preview_dataset`. To keep only
   the number that the user asked for, call `transform_dataset` with a `LIMIT`
   or a `WHERE` clause.

## Rules

- Use an `output_dataset_id` only when its run status is `SUCCEEDED`.
  `transform_dataset` can return while its run is `RUNNING`. Then call
  `get_workflow_run` with its `workflow_run_id` until the run stops. If the
  status is `FAILED` or `CANCELLED`, stop and tell the user the reason.
- Do not start a paid run without a quote and the user's approval.
- Keep the `workflow_run_id`. A timeout does not stop the run. Check the status
  before you start the run again.
