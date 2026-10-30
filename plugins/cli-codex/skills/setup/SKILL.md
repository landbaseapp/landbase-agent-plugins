---
name: landbase-cli:setup
description: Verify the landbase-cli binary is installed and meets the plugin's minimum version.
---

Check whether the `landbase-cli` binary is on the user's PATH, and if so, whether it meets the plugin's declared minimum version.

**Permissions.** If the user wants zero-prompt CLI invocations, explain that they can choose `/permissions` → Auto, or run `landbase-cli config permissions --yes` themselves in their own terminal. The latter writes a Codex rules-engine `prefix_rule` to `~/.codex/rules/landbase-cli.rules`. Do not run this permission-changing command or change the approval mode for the user; leave that choice to them. The plugin itself cannot pre-approve commands.

The diagnostic probes below also use `command -v`, `where.exe`, and `uname` — these are read-only shell builtins / utilities and do NOT depend on the per-binary allowlist (which only covers `landbase-cli`). Codex may prompt the first time you invoke them under non-Auto permissions.

**Do NOT execute any installer.** Even if permissions would allow it, do not run `curl | bash`, `irm | iex`, or any equivalent. The job of this skill is to diagnose and instruct — not to install.

Run this probe via Bash:

```
command -v landbase-cli 2>/dev/null || where.exe landbase-cli 2>NUL || echo "NOT_FOUND"
```

Branch on the output:

**If the binary is found**, run `landbase-cli --version` to capture the installed version, then check it against the plugin's declared minimum.

The minimum compatible CLI version is declared in `codex-plugin/.codex-plugin/plugin.json` under `compatibility.landbaseCliMin`. Read that file via the following resolution rule, in order:

1. **If Codex injects a runtime env var pointing at the plugin root** (e.g. `CODEX_PLUGIN_ROOT`), use it: `${CODEX_PLUGIN_ROOT}/.codex-plugin/plugin.json`.
2. **Otherwise resolve relative to this skill's own location** at runtime (the skill body is at `<plugin-root>/skills/setup/SKILL.md`, so `../../.codex-plugin/plugin.json` from this skill's directory points at the manifest).
3. **If neither resolves**, tell the user the version check is unavailable on this host and link to the manifest path so they can read `landbaseCliMin` themselves. Do NOT fall back to a hard-coded path.

Parse the `compatibility.landbaseCliMin` field. Both `landbase-cli --version` and `landbaseCliMin` are semver `X.Y.Z` strings. Compare them using this exact algorithm:

1. Strip any pre-release/build suffix from the installed version: discard everything from the first `-` or `+` onward. (e.g. `0.3.0-dev` → `0.3.0`, `0.3.0+abc` → `0.3.0`. The CLI's own dev sentinel is `0.0.0-dev`.) Treat the stripped value as the comparable version.
2. Split each of the two versions on `.` into three integers: `[major, minor, patch]`. If either side fails to parse as three integers, refuse the check and ask the user to re-run after upgrading.
3. Compare lexicographically: installed `>=` minimum if `(installedMajor, installedMinor, installedPatch) >= (minMajor, minMinor, minPatch)` under tuple ordering.

Branch on the comparison:

- **Installed >= landbaseCliMin** → tell the user the plugin is ready to use, with the installed version. Suggest they try the `landbase-cli:search` skill next (or `landbase-cli:auth` first if they haven't set an API key).
- **Installed < landbaseCliMin** → warn the user the installed CLI is **outdated** for this plugin. Print the installed version, the required minimum, and tell them to run the install snippet again to upgrade (the snippets below pull `latest`, which will satisfy the minimum). Don't auto-execute the installer.
- **Installed is `0.0.0-dev`** (the dev sentinel) → tell the user they're running a non-tagged dev build; can't determine compatibility. Suggest they install a tagged release via the snippet below.

**If the output is `NOT_FOUND`**, detect the platform and print the matching install snippet verbatim. Explicitly tell the user to copy/paste it into their own shell. After they install, ask them to re-invoke the `landbase-cli:setup` skill to verify.

Platform detection — try in order:

- Run `uname` via Bash. If it outputs `Darwin` or `Linux`, use the macOS/Linux snippet.
- If `uname` is unavailable (Windows with no WSL/bash), or the shell reports no such command, use the Windows snippet.

**macOS / Linux snippet (copy-paste, single line):**

```
curl -fsSL https://cli.landbase.com/install.sh | bash
```

**Windows (PowerShell) snippet (copy-paste, single line):**

```
$ProgressPreference = 'SilentlyContinue'; irm https://cli.landbase.com/install.ps1 | iex
```

After printing the correct snippet, end with: "Run the snippet above in your own shell, then re-invoke the `landbase-cli:setup` skill to confirm the binary is on PATH."
