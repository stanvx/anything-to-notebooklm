# Troubleshooting Guide

## Environment Check

Run the built-in environment check script:

```bash
./check_env.py    # Full 9-point diagnostic
```

## Common Issues

### NotebookLM Authentication Failed

```bash
./bin/notebooklm auth check --test   # Full diagnostic with network test
./bin/notebooklm login               # Re-authenticate (opens browser)
./bin/notebooklm list                # Verify authentication
```

If using CI/CD, set `NOTEBOOKLM_AUTH_JSON` environment variable with inline auth JSON.

### MCP Tool Not Found (WeChat Reader)

```bash
# Test the MCP server directly
~/.claude/skills/anything-to-notebooklm/.venv/bin/python \
  ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py

# Reinstall dependencies
cd ~/.claude/skills/anything-to-notebooklm
./install.sh
```

Verify MCP configuration in `~/.claude/config.json`:
```json
{
  "mcpServers": {
    "weixin-reader": {
      "command": "<SKILL_DIR>/.venv/bin/python",
      "args": ["<SKILL_DIR>/wexin-read-mcp/src/server.py"]
    }
  }
}
```

**Restart Claude Code after any MCP configuration changes.**

### Generation Task Stuck

```bash
notebooklm artifact list --type audio   # Check artifact status
notebooklm artifact poll <task_id>      # Poll specific task
```

If a task shows "pending" for >10 minutes, it likely failed silently. Create a new generation request.

### File Permission Issues

```bash
chmod 755 /tmp
touch /tmp/test.txt && rm /tmp/test.txt   # Verify write access
```

### Source Processing Delays

After uploading a source, wait for processing to complete before generating:

```bash
notebooklm source add ./file.pdf
notebooklm source wait <source_id> --timeout 120
```

### markitdown Conversion Failures

```bash
# Test markitdown directly
./bin/markitdown /path/to/file.pdf

# Recreate wrappers and refresh dependencies
./install.sh
```

### Rate Limiting

Use `--retry N` on generate commands for automatic exponential backoff:

```bash
notebooklm generate audio --retry 3 --wait
```

## Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| "Not logged in" | Authentication expired | `./bin/notebooklm login` |
| "Notebook not found" | Invalid/expired notebook ID | `notebooklm list` to get current IDs |
| "Source too short" | Content < ~500 words | Add more content or combine sources |
| "Source too long" | Content > ~500K words | Split into smaller documents |
| "Rate limit exceeded" | Too many requests | Wait 30s or use `--retry` |
| "Generation failed" | NotebookLM service error | Retry after a few minutes |
| "MCP tool not found" | MCP not configured | Check `~/.claude/config.json` |

## Reinstallation

```bash
cd ~/.claude/skills/anything-to-notebooklm
./install.sh    # Full reinstall of all dependencies
```
