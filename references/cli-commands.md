# CLI Command Reference

Complete reference for the `notebooklm` CLI. All commands use the pattern:

```
notebooklm [--storage PATH] <command> [OPTIONS] [ARGS]
```

## Table of Contents

- [Session Commands](#session-commands)
- [Language Commands](#language-commands)
- [Notebook Commands](#notebook-commands)
- [Source Commands](#source-commands)
- [Research Commands](#research-commands)
- [Chat Commands](#chat-commands)
- [Note Commands](#note-commands)
- [Generate Commands](#generate-commands)
- [Artifact Commands](#artifact-commands)
- [Download Commands](#download-commands)
- [Share Commands](#share-commands)
- [Skill Commands](#skill-commands)

## Session Commands

| Command | Description |
|---------|-------------|
| `login` | Authenticate via browser (opens Chromium, log into Google, press Enter) |
| `use <id>` | Set active notebook (supports partial ID matching: `use abc` matches `abc123...`) |
| `status` | Show current context (`--paths` for config locations, `--json` for scripting) |
| `clear` | Clear current context |
| `auth check` | Diagnose auth issues (`--test` for network validation, `--json` for automation) |

## Language Commands

**Language is a GLOBAL setting affecting all notebooks in your account.**

```bash
notebooklm language list              # List all 80+ supported languages
notebooklm language get               # Show current language (syncs from server)
notebooklm language get --local       # Show local config only
notebooklm language set en            # Set to English
notebooklm language set zh_Hans       # Set to Simplified Chinese
notebooklm language set ja            # Set to Japanese
```

Common codes: `en`, `zh_Hans`, `zh_Hant`, `ja`, `ko`, `es`, `fr`, `de`, `pt_BR`

## Notebook Commands

| Command | Description |
|---------|-------------|
| `list` | List all notebooks |
| `create <title>` | Create a new notebook |
| `delete <id>` | Delete a notebook |
| `rename <title>` | Rename the active notebook |
| `share` | Toggle sharing (see [Share Commands](#share-commands)) |
| `summary` | Get AI-generated summary of active notebook |

## Source Commands

Prefix: `notebooklm source <cmd>`

Auto-detection: URLs → web source, YouTube URLs → video transcript, file paths → upload (PDF, text, Markdown, Word, audio, video, images).

| Command | Options | Example |
|---------|---------|---------|
| `list` | - | `source list` |
| `add <content>` | URL, file path, or pasted text | `source add "https://..."` or `source add ./paper.pdf` |
| `add-drive <id> <title>` | Google Drive file ID | `source add-drive abc123 "Doc"` |
| `add-research <query>` | `--mode [fast\|deep]`, `--from [web\|drive]`, `--import-all`, `--no-wait` | `source add-research "AI" --mode deep --import-all` |
| `get <id>` | - | `source get src123` |
| `fulltext <id>` | `--json`, `-o FILE` | `source fulltext src123 -o content.txt` |
| `guide <id>` | `--json` | `source guide src123` |
| `rename <id> <title>` | - | `source rename src123 "New Name"` |
| `refresh <id>` | - | `source refresh src123` |
| `delete <id>` | - | `source delete src123` |
| `wait <id>` | `--timeout`, `--interval` | `source wait src123` |

## Research Commands

Prefix: `notebooklm research <cmd>`

| Command | Options | Example |
|---------|---------|---------|
| `status` | `--json` | `research status` |
| `wait` | `--timeout`, `--interval`, `--import-all`, `--json` | `research wait --import-all --timeout 300` |

Use with `source add-research --no-wait` for non-blocking deep research in agent workflows.

## Chat Commands

| Command | Options | Example |
|---------|---------|---------|
| `ask <question>` | `-s <id>` (specific sources), `--json` | `ask "Summarize" -s src1 -s src2` |
| `configure` | `--mode learning-guide` | `configure --mode learning-guide` |
| `history` | `--clear` | `history --clear` |

## Note Commands

Prefix: `notebooklm note <cmd>`

| Command | Example |
|---------|---------|
| `list` | `note list` |
| `create <content>` | `note create "My observations..."` |
| `get <id>` | `note get note123` |
| `save <id>` | `note save note123` |
| `rename <id> <title>` | `note rename note123 "Key Insights"` |
| `delete <id>` | `note delete note123` |

## Generate Commands

Prefix: `notebooklm generate <type>`

All commands support: `-s/--source ID` (repeatable), `--json`, `--language LANG`, `--retry N`

See [generation-options.md](generation-options.md) for full details on each type.

| Type | Key Options | Wait? |
|------|-------------|-------|
| `audio` | `--format`, `--length`, `--wait` | Async |
| `video` | `--format`, `--style`, `--wait` | Async |
| `slide-deck` | `--format`, `--length`, `--wait` | Async |
| `quiz` | `--difficulty`, `--quantity`, `--wait` | Async |
| `flashcards` | `--difficulty`, `--quantity`, `--wait` | Async |
| `infographic` | `--orientation`, `--detail`, `--wait` | Async |
| `data-table` | `--wait` | Async |
| `mind-map` | *(sync, no wait)* | Sync |
| `report` | `--format`, `--wait` | Async |

## Artifact Commands

Prefix: `notebooklm artifact <cmd>`

| Command | Options | Example |
|---------|---------|---------|
| `list` | `--type` | `artifact list --type audio` |
| `get <id>` | - | `artifact get art123` |
| `rename <id> <title>` | - | `artifact rename art123 "Final Version"` |
| `delete <id>` | - | `artifact delete art123` |
| `export <id>` | `--type [docs\|sheets]`, `--title` | `artifact export art123 --type sheets` |
| `poll <task_id>` | - | `artifact poll task123` |
| `wait <id>` | `--timeout`, `--interval` | `artifact wait art123` |
| `suggestions` | `-s/--source`, `--json` | `artifact suggestions` |

## Download Commands

Prefix: `notebooklm download <type>`

All download commands support: `--all`, `--latest`, `--earliest`, `--name NAME`, `-a/--artifact ID`, `--dry-run`, `--force`, `--no-clobber`, `--json`

| Type | Default Ext | Format Options |
|------|-------------|----------------|
| `audio` | `.mp4` | - |
| `video` | `.mp4` | - |
| `slide-deck` | `.pdf` | - |
| `infographic` | `.png` | - |
| `report` | `.md` | - |
| `mind-map` | `.json` | - |
| `data-table` | `.csv` | - |
| `quiz` | `.json` | `--format [json\|markdown\|html]` |
| `flashcards` | `.json` | `--format [json\|markdown\|html]` |

**Batch download example:**
```bash
notebooklm download audio --all ./podcasts/
notebooklm download quiz --format markdown ./quiz.md
```

## Share Commands

Prefix: `notebooklm share <cmd>`

| Command | Options | Example |
|---------|---------|---------|
| `status` | `--json` | `share status` |
| `public` | `--enable`, `--disable` | `share public --enable` |
| `view-level` | `full`, `chat` | `share view-level chat` |
| `add <email>` | `--permission [viewer\|editor]`, `-m MESSAGE`, `--no-notify` | `share add user@example.com --permission editor` |
| `update <email>` | `--permission` | `share update user@example.com --permission editor` |
| `remove <email>` | `-y` (skip confirmation) | `share remove user@example.com -y` |

## Skill Commands

Prefix: `notebooklm skill <cmd>`

| Command | Description |
|---------|-------------|
| `install` | Install/update Claude Code skill |
| `status` | Check installation and version |
| `uninstall` | Remove skill |
| `show` | Display skill content |

## Features Beyond the Web UI

These CLI capabilities are NOT available in NotebookLM's web interface:

| Feature | Command |
|---------|---------|
| Batch downloads | `download <type> --all` |
| Quiz/Flashcard export | `download quiz --format json\|markdown\|html` |
| Mind map extraction | `download mind-map` (JSON tree) |
| Data table export | `download data-table` (CSV) |
| Source fulltext access | `source fulltext <id>` |
| Programmatic sharing | `share` commands |
| Export to Google Docs/Sheets | `artifact export <id> --type docs\|sheets` |

## Global Options

- `--storage PATH` — Override storage location (default: `~/.notebooklm/storage_state.json`)
- `--version` — Show version
- `--help` — Show help

**Environment Variables:**
- `NOTEBOOKLM_HOME` — Base directory for config (default: `~/.notebooklm`)
- `NOTEBOOKLM_AUTH_JSON` — Inline auth JSON for CI/CD
- `NOTEBOOKLM_DEBUG_RPC` — Enable RPC debug logging (`1` to enable)
