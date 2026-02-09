# Generation Options Reference

Detailed options for every `notebooklm generate <type>` command.

All generate commands share these common options:
- `-s/--source ID` — Use specific source(s), repeatable (uses all if omitted)
- `--json` — Machine-readable output (returns `task_id` and `status`)
- `--language LANG` — Override output language (defaults to config or 'en')
- `--retry N` — Auto-retry on rate limits with exponential backoff

## Audio Overview (Podcast)

```bash
notebooklm generate audio [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--format` | `deep-dive`, `brief`, `critique`, `debate` | `deep-dive` |
| `--length` | `short`, `default`, `long` | `default` |
| `--wait` | Flag — wait for completion | No wait |

**Examples:**
```bash
generate audio "Focus on key takeaways" --format brief --length short --wait
generate audio "Compare viewpoints" --format debate --wait
generate audio -s src_abc -s src_def    # Specific sources only
```

**Supported in 50+ languages** via `--language` or global language setting.

## Video Overview

```bash
notebooklm generate video [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--format` | `explainer`, `brief` | — |
| `--style` | `auto`, `classic`, `whiteboard`, `kawaii`, `anime`, `watercolor`, `retro-print`, `heritage`, `paper-craft` | `auto` |
| `--wait` | Flag | No wait |

**Examples:**
```bash
generate video "Explain for beginners" --style whiteboard --wait
generate video --style kawaii --format brief
```

## Slide Deck (PPT)

```bash
notebooklm generate slide-deck [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--format` | `detailed`, `presenter` | — |
| `--length` | `default`, `short` | `default` |
| `--wait` | Flag | No wait |

## Quiz

```bash
notebooklm generate quiz [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--difficulty` | `easy`, `medium`, `hard` | — |
| `--quantity` | `fewer`, `standard`, `more` | `standard` |
| `--wait` | Flag | No wait |

**Download formats:** JSON (structured with answerOptions, rationale, isCorrect, hint), Markdown (human-readable with checkboxes), HTML (raw from NotebookLM).

## Flashcards

```bash
notebooklm generate flashcards [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--difficulty` | `easy`, `medium`, `hard` | — |
| `--quantity` | `fewer`, `standard`, `more` | `standard` |
| `--wait` | Flag | No wait |

**Download formats:** JSON (front/back normalized), Markdown, HTML.

## Infographic

```bash
notebooklm generate infographic [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--orientation` | `landscape`, `portrait`, `square` | — |
| `--detail` | `concise`, `standard`, `detailed` | `standard` |
| `--wait` | Flag | No wait |

## Data Table

```bash
notebooklm generate data-table <description> [OPTIONS]
```

**Note:** Description is required (defines the table structure via natural language).

| Option | Values | Default |
|--------|--------|---------|
| `--wait` | Flag | No wait |

**Example:**
```bash
generate data-table "Compare key concepts with pros, cons, and examples" --wait
```

## Mind Map

```bash
notebooklm generate mind-map
```

**Synchronous** — completes instantly, no `--wait` needed. Returns hierarchical JSON.

## Report

```bash
notebooklm generate report [description] [OPTIONS]
```

| Option | Values | Default |
|--------|--------|---------|
| `--format` | `briefing-doc`, `study-guide`, `blog-post`, `custom` | `briefing-doc` |
| `--wait` | Flag | No wait |

**Examples:**
```bash
generate report --format study-guide --wait
generate report "Executive summary for stakeholders" --format briefing-doc
generate report "Create a white paper on key trends"   # Auto-selects custom format
```

## Generation Timing Guidelines

| Type | Typical Duration |
|------|-----------------|
| Audio (podcast) | 2–5 minutes |
| Video | 3–8 minutes |
| Slide deck | 1–3 minutes |
| Mind map | Instant (sync) |
| Quiz / Flashcards | 1–2 minutes |
| Infographic | 2–3 minutes |
| Report | 2–4 minutes |
| Data table | 1–2 minutes |

## Tips for Agent Workflows

1. **Avoid `--wait` in agent contexts** — async operations can take 30+ minutes. Instead use `artifact wait <id>` in a subagent.
2. **Use `--json`** to get `task_id` for programmatic polling with `artifact poll <task_id>`.
3. **Source selection** with `-s` lets you generate from a subset of notebook sources.
4. **Rate limit handling** — use `--retry N` for automatic exponential backoff.
