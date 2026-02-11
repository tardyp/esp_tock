---
name: opencode-config
description: Complete reference for configuring OpenCode (agents, tools, permissions, models)
license: MIT
compatibility: opencode
metadata:
  category: reference
  scope: opencode-configuration
---

## What I do

I provide comprehensive configuration guidance for OpenCode, covering all aspects of setup and customization.

When you load me, you get instant access to detailed information about:
- Configuration file locations and precedence
- Agent configuration (primary and subagents)
- Tools and permissions management
- Model and provider setup
- Skills, commands, and keybinds
- Advanced features (MCP servers, plugins, formatters)

## When to use me

Use this skill when you need to:
- Configure OpenCode agents (create, customize, or troubleshoot)
- Set up permissions for tools and agents
- Understand configuration file structure and precedence
- Configure models and providers
- Set up custom tools, skills, or commands
- Troubleshoot configuration issues

## Configuration file basics

### Locations and precedence (highest to lowest)

1. **Inline config**: `OPENCODE_CONFIG_CONTENT` env var (runtime overrides)
2. **`.opencode` directories**: Agents, commands, plugins (project-specific)
3. **Project config**: `opencode.json` in project root
4. **Custom config**: `OPENCODE_CONFIG` env var path
5. **Global config**: `~/.config/opencode/opencode.json`
6. **Remote config**: `.well-known/opencode` (organizational defaults)

### Key principle: Configs are MERGED, not replaced
- Later configs override earlier ones for CONFLICTING keys only
- Non-conflicting settings from all levels are preserved
- Example: Global sets `theme`, project sets `model` → both are active

### Format support
- JSON: `opencode.json`
- JSONC: `opencode.jsonc` (supports comments)
- Schema: `https://opencode.ai/config.json` (enables autocomplete)

### Variable substitution

**Environment variables**:
```json
"model": "{env:OPENCODE_MODEL}"
```

**File contents**:
```json
"instructions": "{file:./custom-instructions.md}"
```
Paths are relative to config file or absolute (`/`, `~`)

## Agent configuration

### Agent types

**Primary agents**: Main assistants you interact with directly
- Switch with Tab key or configured keybind
- Examples: `build`, `plan`, custom agents

**Subagents**: Specialized assistants invoked for specific tasks
- Invoked by primary agents via Task tool
- Manually invocable with `@mention`
- Examples: `general`, `explore`, custom subagents

### Agent configuration options

**Via JSON** (`opencode.json`):
```json
{
  "agent": {
    "my-agent": {
      "description": "Brief description for when to use this agent",
      "mode": "primary",  // or "subagent" or "all"
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "{file:./prompts/my-agent.txt}",
      "temperature": 0.2,
      "hidden": false,  // subagents only
      "maxSteps": 10,   // limit agentic iterations
      "tools": {
        "write": true,
        "edit": true,
        "bash": true,
        "skill": true,
        "task": true
      },
      "permission": {
        "bash": {
          "*": "ask",
          "git status*": "allow"
        },
        "edit": "allow",
        "task": {
          "*": "deny",
          "my-subagent": "allow"
        }
      }
    }
  }
}
```

**Via Markdown** (`.opencode/agents/my-agent.md`):
```markdown
---
description: Brief description
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.2
color: "#FF6B35"
hidden: false
maxSteps: 10
tools:
  write: true
  edit: true
  bash: true
permission:
  bash:
    "*": "ask"
    "git status*": "allow"
  edit: allow
---

Your system prompt goes here.
Instructions for the agent's behavior.
```

### Agent options reference

| Option | Description | Values/Format |
|--------|-------------|---------------|
| `description` | What the agent does (REQUIRED) | String, brief |
| `mode` | Agent type | `"primary"`, `"subagent"`, `"all"` |
| `model` | Override model for this agent | `"provider/model-id"` |
| `prompt` | Custom system prompt | String or `{file:path}` |
| `temperature` | Response randomness | `0.0-1.0` (0.0=deterministic) |
| `hidden` | Hide from @ autocomplete (subagents) | `true`/`false` |
| `maxSteps` | Max agentic iterations before text-only | Number |
| `color` | Agent color in UI | Hex code `"#RRGGBB"` |
| `tools` | Tool access control | Object (see tools section) |
| `permission` | Action permissions | Object (see permissions section) |

