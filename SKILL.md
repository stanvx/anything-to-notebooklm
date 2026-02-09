---
name: anything-to-notebooklm
description: "Multi-source content processor for Google NotebookLM. Converts any content (URLs, YouTube, WeChat articles, PDFs, EPUB, Office docs, images with OCR, audio, CSV/JSON/XML, ZIP archives, search queries, Google Drive files) into podcasts, videos, slide decks, quizzes, flashcards, mind maps, infographics, reports, data tables, and study guides via NotebookLM. Use when users want to: (1) convert content to audio/video/slides, (2) generate study materials from documents, (3) create podcasts from articles or books, (4) build mind maps or infographics, (5) research topics and generate reports, (6) upload content to NotebookLM, (7) batch process multiple sources, or any task involving content transformation through NotebookLM."
---

# Anything → NotebookLM

Automatically acquire content from 15+ source types, upload to Google NotebookLM, and generate 9 output formats via natural language.

## Prerequisites

1. **NotebookLM CLI** — authenticate once: `notebooklm login` then verify with `notebooklm list`
2. **WeChat MCP** (optional, for WeChat articles only) — configure in `~/.claude/config.json`:
   ```json
   { "mcpServers": { "weixin-reader": { "command": "python", "args": ["<SKILL_DIR>/wexin-read-mcp/src/server.py"] } } }
   ```
   Restart Claude Code after configuration.
3. **Environment check**: `./check_env.py` (9-point diagnostic)

## Workflow

Process any request in these steps:

1. **Identify source type** (auto-detect from input)
2. **Acquire content** (fetch/convert as needed)
3. **Upload to NotebookLM** (create notebook + add sources)
4. **Generate output** (if user specifies a format)
5. **Download and deliver** (save to local path)

### Step 1: Identify Source Type

| Input Pattern | Type | Acquisition Method |
|---------------|------|-------------------|
| `https://mp.weixin.qq.com/s/` | WeChat article | MCP `read_weixin_article` → save TXT |
| `https://youtube.com/...` or `https://youtu.be/...` | YouTube | Direct: `source add <URL>` |
| `https://` or `http://` | Web page | Direct: `source add <URL>` |
| `/path/to/file.pdf` | PDF | `markitdown` → TXT then `source add` |
| `/path/to/file.epub` | EPUB | `markitdown` → TXT then `source add` |
| `/path/to/file.docx` | Word | `markitdown` → TXT then `source add` |
| `/path/to/file.pptx` | PowerPoint | `markitdown` → TXT then `source add` |
| `/path/to/file.xlsx` | Excel | `markitdown` → TXT then `source add` |
| `/path/to/file.md` | Markdown | Direct: `source add <path>` |
| `/path/to/image.{jpg,png,gif,webp}` | Image (OCR) | `markitdown` OCR → TXT |
| `/path/to/audio.{mp3,wav}` | Audio | `markitdown` transcribe → TXT |
| `/path/to/file.{csv,json,xml}` | Structured data | `markitdown` → TXT |
| `/path/to/file.zip` | ZIP archive | Extract → `markitdown` batch → TXT |
| Keywords (no URL/path) | Search query | WebSearch → aggregate → TXT |

### Step 2: Acquire Content

**WeChat articles**: Use MCP tool `read_weixin_article` → returns title, author, publish_time, content → save as `/tmp/weixin_{title}_{timestamp}.txt`

**URLs / YouTube**: Pass directly to `notebooklm source add <URL>` — NotebookLM handles extraction.

**Documents / ebooks / images / audio**: Convert via `markitdown /path/to/file -o /tmp/converted.md` → save as TXT.

**ZIP archives**: Extract to temp dir → iterate all supported files → batch convert with markitdown → merge or add as multiple sources.

**Search queries**: Use WebSearch → aggregate top 3–5 results → save as `/tmp/search_{keyword}_{timestamp}.txt`

### Step 3: Upload to NotebookLM

```bash
notebooklm create "{title}"
notebooklm source add /tmp/content.txt    # or URL
notebooklm source wait <source_id>        # Wait for processing — critical before generation
```

For multiple sources, add each sequentially and wait for processing.

### Step 4: Generate Content

Map user intent to the appropriate command. If no intent specified, upload only and await further instructions.

| User Says | Intent | Command |
|-----------|--------|---------|
| "generate podcast" / "make audio" / "convert to audio" | audio | `generate audio` |
| "make slides" / "create PPT" / "generate presentation" | slide-deck | `generate slide-deck` |
| "create mind map" / "draw a concept map" | mind-map | `generate mind-map` |
| "generate quiz" / "create test questions" | quiz | `generate quiz` |
| "make a video" / "generate video" | video | `generate video` |
| "write a report" / "create summary" / "make a study guide" | report | `generate report` |
| "create infographic" / "visualize data" | infographic | `generate infographic` |
| "make flashcards" / "create study cards" | flashcards | `generate flashcards` |
| "create data table" / "make a comparison table" | data-table | `generate data-table` |

