# YouTrack agent skill

[![Buy Me a Coffee](https://img.buymeacoffee.com/button-api/?text=Buy+me+a+coffee&emoji=%E2%98%95&slug=maxmaxme&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/maxmaxme)

Public agent skill for reading YouTrack issues and turning them into implementation-ready coding context.

## What this skill does

- Fetches a single issue by key (`ABC-123`) from YouTrack API.
- Fetches issue lists by YouTrack query.
- Fetches issue comments and extracts key discussion context.
- Extracts key fields: `summary`, `description`, `customFields`, `links`, `subtasks`, `comments`.
- Produces an actionable brief and can continue to implementation.

## Install with `skills` CLI

This repository is compatible with [`skills`](https://www.npmjs.com/package/skills), so you can install it for different coding agents (Codex, Claude Code, Cursor, OpenCode, and others).

Install from GitHub:

```bash
npx skills add maxmaxme/ai-skills-youtrack
```

Install for specific agent(s):

```bash
npx skills add maxmaxme/ai-skills-youtrack -a codex
npx skills add maxmaxme/ai-skills-youtrack -a claude-code -a cursor
```

Install globally (available in all projects):

```bash
npx skills add maxmaxme/ai-skills-youtrack -g
```

Preview skill(s) before installing:

```bash
npx skills add maxmaxme/ai-skills-youtrack --list
```

After installation, restart your agent if it does not pick up newly installed skills automatically.

## Expected UX

User prompt:

`Do task ABC-123`

Agent behavior:

1. Fetch issue context from YouTrack.
2. Build a concise actionable brief.
3. Proceed with code changes when the request is implementation-oriented.
