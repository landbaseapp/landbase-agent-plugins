---
name: export-list
description: Get a Landbase dataset as a CSV, JSONL or Parquet file through a download link. Use when the user asks to download or export a list, or asks for a file or spreadsheet of a list.
---

# Export a list

Downloads cost 0 credits. Before the download, remove the rows and columns that
the user does not need.

## Steps

1. **Find the correct dataset.** Use the dataset that the user names or
   talked about last, for example "the qualified list" or "the list with
   emails". If more than one dataset in this conversation can be the correct
   one, for example a sample and a full run, or two segments, and the user does
   not say which one, show those datasets with their row counts and ask. Use
   the latest `output_dataset_id` only when one dataset fits the request. Do
   not export a test sample when the user wants the full list. If the user has
   more than one account, pass the same `account_id` on every call.
2. **Remove what the user does not need.** Show the row count and the columns
   with `get_dataset`. If the user wants fewer rows or columns, call
   `transform_dataset` with SQL, for example
   `SELECT company_name, website, email FROM input_dataset WHERE email IS NOT NULL`.
   Use its `output_dataset_id`.
3. **Make the file.** Call `publish_dataset` with `format="csv"` (or `jsonl.gz`
   or `parquet` if the user asks). Call `get_workflow_run` with the
   `workflow_run_id` until the status is `SUCCEEDED`. Use its
   `output_dataset_id`.
4. **Get approval for the download.** Call `get_download_url` without
   `confirm`. The result is `needs_confirmation` with the row count. Tell the
   user the row count and ask for approval.
5. **Get the link.** After the user agrees, call `get_download_url` again with
   `confirm=true`. Give the link to the user. The link expires after about 30
   minutes.

If `get_download_url` returns `PUBLISH_REQUIRED`, do step 3 first.

## Rules

- Use an `output_dataset_id` only when its run status is `SUCCEEDED`.
  `transform_dataset` can return while its run is `RUNNING`. Then call
  `get_workflow_run` with its `workflow_run_id` until the run stops. If the
  status is `FAILED` or `CANCELLED`, stop and tell the user the reason.
- Do not download without the user's approval.
- Anyone who has the link can download the file until it expires. Do not put
  the link in a public place.