### Default agent

Set which primary agent starts by default:
```json
{
  "default_agent": "plan"  // Must be a primary agent
}
```

## Tools configuration

### Built-in tools

| Tool | Purpose | Permission Key |
|------|---------|----------------|
| `bash` | Execute shell commands | `permission.bash` |
| `edit` | Modify existing files | `permission.edit` |
| `write` | Create/overwrite files | Controlled by `permission.edit` |
| `read` | Read file contents | `permission.read` |
| `grep` | Search file contents (regex) | `permission.grep` |
| `glob` | Find files by pattern | `permission.glob` |
| `list` | List directory contents | `permission.list` |
| `patch` | Apply patches | Controlled by `permission.edit` |
| `skill` | Load skill definitions | `permission.skill` |
| `task` | Launch subagents | `permission.task` |
| `todowrite` | Manage todo lists | `permission.todowrite` |
| `todoread` | Read todo lists | `permission.todoread` |
| `webfetch` | Fetch web content | `permission.webfetch` |
| `question` | Ask user questions | `permission.question` |
| `lsp` | LSP code intelligence (experimental) | `permission.lsp` |

### Enable/disable tools

**Global**:
```json
{
  "tools": {
    "write": true,
    "bash": true,
    "skill": false
  }
}
```

**Per agent**:
```json
{
  "agent": {
    "plan": {
      "tools": {
        "write": false,
        "edit": false,
        "bash": false
      }
    }
  }
}
```

**Wildcards** (MCP tools):
```json
{
  "agent": {
    "readonly": {
      "tools": {
        "mymcp_*": false,
        "write": false
      }
    }
  }
}
```

## Permissions

### Permission actions

- `"allow"` — Run without approval
- `"ask"` — Prompt for approval
- `"deny"` — Block the action

### Global permissions

**Simple**:
```json
{
  "permission": "allow"  // All tools allowed
}
```

**Specific tools**:
```json
{
  "permission": {
    "*": "ask",      // Default for all
    "bash": "allow",
    "edit": "deny"
  }
}
```

### Granular permissions (pattern matching)

```json
{
  "permission": {
    "bash": {
      "*": "ask",                  // Default: ask
      "git *": "allow",            // Allow all git commands
      "git push*": "deny",         // Deny git push
      "npm install*": "allow",
      "rm *": "deny"
    },
    "edit": {
      "*": "deny",                           // Default: deny
      "packages/*/src/**/*.ts": "allow",     // Allow specific paths
      "*.md": "allow"                        // Allow markdown
    },
    "read": {
      "*": "allow",
      "*.env": "deny",             // Block .env files
      "*.env.*": "deny",
      "*.env.example": "allow"     // Except examples
    },
    "task": {
      "*": "deny",                 // Block all subagents
      "android-compilation": "allow"  // Except specific one
    },
    "skill": {
      "*": "allow",
      "internal-*": "deny",        // Block internal skills
      "experimental-*": "ask"      // Ask for experimental
    }
  }
}
```

### Permission pattern matching

- `*` matches zero or more of any character
- `?` matches exactly one character
- Last matching rule wins
- Put `*` first, specific rules after

### Special permissions

- `external_directory` — Triggered when accessing files outside project
- `doom_loop` — Triggered when same tool call repeats 3x identically
- Both default to `"ask"`

### Per-agent permissions

Agent permissions override global config:

```json
{
  "permission": {
    "bash": "ask"
  },
  "agent": {
    "build": {
      "permission": {
        "bash": {
          "*": "ask",
          "git status*": "allow"
        }
      }
    }
  }
}
```

In markdown agents:
```yaml
---
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
---
```

## Models and providers

### Model configuration

```json
{
  "model": "anthropic/claude-sonnet-4-20250514",
  "small_model": "anthropic/claude-haiku-4-20250514"
}
```

Format: `"provider/model-id"`

`small_model` is used for lightweight tasks (title generation, etc.)

### Provider options

```json
{
  "provider": {
    "anthropic": {
      "options": {
        "timeout": 600000,      // 10 min (default: 300000)
        "setCacheKey": true,
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    }
  }
}
```

