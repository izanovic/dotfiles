# Multi-Agent Workflow

## Setup

Two zellij panes:
1. **Main** — this opencode (writes features, spawns agents)
2. **Agents** — the combined agent tab: `~/.config/opencode/agents/agents-dashboard.py`

The dashboard is a [Textual](https://textual.textualize.io) app split into
two panes in that one tab (it self-bootstraps `.opencode-agents/.venv`
with textual on first run via uv):

- **Left** — every headless agent working on a feature, navigate with ↑/↓
  or mouse click
- **Right** — the selected agent's completion summary as formatted
  markdown, shown immediately on selection; scrollable
- Session view (`e`) shows the full conversation history from the server
  plus an inline composer

Themed with **catppuccin-macchiato**; override via `OPENCODE_DASHBOARD_THEME`
(any built-in Textual theme name).

## Dashboard keys

| Key | Action |
| --- | --- |
| ↑/↓ | select agent (summary opens automatically) |
| PgUp/PgDn | always scroll the right pane, regardless of focus (mouse wheel works too) |
| `i` | back to the summary view |
| `e` | session view: full conversation history **plus an inline composer** — type and press enter to message the agent (auto-pauses the driver; `r` resumes autonomy). `esc` returns focus to the agent list. For the full interactive opencode TUI, use take over (`a`) |
| `d` | whole-branch git diff for headstad + nexura vs merge-base: delta-style colored (green/red tinted lines, cyan hunk headers, dim metadata), stat header per repo, truncated at ~120KB. Scrollable like every right-pane view |
| `a` | take over: stops the driver loop (server stays up), attaches the interactive opencode TUI **resuming the agent's own session** (`-s`) so you see its full history |
| `r` | resume: restart the autonomous driver (reuses the running server) |
| `s` | stop agent (driver + server) |
| `R` | reload: restart the dashboard app itself (same tty, fresh process — clears caches and picks up edits to `agents-dashboard.py`) |
| `q` | quit |

### Taking over a session

Press `a` on a selected agent: the retry driver is killed, then an
interactive opencode TUI attaches to the agent's server, so manual
instructions continue in the same session. Exit the TUI to return to
the dashboard; press `r` to hand control back to the driver.

## Communication

File-based IPC via `.opencode-agents/`:

```
.opencode-agents/
  tasks/<feature>.md     # Task spec + status
  reports/<feature>.md   # Agent progress output + final ## Summary
  reports/<feature>.driver.log  # Raw headless run output
  <feature>.port         # Server port for attach/take over
  <feature>.session      # Driver session id (take over resumes it with history)
```

## Usage

```bash
# Spawn an agent for a new feature
/home/izanovic/.config/opencode/agents/spawn-agent.sh "invite-page" "Build an invite page with email validation"

# Open the combined agents tab
/home/izanovic/.config/opencode/agents/agents-dashboard.py
```

## Rules for Spawned Agents

1. Read the task file before starting
2. Write progress to the report file periodically
3. When done, append a `## Summary` section (what was done + choices made and why)
4. Update Status in task file last (`in_progress` → `completed`)
5. Follow clean/minimal code principles
6. Use types from `models.ts`, built-in UI components, `data.ts` for CRUD
