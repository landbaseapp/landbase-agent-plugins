---
description: Verify the landbase-cli binary is installed; print the install snippet if missing.
argument-hint: (no arguments)
---

Check whether the `landbase-cli` binary is on the user's PATH.

**Do NOT execute any installer.** Even if permissions would allow it, do not run `curl | bash`, `irm | iex`, or any equivalent. The job of this command is to diagnose and instruct — not to install.

Use the Bash tool to run this probe (request permission if needed — no `allowed-tools` is declared for this command on purpose):

```
command -v landbase-cli 2>/dev/null || where.exe landbase-cli 2>/dev/null || echo "NOT_FOUND"
```

Branch on the output:

**If the binary is found**, first try:

```
landbase-cli version --check
```

If it exits 0 and prints valid JSON, parse `current`, `latest`, `update_available`, `upgrade_command`, `highlights`, and `release_notes`.

If `landbase-cli version --check` is unsupported or exits non-zero (older CLIs do not have it), fall back to:

```
landbase-cli --version
```

Then fetch the latest published version with:

```
curl -fsSL https://cli.landbase.com/latest/version.txt
```

Use that fallback data to compare installed vs. latest. If the curl call fails, continue with the installed-version compatibility check below and say that the latest-version check could not be completed.

After capturing the installed version, check it against the plugin's declared minimum.

Read the manifest at **`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`** (this env var is set by Claude Code to the plugin's installed root). If `CLAUDE_PLUGIN_ROOT` is not set, refuse the version check and tell the user the plugin runtime didn't expose the plugin root — they should report this. Do NOT fall back to a hard-coded path.

Parse the `compatibility.landbaseCliMin` field. Both `landbase-cli --version` and `landbaseCliMin` are semver `X.Y.Z` strings. Compare them using this exact algorithm:

1. Strip any pre-release/build suffix from the installed version: discard everything from the first `-` or `+` onward. (e.g. `0.3.0-dev` → `0.3.0`, `0.3.0+abc` → `0.3.0`. The CLI's own dev sentinel is `0.0.0-dev`.) Treat the stripped value as the comparable version.
2. Split each of the two versions on `.` into three integers: `[major, minor, patch]`. If either side fails to parse as three integers, refuse the check and ask the user to re-run after upgrading.
3. Compare lexicographically: installed `>=` minimum if `(installedMajor, installedMinor, installedPatch) >= (minMajor, minMinor, minPatch)` under tuple ordering.

Branch on the comparison:

- **Installed >= landbaseCliMin** → tell the user the plugin is ready to use, with the installed version. Suggest they try `/landbase-cli:search "<query>"` next (or `/landbase-cli:auth` first if they haven't set an API key).
- **Installed < landbaseCliMin** → warn the user the installed CLI is **outdated** for this plugin. Print the installed version, the required minimum, and tell them to run the install snippet again to upgrade (the snippets below pull `latest`, which will satisfy the minimum). Don't auto-execute the installer.
- **Installed is `0.0.0-dev`** (the dev sentinel) → tell the user they're running a non-tagged dev build; can't determine compatibility. Suggest they install a tagged release via the snippet below.

Also branch on the latest-version check:

- **Latest check says `update_available: true` OR fallback latest > installed** → tell the user the installed CLI works but is not current. Print installed version, latest version, and the upgrade command (`landbase-cli update` when available; otherwise use the install snippet below). If highlights are available, list up to three of them so the user knows what they gain by upgrading. Include `release_notes` when present. Do not auto-execute the upgrade.
- **Latest check succeeds and installed >= latest** → say the CLI is current.
- **Latest check fails** → do not block setup; say the plugin compatibility check passed or failed based on `landbaseCliMin`, and mention that the latest-release check could not be completed.

**If the output is `NOT_FOUND`**, detect the platform and print the matching install snippet verbatim. Explicitly tell the user to copy/paste it into their own shell. After they install, ask them to re-run `/landbase-cli:setup` to verify.

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

After printing the correct snippet, end with: "Run the snippet above in your own shell, then invoke `/landbase-cli:setup` again to confirm the binary is on PATH."
