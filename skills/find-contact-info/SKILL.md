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
5. **Get a quote.** Call `enrich_contacts` without `confirm`. The result is
   `needs_confirmation` with the row count and the estimated credits. Show them
   to the user and ask for approval.
6. **Run.** After the user agrees, call `enrich_contacts` again with the same
   arguments and `confirm=true`. Call `get_workflow_run` with the
   `workflow_run_id` until the status is `SUCCEEDED`. A large list can take a
   long time. Continue with the same run ID.
7. **Show the result.** Use the `output_dataset_id`. Call `get_dataset_fields`
   to find the email and phone columns. Use `preview_dataset` with SQL to count
   the rows that have an email or a phone number, and show some examples.
8. **Offer a file.** To give the user a file, use the `export-list` skill.

## Rules

- Use an `output_dataset_id` only when its run status is `SUCCEEDED`.
  `transform_dataset` can return while its run is `RUNNING`. Then call
  `get_workflow_run` with its `workflow_run_id` until the run stops. If the
  status is `FAILED` or `CANCELLED`, stop and tell the user the reason.
- Do not start a paid run without a quote and the user's approval.
- Keep the `workflow_run_id`. A timeout does not stop the run. Check the status
  before you start the run again.
- Do not send messages to the people on the list. This skill only finds contact
  details.
