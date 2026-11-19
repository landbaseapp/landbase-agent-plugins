# Landbase — Claude Code Plugin

Find, research, and analyze companies and people using Landbase datasets, web research, and data you provide.

Use Landbase to discover companies and people, research or evaluate them, and answer questions across records, lists, and populations.

Discover by custom criteria: Find people or companies using calculated attributes. For example, find companies with substantial platform-engineering teams and compare their security-to-platform-engineering staffing ratios.

Connect data, uncover signals: Combine existing records with external context. For example, identify portfolio companies with more engineering than sales job postings.

Refresh and reclassify records: Update information and reassess which records fit. For example, refresh a candidate list and identify who appears to fit a role now.

Use Landbase company, people, job-posting and career-history data, web research, and records you provide. Inspect, refine and export datasets; calculate counts and comparisons or analyze available historical data for market research, recruiting, portfolio analysis, sales and other company-and-people workflows.

## Install

```
/plugin marketplace add landbaseapp/landbase-cli
/plugin install landbase-cli@landbase-plugins
```

## Prerequisites — install the `landbase-cli` binary

The plugin wraps the `landbase-cli` binary; it does NOT ship one. After installing the plugin, run `/landbase-cli:setup` — it will check your PATH and print the platform-appropriate installer snippet if needed.

- **macOS / Linux:** `curl -fsSL https://cli.landbase.com/install.sh | bash`
- **Windows (PowerShell):** `$ProgressPreference = 'SilentlyContinue'; irm https://cli.landbase.com/install.ps1 | iex`

You'll also need an API key — run `/landbase-cli:auth` once after the binary is installed.

The bundled search command uses default mode to find companies and people. For computed counts, ratios, or comparisons, run `landbase-cli search --mode=research "<question>"` directly and follow the proposed query and confirmation flow.

Dataset commands `match` and `enrich` require CLI **0.3.0 or later**. Plugin setup still accepts `0.2.0` for the basic wrappers; update the CLI before using these dataset commands.

## Slash commands

| Command | Purpose |
|---|---|
| `/landbase-cli:search "<query>"` | Find companies and people in natural language; download results locally. |
| `/landbase-cli:continue <label> <followup>` | Multi-turn refinement under a named session. |
| `/landbase-cli:auth` | Set or rotate the API key via the CLI's auth flow. |
| `/landbase-cli:setup` | Verify the binary is installed; print install snippet if missing. |

Each command except `/landbase-cli:setup` declares `allowed-tools: Bash(landbase-cli *)` in its frontmatter, so CLI invocations run without permission prompts. No other tools are pre-approved.

## Uninstall

```
/plugin uninstall landbase-cli
/plugin marketplace remove landbase-plugins
```

Uninstalling removes the slash commands and the per-command `allowed-tools` entries. It does NOT remove the `landbase-cli` binary or `~/.landbase/config.json` — those are user-owned.

## Auto-publish behavior (CLI 0.3.0+)

`landbase-cli` v0.3.0 added auto-publish on `search --download`: when the agent run produces a dataset but no signed `download_url`, the CLI now auto-triggers the publish workflow and waits for the resulting download URL before exiting. That removes the headline `DOWNLOAD_FAILED` failure mode the slash commands hit on older CLIs.

If a query genuinely doesn't produce a downloadable dataset (e.g. the agent answers in prose only), the CLI still surfaces `DOWNLOAD_FAILED` and the slash commands render the documented action hint to re-run with a more specific batch-style query.

## Multi-host note

This plugin is purely additive metadata for Claude Code — non-Claude-Code hosts see no change.

## Version & compatibility

The plugin has its own semver `version` (see `plugin/.claude-plugin/plugin.json`), independent of the CLI binary. It declares the oldest compatible CLI version under `compatibility.landbaseCliMin`. `/landbase-cli:setup` reads that value and warns if your installed `landbase-cli` is older.

The release workflow validates that `package.json`'s `version` matches the pushed tag and that `plugin.json`'s `version` and `compatibility.landbaseCliMin` are valid semver. It does NOT require plugin and CLI versions to match — plugin-only patches can ship at the next CLI release tag without forcing a CLI bump.

## Workflow guidance

- **Staffing analysis:** Show the observed security and platform-engineering headcounts alongside the calculated ratio.
- **Portfolio hiring analysis:** Show the observed job-posting counts by function. Describe the comparison as posting activity; postings alone do not establish actual hires.
- **Candidate refresh:** Show original and observed employers and roles side by side, keep uncertain matches visible for review, and summarize the results by talent pool.
