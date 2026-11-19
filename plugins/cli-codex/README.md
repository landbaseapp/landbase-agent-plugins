# Landbase — Codex Plugin

Find, research, and analyze companies and people using Landbase datasets, web research, and data you provide.

Use Landbase to discover companies and people, research or evaluate them, and answer questions across records, lists, and populations.

Discover by custom criteria: Find people or companies using calculated attributes. For example, find companies with substantial platform-engineering teams and compare their security-to-platform-engineering staffing ratios.

Connect data, uncover signals: Combine existing records with external context. For example, identify portfolio companies with more engineering than sales job postings.

Refresh and reclassify records: Update information and reassess which records fit. For example, refresh a candidate list and identify who appears to fit a role now.

Use Landbase company, people, job-posting and career-history data, web research, and records you provide. Inspect, refine and export datasets; calculate counts and comparisons or analyze available historical data for market research, recruiting, portfolio analysis, sales and other company-and-people workflows.

## Install

```
codex plugin marketplace add landbaseapp/landbase-cli
```

Then enable `landbase-cli` in `/plugins`. The plugin's `interface.defaultPrompt` array surfaces research questions and session/setup prompts in the plugin browser.

## Prerequisites — install the `landbase-cli` binary

The plugin wraps the `landbase-cli` binary; it does NOT ship one. After enabling the plugin, invoke the `landbase-cli:setup` skill — it checks your PATH, runs `landbase-cli --version`, compares it against the plugin's declared minimum, and prints the platform-appropriate installer snippet if the binary is missing or outdated.

- **macOS / Linux:** `curl -fsSL https://cli.landbase.com/install.sh | bash`
- **Windows (PowerShell):** `$ProgressPreference = 'SilentlyContinue'; irm https://cli.landbase.com/install.ps1 | iex`

You'll also need an API key — invoke the `landbase-cli:auth` skill once after the binary is installed.

The bundled search command uses default mode to find companies and people. For computed counts, ratios, or comparisons, run `landbase-cli search --mode=research "<question>"` directly and follow the proposed query and confirmation flow.

Dataset commands `match` and `enrich` require CLI **0.3.0 or later**. Plugin setup still accepts `0.2.0` for the basic wrappers; update the CLI before using these dataset commands.

## Skills

| Skill | Purpose |
|---|---|
| `landbase-cli:search` | Find companies and people in natural language; download results locally. |
| `landbase-cli:continue` | Multi-turn refinement under a named session. |
| `landbase-cli:auth` | Set or rotate the API key via the CLI's auth flow. |
| `landbase-cli:setup` | Verify the binary is installed and meets the plugin's minimum version. |
## Permissions — zero-prompt invocations

Codex's plugin spec has no per-skill allowlist; the plugin itself cannot pre-approve `landbase-cli` invocations. To run the four CLI-wrapping skills without per-call prompts, use one of:

- **Session-wide Auto mode:** type `/permissions` and pick Auto. Applies to the current session.
- **`landbase-cli config permissions --yes`:** writes a Codex [rules-engine](https://developers.openai.com/codex/rules) `prefix_rule(pattern = ["landbase-cli"], decision = "allow")` block to `~/.codex/rules/landbase-cli.rules`. Persists across sessions, scoped to the `landbase-cli` binary only.

## Multi-host note

This plugin is purely additive metadata for Codex CLI plugin consumers — non-plugin Codex sessions see no change.

## Version & compatibility

The plugin has its own semver `version` (see `codex-plugin/.codex-plugin/plugin.json`), independent of the CLI binary and of the Claude Code plugin's version. It declares the oldest compatible CLI version under `compatibility.landbaseCliMin` (a non-standard custom field — Codex's plugin spec does not define a `compatibility` block, but ignores unknown top-level fields). The `landbase-cli:setup` skill reads that value and warns if your installed `landbase-cli` is older.

The release workflow validates that `codex-plugin/.codex-plugin/plugin.json:version` is valid semver, that `compatibility.landbaseCliMin` (when present) is valid semver, and that `.agents/plugins/marketplace.json:plugins[0].source.ref` matches the pushed tag. Plugin-only patches can ship at the next CLI release tag without forcing a CLI bump.

## Workflow guidance

- **Staffing analysis:** Show the observed security and platform-engineering headcounts alongside the calculated ratio.
- **Portfolio hiring analysis:** Show the observed job-posting counts by function. Describe the comparison as posting activity; postings alone do not establish actual hires.
- **Candidate refresh:** Show original and observed employers and roles side by side, keep uncertain matches visible for review, and summarize the results by talent pool.
