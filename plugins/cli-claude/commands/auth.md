---
description: Set or rotate the Landbase API key via the CLI's interactive prompt.
argument-hint: (no arguments)
allowed-tools: Bash(landbase-cli *)
---

Save or rotate the user's Landbase API key.

Invoke `landbase-cli auth` via the Bash tool (the `allowed-tools` frontmatter pre-approves this). Capture exit code and stderr.

```
landbase-cli auth
```

Do NOT echo, print, or display the API key in any form. The key itself never passes through the conversation — only the CLI sees it. Do NOT print the value of `$LANDBASE_API_KEY` or read `~/.landbase/config.json` back to the user.

**On exit code 0:** the CLI wrote the key to `~/.landbase/config.json`. Tell the user "API key saved" — nothing more. Suggest they try `/landbase-cli:search "<query>"` to verify it works end-to-end.

**On non-zero exit code:** stderr will contain `{"error":{"code":"AUTH_FAILED","message":"..."}}`. Parse it and branch on the message text (substring match — the CLI may evolve the exact wording):

- **Message contains `"No TTY available"` or `"non-interactive"`** → the user has no `LANDBASE_API_KEY` env var and Claude Code's shell has no TTY for the CLI's auth flow (which now defaults to browser OAuth via `auth login`). Tell the user **two ways** to continue. Both are shell-history-safe; the OAuth path is the recommended primary because it doesn't require the user to ever paste their key into a shell:
  1. **Recommended:** run `landbase-cli auth login` directly in their own terminal — that gets a TTY, opens a browser for OAuth, and writes the API key to `~/.landbase/config.json`. Once done, future `/landbase-cli:search` calls inherit the saved key automatically.
  2. **Alternative (env var, for users who already have a key string):** in their own shell, run `read -s LANDBASE_API_KEY && export LANDBASE_API_KEY` — the `-s` flag suppresses echo and the assignment runs in-line so the value never lands in `.zsh_history` / `.bash_history`. Then restart Claude Code (so the env var propagates into its shell) and re-run `/landbase-cli:auth`. **Never** suggest a plain `export LANDBASE_API_KEY=<value>` — that lands the secret in shell history.
- **Anything else** (e.g. the server rejected the key) → surface the message verbatim and suggest they check the key and try again. Do NOT auto-retry.

Do NOT auto-retry. Do NOT prompt for the key inside the conversation.
