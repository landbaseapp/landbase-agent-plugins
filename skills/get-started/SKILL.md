---
name: get-started
description: Start with Landbase - check the sign-in, select the account, show the credit balance and plans, and explain what Landbase can do. Use when the user is new to Landbase, asks what Landbase can do, asks how many credits they have, is out of credits, or asks about plans, pricing or an upgrade.
---

# Get started with Landbase

Landbase has B2B data on companies and people. Each step (search, qualify,
research, enrich, export) makes a new dataset in the user's Landbase account.

## Steps

1. **Check the sign-in and the account.** Call `list_accounts`.
   - If the result is `UNAUTHORIZED`, tell the user to reconnect the Landbase
     connector.
   - If the user has more than one account, show the account names and ask
     which one to use. Pass that `account_id` on every later call.
2. **Show the credit balance.** Call `get_credit_balance`. Tell the user the
   number of credits. These steps use credits: research-mode search,
   qualification, custom research, contact enrichment and lookalike
   expansion. Landbase gives a quote before each of them, and you ask the user
   before you start. Attribute enrichment and downloads cost 0 credits, but you
   also ask the user before them.
3. **Show what Landbase can do.** Give the user examples that they can ask
   for, and use the skill that fits:
   - "Find VPs of Sales at fintech companies in London": the
     `build-prospect-list` skill.
   - "Keep only the companies that sell to hospitals": the `qualify-list`
     skill.
   - "Add funding and revenue to each company": the `research-accounts` skill.
   - "Find work emails for these people": the `find-contact-info` skill.
   - "Find companies like our best customers": the `find-lookalike-companies`
     skill.
   - "Here is our CRM export": the `import-and-match` skill.
   - "Give me this list as a CSV": the `export-list` skill.
   - "What lists do I have?": the `manage-datasets` skill.
4. **Start with a small first list.** If the user does not have a request, ask
   who they sell to. Then use the `build-prospect-list` skill with a default
   search.

## Plans and more credits

Use this section when the balance is too low, a tool returns
`INSUFFICIENT_CREDITS`, or the user asks about plans or pricing.

1. Do not try the failed step again. Tell the user that the account does not
   have enough credits.
2. Call `list_plans`. Show the name, the price and the monthly credits of each
   plan. The account's current plan is not in the list.
3. Let the user select a plan. Do not select a plan for the user.
4. After the user selects a plan, call `subscribe_plan` with its `plan_id`.
   Give the user the `checkout_url`. Nothing is charged until the user pays on
   that page. The link expires after 24 hours.
5. When the user says that they paid, call `get_credit_balance` to make sure
   that the credits are there. Then continue the step that failed.

## Rules

- Do not call `subscribe_plan` before the user selects a plan.
- Do not start a paid step without a quote and the user's approval.
- Do not put the checkout link in a public place.