**Generation options** (see [references/generation-options.md](references/generation-options.md) for full details):

- **Audio**: `--format [deep-dive|brief|critique|debate]`, `--length [short|default|long]`
- **Video**: `--style [classic|whiteboard|kawaii|anime|watercolor|retro-print|heritage|paper-craft]`, `--format [explainer|brief]`
- **Slide deck**: `--format [detailed|presenter]`, `--length [default|short]`
- **Quiz**: `--difficulty [easy|medium|hard]`, `--quantity [fewer|standard|more]`
- **Flashcards**: `--difficulty [easy|medium|hard]`, `--quantity [fewer|standard|more]`
- **Infographic**: `--orientation [landscape|portrait|square]`, `--detail [concise|standard|detailed]`
- **Report**: `--format [briefing-doc|study-guide|blog-post|custom]`
- **Data table**: Requires a description defining the table structure

All async generators accept `--wait`, `-s <source_id>` (specific sources), `--language LANG`, `--retry N`.
Mind map is synchronous (instant).

### Step 5: Download and Deliver

```bash
notebooklm download audio ./podcast.mp3
notebooklm download video ./video.mp4
notebooklm download slide-deck ./slides.pdf
notebooklm download mind-map ./map.json
notebooklm download quiz --format markdown ./quiz.md
notebooklm download flashcards --format json ./cards.json
notebooklm download infographic ./infographic.png
notebooklm download report ./report.md
notebooklm download data-table ./data.csv
```

Download options: `--all` (batch), `--latest`, `--name "Title"`, `--force`, `--dry-run`
Quiz/Flashcards formats: `json`, `markdown`, `html`

## Advanced Features

### AI-Powered Research

Discover and import sources automatically:
```bash
notebooklm source add-research "quantum computing breakthroughs" --mode deep --import-all
```
Modes: `fast` (quick) or `deep` (thorough). Sources: `--from web` or `--from drive`.
Non-blocking: add `--no-wait`, then poll with `notebooklm research wait --import-all`.

### Chat with Sources

Ask questions about uploaded content:
```bash
notebooklm ask "What are the key themes across all sources?"
notebooklm ask "Compare the two viewpoints" -s src1 -s src2
notebooklm configure --mode learning-guide   # Set persona
```

### Language Configuration

Set output language for all generated content (50+ languages supported):
```bash
notebooklm language set es     # Spanish
notebooklm language set ja     # Japanese
notebooklm language list       # See all 80+ options
```

### Notebook Sharing

```bash
notebooklm share public --enable
notebooklm share add user@example.com --permission editor -m "Check this out!"
notebooklm share view-level chat    # Chat-only access for viewers
```

### Notes Management

```bash
notebooklm note create "Key insight: the main argument is..."
notebooklm note list
```

### Artifact Management

```bash
notebooklm artifact list --type audio
notebooklm artifact export <id> --type docs    # Export to Google Docs
notebooklm artifact export <id> --type sheets  # Export to Google Sheets
notebooklm artifact suggestions                # Get AI-suggested artifacts
```

### Multi-Intent Processing

Handle multiple outputs in one request:
```
Generate a podcast and slides from this article https://example.com/article
```
Execute sequentially: generate audio → generate slide-deck.

### Custom Notebooks

Add to an existing notebook instead of creating a new one:
```
Add this to my "AI Research" notebook https://example.com/article
```
Search for the notebook by name → add source → generate from all sources.

### Custom Generation Instructions

Pass specific requirements as the description parameter:
```
Generate a podcast with a humorous tone, keep it under 5 minutes
```
The description is forwarded as instructions to NotebookLM.

### Batch Processing

```bash
# Bulk add sources
for f in ./papers/*.pdf; do notebooklm source add "$f"; done

# Batch download all artifacts of a type
notebooklm download audio --all ./podcasts/
```

## Important Notes

- **Rate limits**: Space requests >2s apart. Max 3 concurrent generation tasks.
- **Content length**: 500–500K words. Best results with 1K–10K words.
- **Generation timing**: Audio 2–5min, Video 3–8min, Slides 1–3min, Mind map instant, Quiz/Flashcards 1–2min.
- **Temp files**: Source files saved to `/tmp/`, cleared on reboot. Specify custom output paths.
- **Copyright**: For personal learning/research only. Respect source content copyright and NotebookLM ToS.

## Reference Documentation

- **[CLI Commands](references/cli-commands.md)** — Complete command reference with all options
- **[Generation Options](references/generation-options.md)** — Detailed options for every generation type
- **[Troubleshooting](references/troubleshooting.md)** — Error handling and debugging guide