**Common options**:
- `timeout`: Request timeout in ms (or `false` to disable)
- `setCacheKey`: Ensure cache key always set
- `apiKey`: API key (use env vars!)
- `baseURL`: Custom API endpoint

### Provider-specific options

**Amazon Bedrock**:
```json
{
  "provider": {
    "amazon-bedrock": {
      "options": {
        "region": "us-east-1",
        "profile": "my-aws-profile",
        "endpoint": "https://bedrock-runtime.vpce-xxx.amazonaws.com"
      }
    }
  }
}
```

### Disable/enable providers

```json
{
  "disabled_providers": ["openai", "gemini"],
  "enabled_providers": ["anthropic", "openai"]
}
```

Note: `disabled_providers` takes priority over `enabled_providers`

### Model-specific options

Pass provider-specific params directly:
```json
{
  "agent": {
    "deep-thinker": {
      "model": "openai/gpt-5",
      "reasoningEffort": "high",     // OpenAI-specific
      "textVerbosity": "low"
    }
  }
}
```

## Skills

### Skill structure

**Directory**: `.opencode/skills/<skill-name>/SKILL.md`

**SKILL.md format**:
```markdown
---
name: skill-name
description: What this skill does (1-1024 chars)
license: MIT
compatibility: opencode
metadata:
  key1: value1
  key2: value2
---

Skill content goes here.
Instructions, examples, reference material.
```

### Skill name requirements

- 1-64 characters
- Lowercase alphanumeric with single hyphen separators
- No leading/trailing `-`
- No consecutive `--`
- Must match directory name
- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

### Discovery locations

- Project: `.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md` (both project and global)

### Skill permissions

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

**Per agent**:
```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

### Disable skill tool

```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

## Commands

### Custom commands

**JSON**:
```json
{
  "command": {
    "test": {
      "template": "Run the full test suite with coverage report.\nFocus on failing tests and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-haiku-4-20250514"
    },
    "component": {
      "template": "Create a new React component named $ARGUMENTS with TypeScript.\nInclude proper typing and basic structure.",
      "description": "Create a new component"
    }
  }
}
```

**Markdown** (`.opencode/commands/test.md`):
```markdown
---
description: Run tests with coverage
agent: build
model: anthropic/claude-haiku-4-20250514
---

Run the full test suite with coverage report.
Focus on failing tests and suggest fixes.
```

Use `$ARGUMENTS` for command arguments.

## Advanced configuration

### Themes

```json
{
  "theme": "opencode"
}
```

Place custom themes in `.opencode/themes/` or `~/.config/opencode/themes/`

### Keybinds

```json
{
  "keybinds": {
    "switch_agent": "Tab",
    "session_child_cycle": "<Leader>+Right"
  }
}
```

### TUI settings

```json
{
  "tui": {
    "scroll_speed": 3,
    "scroll_acceleration": {
      "enabled": true
    },
    "diff_style": "auto"  // or "stacked"
  }
}
```

### Server settings

```json
{
  "server": {
    "port": 4096,
    "hostname": "0.0.0.0",
    "mdns": true,
    "cors": ["http://localhost:5173"]
  }
}
```

### Formatters

```json
{
  "formatter": {
    "prettier": {
      "disabled": true
    },
    "custom-prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "environment": {
        "NODE_ENV": "development"
      },
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    }
  }
}
```

### Instructions (rules)

```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md"
  ]
}
```

Supports paths and glob patterns.

### MCP servers

```json
{
  "mcp": {
    "server-name": {
      "type": "remote",
      "url": "https://api.example.com/mcp",
      "enabled": true
    }
  }
}
```

### Plugins

```json
{
  "plugin": ["opencode-helicone-session", "@my-org/custom-plugin"]
}
```

Also place in `.opencode/plugins/` or `~/.config/opencode/plugins/`

### Compaction

```json
{
  "compaction": {
    "auto": true,   // Auto compact when context full
    "prune": true   // Remove old tool outputs
  }
}
```

### Watcher

```json
{
  "watcher": {
    "ignore": ["node_modules/**", "dist/**", ".git/**"]
  }
}
```

### Sharing

```json
{
  "share": "manual"  // "manual", "auto", or "disabled"
}
```

