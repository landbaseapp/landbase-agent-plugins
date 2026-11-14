---
name: find-contact-info
description: Find work email addresses and phone numbers for the people in a Landbase dataset. Use when the user asks for emails, phone numbers or contact details for a list of people, or asks how to reach the people on a list.
---

# Find contact information

`enrich_contacts` finds work emails, phone numbers, or both, for each person in
a dataset. It uses credits. Phone numbers cost more credits than emails.

## Steps

1. **Find the dataset.** Use a dataset ID from this conversation, or call
   `list_datasets` and ask the user which one. If the user has more than one
   account, pass the same `account_id` on every call.
2. **Make sure that the rows are people.** Call `get_dataset_fields` and
   `preview_dataset`. Each row must identify one person, for example with a
   name and a company, or a LinkedIn URL. If the dataset has only companies,
   ask the user which job titles they want. Then find those people with the
   `build-prospect-list` skill.
3. **Ask what to find.** Ask the user if they want emails, phone numbers, or
   both. Set `enrich_email_address` and `enrich_phone_number` to match.
4. **Limit the rows.** If the user needs fewer rows than the dataset has, call
   `transform_dataset` with a `LIMIT` or a `WHERE` clause first. Use its
   `output_dataset_id`.
5. **Run.** Call `enrich_contacts` with `confirm=true`. Call `get_workflow_run`
   with the `workflow_run_id` until the status is `SUCCEEDED`. A large list can
   take a long time. Continue with the same run ID.
6. **Show the result.** Use the `output_dataset_id`. Call `get_dataset_fields`
   to find the email and phone columns. Count rows with email and phone values
   over the full output using `transform_dataset`; wait for `SUCCEEDED` and
   preview its summary. Preview SQL sees only the first 100 source rows; use
   it directly for counts only if `get_dataset` confirms `row_count` is at most
   100. Show example rows as samples. Return the result ID and any saved summary
   ID, and say the summary is a new dataset removable with `delete_dataset`
   after confirmation.
7. **Offer a file.** To give the user a file, use the `export-list` skill.

## Rules

- Use an `output_dataset_id` only when its run status is `SUCCEEDED`.
  `transform_dataset` can return while its run is `RUNNING`. Then call
  `get_workflow_run` with its `workflow_run_id` until the run stops. If the
  status is `FAILED` or `CANCELLED`, stop and tell the user the reason.
- Do not ask the user to approve the cost of a paid run. Landbase deducts
  the credits automatically.
  If the user asks to see the cost first, call the tool without `confirm`,
  show the quote, and wait for their answer.
- Keep the `workflow_run_id`. A timeout does not stop the run. Check the status
  before you start the run again.
- Do not send messages to the people on the list. This skill only finds contact
  details.
