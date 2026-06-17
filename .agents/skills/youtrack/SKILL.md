---
name: youtrack
description: Fetch and analyze YouTrack issues, then convert task text into actionable implementation steps for coding work. Use when the user references YouTrack, provides an issue key like ABC-123, asks to "do the task", requests task details, acceptance criteria, linked issues, bug-fix context from YouTrack, or asks to configure YouTrack access token/domain.
---

# YouTrack

Use this skill to pull issue details from YouTrack and turn them into a concrete implementation plan.

## Quick start

- If not configured, ask the user to set `YOUTRACK_BASE_URL` and `YOUTRACK_TOKEN`.
- Prefer the interactive setup script. It prompts in terminal and hides token input.
- Never ask the user to paste a full token in chat. Ask them to enter it only in terminal.
- Always call YouTrack API directly when issue details are needed.

If base URL/token is missing, provide these steps:
1. Open YouTrack -> profile -> security and create a permanent token.
2. Run interactive setup from this skill directory:
```bash
./scripts/setup_env.sh
```
3. Enter base URL and token in terminal when prompted (token is hidden).
4. Apply env in current shell:
```bash
source ~/.zshrc
```
Use `~/.bashrc` or `~/.profile` if not using zsh.
5. Restart your coding agent session if needed.

## Required environment variables

- `YOUTRACK_BASE_URL` (for example `https://youtrack.example.com`)
- `YOUTRACK_TOKEN` (YouTrack permanent token)

Never store tokens in repository files or commit them.
Never echo tokens in command output.

## Workflow

1. Detect issue key in user message with regex `[A-Z][A-Z0-9]+-[0-9]+`.
   Also treat phrases like `Сделай задачу ABC-123` / `Do task ABC-123` as an implementation request.
2. Run `scripts/fetch_issue.sh <ISSUE_KEY>` or query mode when key is absent.
3. Parse response fields:
- `idReadable`
- `summary`
- `description`
- `customFields`
- `links`
- `subtasks`
- `comments` (author, text, timestamps)
4. Produce a short structured brief before coding:
- Goal
- Problem statement
- Constraints and scope
- Acceptance criteria
- Key discussion points from comments
- Open questions
- Implementation steps
5. If the user asks to implement, proceed with code changes immediately.
   For direct execution phrasing (`Сделай задачу ...`), do not stop after summary: continue to implementation.

## Commands

Fetch one issue:

```bash
./scripts/fetch_issue.sh ABC-123
```

Fetch list by query:

```bash
./scripts/fetch_issue.sh --query 'for: me #Unresolved'
```

Fetch issue comments only:

```bash
./scripts/fetch_issue.sh --comments ABC-123
```
