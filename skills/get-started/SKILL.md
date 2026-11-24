---
name: get-started
description: Start with Landbase, which gives agents answers beyond web search by computing custom signals from the user's own data, web data and private datasets. Check the sign-in, select the account, show the credit balance, explain what Landbase can do (computed signals, market research, competitive intelligence, numbers for content, and sales lists), and offer a data test. Use when the user is new to Landbase, asks what Landbase or this MCP can do, asks how many credits they have, is out of credits, or asks whether Landbase data is accurate or how it compares with another data provider.
---

# Get started with Landbase

Landbase gives agents answers beyond web search. It computes custom signals
from three sources: the user's own data (uploads and CRM exports), web data (AI
research and qualification) and Landbase's private datasets on companies,
people, career history and job posts. Each answer and each step makes a new
dataset in the user's Landbase account, with the numbers behind it.

## Offer choices as a pick list

When the user must choose (an account, a first task, who they sell to, a plan),
give 2-4 options that the user can pick.

- If your app has a question tool with clickable options, use it. Examples:
  `AskUserQuestion` in Claude Code, `request_user_input` in Codex.
- If it does not, show a numbered list. Tell the user to answer with a number
  or in their own words.
- Always let the user give an answer that is not in the list.
- Fill the options from real data when you have it, for example the account
  names from `list_accounts`.

## Steps

Use only the steps that the request needs. For a question about data quality,
or a request to test the data, go to step 4.

1. **Check the sign-in and the account.** Call `list_accounts`.
   - If the result is `UNAUTHORIZED`, tell the user to reconnect the Landbase
     connector.
   - If the user has more than one account, show the account names as a pick
     list. Pass the selected `account_id` on every later call.
2. **Show the credit balance.** Call `get_credit_balance`. Tell the user the
   number of credits. These steps use credits: full search execution,
   qualification, custom research and contact enrichment. Landbase deducts the
   credits when the step runs. Do not ask the user to approve the cost. If the
   user asks to see the cost first, show the quote and wait for their answer.
   Lookalike expansion, attribute enrichment and downloads cost 0 credits.
3. **Show what Landbase can do.** Lead with computed answers, not with a list
   of tools. Tell the user that Landbase is not only a filter on a database: it
   calculates new signals in real time, and it is for more than sales lists.
   Give one or two examples from each group, and use the skill that fits.

   Computed signals (the `market-insights` and `expand-dataset` skills):
   - "Which Series B fintechs in Europe added 20+ engineers in the last year?"
   - "Which data teams doubled in size in 2026?"
   - "Rank these accounts by the median tenure of their engineers."

   Market research and competitive intelligence (the `market-insights`
   skill):
   - "How many B2B SaaS companies in Texas have 50-200 employees, by city?"
   - "Where do product managers from big tech companies go next?"
   - "Which of my competitors grew their sales team the most this year?"

   Content and infographics (the `market-insights` skill):
   - "Give me the numbers for a LinkedIn post on AI hiring in fintech."

   Sales lists and next steps:
   - "Find VPs of Sales at fintech companies in London": the
     `build-prospect-list` skill.
   - "Find every mechanic in Toronto": the `advanced-search` skill.
   - "Keep only the companies that sell to hospitals": the `qualify-list`
     skill.
   - "Add funding and revenue to each company": the `research-accounts` skill.
   - "Find work emails for these people": the `find-contact-info` skill.
   - "Find companies like our best customers": the `find-lookalike-companies`
     skill.
   - "Here is our CRM export": the `import-and-match` skill.
   - "Give me this list as a CSV": the `export-list` skill.
   - "What lists do I have?": the `manage-datasets` skill.
4. **Offer a data test.** Tell the user that, if they want to check that the
   data is good before they rely on it, Landbase can run a data test. Offer it
   when the user is new, asks whether the data is accurate, or compares
   Landbase with another provider. Do not claim that Landbase is better, and
   do not criticize other providers: the test shows it.
   - If the user has not named anything to test, ask for 3-5 companies or
     people that they know well, for example their own company, their
     customers or their team. Do not add other options.
   - When the user names companies or people, run the test at once. Look up
     each one with `match_company` or `match_person` (0 credits). Show what
     Landbase returns for each one. Do not say that a record is correct: ask
     the user to compare it with what they know.
   - Make at most one optional suggestion, for example a larger test: a small
     list for a segment that the user knows (the `build-prospect-list` skill),
     to compare with their own list.
5. **Help the user start.** If the user does not have a request, ask what to
   do first as a pick list, for example:
   1. Answer a market or competitor question with computed numbers.
   2. Build a list of companies or people.
   3. Run a data test on companies I know.
   4. Something else.

   For a first list, ask who they sell to. Then use the `build-prospect-list`
   skill with a default search.

## Insufficient credits

If a tool returns `INSUFFICIENT_CREDITS`, tell the user the account does not
have enough credits and stop that operation. Do not retry it.

## Rules

- Use only tools advertised by this connection.
- When the user asks for a paid step, start it with `confirm=true`. Do not ask
  the user to approve the cost. If the user asks to see the cost first, call the
  tool without `confirm`, show the quote, and wait for their answer.
