# Landbase — Codex Plugin

Run Landbase B2B prospecting workflows from inside Codex CLI with four CLI-wrapping skills. Sibling to the Claude Code plugin under `plugin/`.

## Install

```
codex plugin marketplace add landbaseapp/landbase-cli
```

Then enable `landbase-cli` in `/plugins`. The plugin's `interface.defaultPrompt` array surfaces four starter prompts in the plugin browser, one per CLI-wrapping skill.

## Prerequisites — install the `landbase-cli` binary

The plugin wraps the `landbase-cli` binary; it does NOT ship one. After enabling the plugin, invoke the `landbase-cli:setup` skill — it checks your PATH, runs `landbase-cli --version`, compares it against the plugin's declared minimum, and prints the platform-appropriate installer snippet if the binary is missing or outdated.

- **macOS / Linux:** `curl -fsSL https://cli.landbase.com/install.sh | bash`
- **Windows (PowerShell):** `$ProgressPreference = 'SilentlyContinue'; irm https://cli.landbase.com/install.ps1 | iex`

You'll also need an API key — invoke the `landbase-cli:auth` skill once after the binary is installed.

## Skills

| Skill | Purpose |
|---|---|
| `landbase-cli:search` | NL prospecting search; downloads results locally. |
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
