# Landbase — Claude Code Plugin

Run Landbase B2B prospecting workflows from inside Claude Code with four slash commands.

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

## Slash commands

| Command | Purpose |
|---|---|
| `/landbase-cli:search "<query>"` | NL prospecting search; downloads results locally. |
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
