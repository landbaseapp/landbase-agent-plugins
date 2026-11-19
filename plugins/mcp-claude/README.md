# Landbase

Find, research, and analyze companies and people using Landbase datasets, web research, and data you provide.

Use Landbase to discover companies and people, research or evaluate them, and answer questions across records, lists, and populations.

Discover by custom criteria: Find people or companies using calculated attributes. For example, find companies with substantial platform-engineering teams and compare their security-to-platform-engineering staffing ratios.

Connect data, uncover signals: Combine existing records with external context. For example, identify portfolio companies with more engineering than sales job postings.

Refresh and reclassify records: Update information and reassess which records fit. For example, refresh a candidate list and identify who appears to fit a role now.

Use Landbase company, people, job-posting and career-history data, web research, and records you provide. Inspect, refine and export datasets; calculate counts and comparisons or analyze available historical data for market research, recruiting, portfolio analysis, sales and other company-and-people workflows.

Bring a comprehensive B2B data platform into Claude: 300M+ verified contacts across 24M+ companies. Landbase is more than just a search engine. It's a compute platform for B2B data: describe the audience you need, then run real-time filters and calculations on the fly to find exactly the right targets.

Optimised for Claude and MCP connections, Landbase supports long-running workflows that combine search, real-time web research, AI qualification and enrichment. Ask your own questions about companies and people, assess their fit, and build context before you reach out.

Find work emails, direct dials and mobile phone numbers through one enrichment system spanning multiple providers. Landbase searches across providers for coverage and quality, then separately verifies email deliverability and phone validity.

The wider Landbase platform adds CRM enrichment and deduplication, integrations with Salesforce, HubSpot and Pipedrive, and connections to go-to-market execution platforms such as Instantly and HeyReach. Match and enrich an existing list, then take the results into your next workflow.

Use it for market research, competitive intelligence, talent and hiring trends, numbers for charts and social posts, ICP/TAM mapping, account-based marketing lists, outbound prospecting and research, meeting and interview preparation, CRM enrichment, and business research on companies or people.

Sign up for free at landbase.com. Pricing is simple: you ask for the work, and Landbase deducts the credits for each step when it runs.

This Claude plugin includes twelve skills and the Landbase MCP connection for search, research, qualification, enrichment and export. The CRM and execution integrations described above are available through the wider Landbase platform; they are not exposed by this plugin’s current MCP tools.

## What you can ask

- "Which Series B fintechs in Europe added 20+ engineers in the last year?"
- "Where do product managers from big tech companies go next?"
- "Which data teams doubled in size in 2026?"
- "Which of my competitors grew their sales team the most this year? Give me the numbers for a LinkedIn post."
- "Find VPs of Sales at fintech companies in London with 50-500 employees."
- "Which of these companies sell to hospitals? Keep only the ones that do."
- "Add industry, revenue and funding to this list."
- "Find out if each company shows prices on its website."
- "Find work emails for these 100 people."
- "Find 500 companies like our best 20 customers."
- "Here is our CRM export. Match it to Landbase and fill in the gaps."
- "Give me this list as a CSV."

## What the plugin contains

- **A connection to the Landbase MCP server** at `https://mcp.landbase.com/mcp`
  (remote, Streamable HTTP). You sign in with your Landbase account through
  OAuth. The plugin does not store a password or an API key.
- **Twelve skills** that show Claude how to use the Landbase tools step by step:

| Skill | What it does |
| --- | --- |
| `get-started` | Checks your account and credit balance, shows what you can ask (including real-time calculations), offers a data test, and lists plans when you need more credits |
| `build-prospect-list` | Builds a list of companies or people from a plain-language request |
| `advanced-search` | The Art of the Possible: gets the largest accurate list with a tight search, a wider search, a merge without duplicates and AI qualification |
| `expand-dataset` | Extends a list with derived signals, owned-data joins, or a related audience while preserving its source |
| `qualify-list` | Checks each row against your yes/no criteria and keeps the rows that pass |
| `research-accounts` | Adds standard attributes or a custom research answer to each row, or looks up one company or person |
| `find-contact-info` | Finds work emails and phone numbers for a list of people |
| `import-and-match` | Uploads your own CSV or JSONL list and matches it to Landbase records |
| `find-lookalike-companies` | Finds companies that are similar to a set of examples |
| `export-list` | Makes a CSV, JSONL or Parquet file and gives you a download link |
| `manage-datasets` | Finds your lists, checks or cancels runs, gets back a search after a timeout, and deletes a list with your approval |
| `market-insights` | Answers market research, competitive intelligence and talent questions with numbers that Landbase computes, ready for a chart or a post |

The plugin has no hooks, scripts or local programs. It runs nothing on your
computer.

## Get started

1. Install the plugin from the Claude directory. In Claude Code, you can also
   add this repository as a marketplace:

   ```
   /plugin marketplace add landbaseapp/landbase-agent-plugins
   /plugin install landbase@landbase-plugins
   ```

2. Sign in with your Landbase account when Claude asks. If you do not have an
   account, sign up at [landbase.com](https://www.landbase.com).
3. Ask for a list, for example "Find Heads of RevOps at B2B SaaS companies in
   the US with 100-500 employees."

## Credits and approvals

Some operations use Landbase credits: research-mode search, qualification,
custom research and contact enrichment. When you ask for one of these, Landbase
deducts the credits when it runs. Claude does not stop to ask you to approve the
cost. Lookalike expansion, attribute enrichment and downloads cost 0 credits.
A dataset deletion needs your approval. To buy more credits, Claude can list the plans and give you a Stripe
checkout link. Nothing is charged until you pay on that page.

## Data and privacy

- **What the plugin sends to Landbase:** your requests (search text,
  qualification questions and research prompts), the IDs of your datasets, and
  files that you ask Claude to upload. Landbase uses them only to do the
  request.
- **What Landbase sends back:** company and people records, which can include
  business contact information, and the results of your workflows.
- **Where the data goes:** the plugin connects only to the Landbase MCP server.
  A download link is a temporary signed link to your file in Landbase storage
  and expires after about 30 minutes.
- **Policies:** [Privacy policy](https://www.landbase.com/legal/privacy-policy)
  and [Terms of service](https://www.landbase.com/legal/terms-of-service).

## Help

- [Landbase MCP documentation](https://docs.landbase.com/guides/mcp/overview)
- [Limits and credits](https://docs.landbase.com/guides/mcp/limits-and-credits)
- [Contact Landbase](https://www.landbase.com/contact)

## License

MIT. See [LICENSE](LICENSE).
