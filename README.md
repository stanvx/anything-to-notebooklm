<div align="center">

# 🎯 Multi-Source Content → NotebookLM Smart Processor

**One sentence turns into a podcast, PPT, mind map, quiz...**

> 🔀 **Fork of [joeseesun/anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm)** with expanded features and improvements

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![uv](https://img.shields.io/badge/uv-enabled-blue.svg)](https://docs.astral.sh/uv/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![GitHub stars](https://img.shields.io/github/stars/stanvx/anything-to-notebooklm?style=social)](https://github.com/stanvx/anything-to-notebooklm/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/stanvx/anything-to-notebooklm)](https://github.com/stanvx/anything-to-notebooklm/issues)

[Quick Start](#-quick-start) • [Supported Formats](#-supported-content-sources) • [Usage Examples](#-usage-examples) • [FAQ](#-faq)

</div>

---

## ✨ What Is This?

A **Claude Code Skill** that lets you use natural language to turn **any content** into **any format**.

```
You say: Turn this article into a podcast
AI:      ✅ 8-minute podcast generated → podcast.mp3

You say: Convert this EPUB ebook into a mind map
AI:      ✅ Mind map generated → mindmap.json

You say: Make this YouTube video into slides
AI:      ✅ 25-page PPT generated → slides.pdf
```

**How it works**: Automatically fetch content from multiple sources → Upload to [Google NotebookLM](https://notebooklm.google.com/) → AI generates your desired format

## 🚀 Supported Content Sources (15+ Formats)

<table>
<tr>
<td width="50%">

### 📱 Social Media
- **WeChat Articles** (anti-scraping bypass)
- **YouTube Videos** (auto subtitle extraction)

### 🌐 Web
- **Any web page** (news, blogs, docs)
- **Search keywords** (auto-aggregate results)

### 📄 Office Documents
- **Word** (.docx)
- **PowerPoint** (.pptx)
- **Excel** (.xlsx)

</td>
<td width="50%">

### 📚 Ebooks & Documents
- **PDF** (including scanned with OCR)
- **EPUB** (ebooks)
- **Markdown** (.md)

### 🖼️ Images & Audio
- **Images** (JPEG/PNG/GIF, auto OCR)
- **Audio** (WAV/MP3, auto transcription)

### 📊 Structured Data
- **CSV/JSON/XML**
- **ZIP archives** (batch processing)

</td>
</tr>
</table>

**Powered by**: [Microsoft markitdown](https://github.com/microsoft/markitdown)

## 🎨 What Can It Generate?

| Output Format | Use Case | Gen Time | Trigger Examples |
|--------------|----------|----------|------------------|
| 🎙️ **Podcast** | Listen on the go | 2–5 min | "generate podcast", "make audio" |
| 📊 **Slides** | Team presentations | 1–3 min | "make PPT", "generate slides" |
| 🗺️ **Mind Map** | Visualize structure | 1–2 min | "draw a mind map", "concept map" |
| 📝 **Quiz** | Self-assessment | 1–2 min | "generate quiz", "create test" |
| 🎬 **Video** | Visual content | 3–8 min | "make a video" |
| 📄 **Report** | Deep analysis | 2–4 min | "generate report", "write summary" |
| 📈 **Infographic** | Data visualization | 2–3 min | "make infographic" |
| 📋 **Flashcards** | Memory reinforcement | 1–2 min | "make flashcards" |
| 📊 **Data Table** | Structured comparison | 1–2 min | "create data table" |

**Fully natural language — no commands to memorize!**

## ⚡ Quick Start

### Prerequisites

- ✅ [uv](https://docs.astral.sh/uv/getting-started/) (universal Python tool runner)
- ✅ Git (pre-installed on macOS/Linux)

**That's it!** All other dependencies are auto-installed.

### Installation (3 Steps)

```bash
# 1. Clone to Claude skills directory
cd ~/.claude/skills/
git clone https://github.com/stanvx/anything-to-notebooklm
cd anything-to-notebooklm

# 2. One-click install all dependencies
./install.sh

# 3. Configure MCP as prompted, then restart Claude Code
```

> install.sh creates local CLI wrappers in `./bin` (powered by uvx). Add them to your PATH to use `notebooklm` and `markitdown` directly:
> `export PATH="$HOME/.claude/skills/anything-to-notebooklm/bin:$PATH"`

### First Use

```bash
# NotebookLM authentication (one-time only)
./bin/notebooklm login
./bin/notebooklm list  # Verify success

# Environment check (optional)
./check_env.py
```

### OpenClaw (AgentSkills) Setup

OpenClaw loads AgentSkills from `<workspace>/skills` (highest priority) and `~/.openclaw/skills` (shared). The default workspace is `~/.openclaw/workspace`. If you haven’t bootstrapped OpenClaw yet, run `openclaw setup` once.

```bash
mkdir -p ~/.openclaw/workspace/skills
git clone https://github.com/stanvx/anything-to-notebooklm \
  ~/.openclaw/workspace/skills/anything-to-notebooklm
cd ~/.openclaw/workspace/skills/anything-to-notebooklm
./install.sh

# Optional: add wrappers to PATH for easy access
export PATH="$HOME/.openclaw/workspace/skills/anything-to-notebooklm/bin:$PATH"
```

## 💡 Usage Examples

### Scenario 1: Quick Learning — Article → Podcast

```
You: Turn this article into a podcast https://mp.weixin.qq.com/s/abc123

AI automatically:
  ✓ Fetches WeChat article content
  ✓ Uploads to NotebookLM
  ✓ Generates podcast (2-5 min)

✅ Result: /tmp/article_podcast.mp3 (8 min, 12.3 MB)
💡 Use: Listen during your commute
```

### Scenario 2: Team Sharing — Ebook → PPT

```
You: Turn this book into slides /Users/joe/Books/sapiens.epub

AI automatically:
  ✓ Extracts ebook content (150K words)
  ✓ AI distills key insights
  ✓ Generates professional slides

✅ Result: /tmp/sapiens_slides.pdf (25 pages, 3.8 MB)
💡 Use: Ready for book club presentation
```

### Scenario 3: Self-Assessment — Video → Quiz

```
You: Generate a quiz from this YouTube video https://youtube.com/watch?v=abc

AI automatically:
  ✓ Extracts video subtitles
  ✓ AI analyzes key knowledge points
  ✓ Auto-generates questions

✅ Result: /tmp/video_quiz.md (15 questions: 10 multiple choice + 5 short answer)
💡 Use: Test your understanding
```

### Scenario 4: Information Synthesis — Multi-Source → Report

```
You: Combine these into a report:
    - https://example.com/article1
    - https://youtube.com/watch?v=xyz
    - /Users/joe/research.pdf

AI automatically:
  ✓ Aggregates 3 different sources
  ✓ AI synthesizes and analyzes
  ✓ Generates comprehensive report

✅ Result: /tmp/multi_source_report.md (7 chapters, 15.2 KB)
💡 Use: Complete topic research report
```

### Scenario 5: Document Digitization — Scan → Text

```
You: Convert this scanned image to a document /Users/joe/scan.jpg

AI automatically:
  ✓ OCR recognizes text in image
  ✓ Extracts as plain text
  ✓ Generates structured document

✅ Result: /tmp/scan_document.txt (95%+ accuracy)
💡 Use: Digital archiving of scanned documents
```

## 🎯 Core Features

### 🧠 Smart Recognition
Auto-detects input type — no manual specification needed

```
https://mp.weixin.qq.com/s/xxx   → WeChat Article
https://youtube.com/watch?v=xxx  → YouTube Video
/path/to/file.epub               → EPUB Ebook
"search 'AI trends'"             → Search Query
```

### 🚀 Fully Automated
From acquisition to generation — seamless end-to-end

```
Input → Fetch → Convert → Upload → Generate → Download
       ︿_________ Fully Automated _________︿
```

### 🌐 Multi-Source Integration
Mix and match multiple content sources

```
Article + Video + PDF + Search Results → Comprehensive Report
```

### 🔒 Local-First
Sensitive content processed locally

```
WeChat Article → Local MCP Fetch → Local Conversion → NotebookLM
```

### 🌍 50+ Languages
Generate content in any of 80+ supported languages

```bash
notebooklm language set es    # Spanish podcasts
notebooklm language set ja    # Japanese reports
```

### 🔬 AI Research Agent
Auto-discover and import sources

```bash
notebooklm source add-research "quantum computing" --mode deep --import-all
```

## 📦 Architecture

```
┌─────────────────────────────────────┐
│       User Natural Language Input    │
│  "Turn this article into a podcast   │
│   https://..."                       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│        Claude Code Skill             │
│  • Smart source type detection       │
│  • Auto-invoke appropriate tools     │
└──────────────┬──────────────────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
┌──────────┐     ┌─────────────┐
│  WeChat   │     │ Other Formats│
│  MCP Fetch│     │ markitdown   │
└─────┬────┘     └──────┬──────┘
      │                 │
      └────────┬────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         NotebookLM API               │
│  • Upload content sources            │
│  • AI-generate target formats        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         Generated Files              │
│  .mp3 / .mp4 / .pdf / .json / .md   │
│  .png / .csv / .html                 │
└─────────────────────────────────────┘
```

## 🔧 Advanced Usage

### Specify Existing Notebook

```
Add this article to my "AI Research" notebook https://example.com
```

### Batch Processing

```
Generate podcasts from all of these:
1. https://mp.weixin.qq.com/s/abc123
2. https://example.com/article2
3. /Users/joe/notes.md
```

### ZIP Batch Conversion

```
Turn all documents in this archive into a podcast /path/to/files.zip
```

Auto-extract, identify, convert, and merge.

### Research → Content Pipeline

```bash
# Discover sources automatically, then generate
notebooklm source add-research "climate change policy" --mode deep --import-all
notebooklm generate audio "Focus on policy solutions" --format debate --wait
notebooklm download audio ./climate-podcast.mp3
```

### Chat with Your Sources

```bash
notebooklm ask "What are the key themes across all sources?"
notebooklm ask "Compare the two viewpoints" -s src1 -s src2
```

## 🐛 Troubleshooting

### MCP Tool Not Found

```bash
# Test MCP server
~/.claude/skills/anything-to-notebooklm/.venv/bin/python \
  ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py

# Reinstall dependencies
cd ~/.claude/skills/anything-to-notebooklm
./install.sh
```

### NotebookLM Authentication Failed

```bash
./bin/notebooklm auth check --test  # Full diagnostic
./bin/notebooklm login              # Re-authenticate
./bin/notebooklm list               # Verify
```

### Environment Check

```bash
./check_env.py       # 9-point comprehensive check
./install.sh         # Reinstall
```

## 🤝 Contributing

PRs, Issues, and suggestions welcome!

## ❓ FAQ

<details>
<summary><b>Q: What languages are supported?</b></summary>

A: NotebookLM supports 80+ languages. Set with `notebooklm language set <code>`. English and Chinese work best.
</details>

<details>
<summary><b>Q: Whose voice is the podcast?</b></summary>

A: Google AI voice synthesis. English features two AI hosts in dialogue; other languages typically use single narrator.
</details>

<details>
<summary><b>Q: What are the content length limits?</b></summary>

A:
- Minimum: ~500 words
- Maximum: ~500K words
- Recommended: 1,000–10,000 words for best results
</details>

<details>
<summary><b>Q: Can I use this commercially?</b></summary>

A:
- This Skill: MIT open source, free to use
- Generated content: Subject to NotebookLM Terms of Service
- Source content: Subject to original content copyright
- Recommendation: For personal learning and research only
</details>

<details>
<summary><b>Q: Why is MCP needed?</b></summary>

A: WeChat articles have anti-scraping protection. MCP uses browser simulation to bypass it. Other sources (web pages, YouTube, PDFs) don't need MCP.
</details>

<details>
<summary><b>Q: What podcast formats are available?</b></summary>

A: Four formats via `--format`: deep-dive (default, thorough exploration), brief (concise overview), critique (critical analysis), and debate (two-sided discussion). Three lengths: short, default, long.
</details>

<details>
<summary><b>Q: What video styles are available?</b></summary>

A: Nine styles via `--style`: auto, classic, whiteboard, kawaii, anime, watercolor, retro-print, heritage, paper-craft.
</details>

## 📄 License

[MIT License](LICENSE)

## 🙏 Acknowledgements

- [Google NotebookLM](https://notebooklm.google.com/) — AI content generation
- [Microsoft markitdown](https://github.com/microsoft/markitdown) — File format conversion
- [wexin-read-mcp](https://github.com/Bwkyd/wexin-read-mcp) — WeChat article fetching
- [notebooklm-py](https://github.com/teng-lin/notebooklm-py) — NotebookLM CLI

## 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/stanvx/anything-to-notebooklm/issues)
- **Original Repo**: [joeseesun/anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm)

---

<div align="center">

**If you find this useful, please give it a ⭐ Star!**

Fork of [joeseesun/anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm)

</div>
