# Landbase Agent Plugins

A starter Claude Code plugin for connecting to a remote MCP server and packaging client skills.

## Structure

```
landbase-agent-plugins/
├── .claude-plugin/
│   └── plugin.json            # Plugin metadata
└── .mcp.json                  # MCP server configuration
```

## Extension Options

### Skills (`skills/`)

Skills are the preferred format for both model-invoked capabilities and user-invoked slash commands. Create a `SKILL.md` in a subdirectory:

**Model-invoked skill** (activated by task context):

```yaml
---
name: skill-name
description: Trigger conditions for this skill
version: 1.0.0
---
```

**User-invoked skill** (slash command — `/skill-name`):

```yaml
---
name: skill-name
description: Short description for /help
argument-hint: <arg1> [optional-arg]
allowed-tools: [Read, Glob, Grep]
---
```

### MCP Servers (`.mcp.json`)

Configure external tool integration via Model Context Protocol:

```json
{
  "server-name": {
    "type": "http",
    "url": "https://mcp.landbase.com/mcp"
  }
}
```

## Usage

The configured Landbase MCP server is available to the plugin over Streamable HTTP.