### Autoupdate

```json
{
  "autoupdate": false  // true, false, or "notify"
}
```

### Experimental features

```json
{
  "experimental": {
    // Experimental options here (unstable)
  }
}
```

## Common configuration patterns

### Read-only agent (Plan mode)

```json
{
  "agent": {
    "plan": {
      "mode": "primary",
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
    }
  }
}
```

### Compilation subagent (noise filter)

```json
{
  "agent": {
    "android-compilation": {
      "mode": "subagent",
      "hidden": false,
      "tools": {
        "write": false,
        "edit": false,
        "bash": true
      },
      "permission": {
        "bash": "allow"
      }
    }
  }
}
```

### Integrator agent (delegates builds)

```json
{
  "agent": {
    "integrator": {
      "mode": "primary",
      "tools": {
        "task": true
      },
      "permission": {
        "task": {
          "*": "deny",
          "android-compilation": "allow"
        }
      }
    }
  }
}
```

### Security-focused permissions

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git diff*": "allow",
      "rm *": "deny",
      "sudo *": "deny"
    },
    "read": {
      "*": "allow",
      "*.env": "deny",
      "*.env.*": "deny",
      "**/secrets/**": "deny"
    },
    "edit": {
      "*": "ask",
      "src/**/*.ts": "allow",
      "package*.json": "ask"
    }
  }
}
```

### Multi-environment setup

**Global** (`~/.config/opencode/opencode.json`):
```json
{
  "theme": "opencode",
  "autoupdate": true,
  "model": "anthropic/claude-sonnet-4-20250514"
}
```

**Project** (`opencode.json`):
```json
{
  "model": "anthropic/claude-haiku-4-20250514",  // Override: use cheaper model
  "instructions": ["CONTRIBUTING.md"],
  "agent": {
    "android-builder": {
      "mode": "primary",
      "prompt": "{file:.opencode/prompts/android-builder.txt}"
    }
  }
}
```

Result: Merged config uses haiku model, opencode theme, and project-specific agent.

## Troubleshooting

### Agent not appearing
- Check `mode` is set correctly (`primary` or `subagent`)
- Verify file is in `.opencode/agents/` or `~/.config/opencode/agents/`
- Check `hidden: true` (subagents only)
- Ensure description is provided

### Skill not loading
- Verify filename is `SKILL.md` (all caps)
- Check frontmatter has `name` and `description`
- Ensure skill name matches directory name
- Check permissions: `permission.skill` not set to `deny`

### Tool not working
- Check `tools.<tool-name>` is not `false`
- Verify `permission.<tool-name>` is not `"deny"`
- For subagents, check agent-specific tool config

### Config not taking effect
- Check precedence order (project > custom > global > remote)
- Remember configs are merged, not replaced
- Use `{env:VAR}` for env vars, not direct references
- Validate JSON syntax (use JSONC for comments)

### Permission patterns not matching
- Remember: last matching rule wins
- Use `*` wildcard correctly
- Put catch-all `*` rule first, specific after
- For commands with args, use `"cmd *"` not just `"cmd"`

## Quick reference

### Essential config locations
- Global: `~/.config/opencode/opencode.json`
- Project: `<project-root>/opencode.json`
- Agents: `.opencode/agents/*.md`
- Skills: `.opencode/skills/<name>/SKILL.md`
- Commands: `.opencode/commands/*.md`

### Common permission patterns
```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status": "allow",
      "git diff*": "allow"
    },
    "edit": "allow",
    "read": {
      "*": "allow",
      "*.env": "deny"
    },
    "task": {
      "*": "deny",
      "my-subagent": "allow"
    }
  }
}
```

### Temperature guidelines
- `0.0-0.2`: Very focused (code analysis, builds, error diagnosis)
- `0.3-0.5`: Balanced (general development)
- `0.6-1.0`: Creative (brainstorming, exploration)

### Model format
```
provider/model-id

Examples:
- anthropic/claude-sonnet-4-20250514
- openai/gpt-4
- google-vertex-anthropic/claude-sonnet-4-5@20250929
- opencode/claude-haiku-4-5  (via OpenCode Zen)
```

For detailed documentation on any topic, refer to the accompanying docs in the `docs/` folder of this skill.
