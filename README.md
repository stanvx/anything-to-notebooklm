# 多源内容 → NotebookLM 智能处理器

自动从多种来源（微信公众号、网页、YouTube、PDF、Markdown等）获取内容，上传到 NotebookLM，并根据自然语言指令生成播客、PPT、思维导图、Quiz 等多种格式内容。

## 支持的内容源

| 内容源 | 示例 | 自动识别 |
|-------|------|---------|
| 微信公众号 | `https://mp.weixin.qq.com/s/xxx` | ✅ |
| 任意网页 | `https://example.com/article` | ✅ |
| YouTube | `https://youtube.com/watch?v=xxx` | ✅ |
| PDF | `/path/to/file.pdf` | ✅ |
| Markdown | `/path/to/file.md` | ✅ |
| 搜索关键词 | "搜索 'AI趋势'" | ✅ |

## 快速开始

### 1. 安装

```bash
cd ~/.claude/skills/
git clone <this-repo> weixin-to-notebooklm
cd weixin-to-notebooklm
./install.sh
```

安装脚本会自动：
- ✅ 检查 Python 环境（需要 3.9+）
- ✅ 克隆并安装 wexin-read-mcp（MCP 服务器）
- ✅ 安装所有 Python 依赖
- ✅ 安装 Playwright 浏览器
- ✅ 安装 notebooklm-py CLI 工具

### 2. 配置 MCP 服务器

编辑 `~/.claude/config.json`，添加：

```json
{
  "primaryApiKey": "any",
  "mcpServers": {
    "weixin-reader": {
      "command": "python",
      "args": [
        "/Users/<你的用户名>/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/src/server.py"
      ]
    }
  }
}
```

**⚠️ 配置后需要重启 Claude Code！**

### 3. NotebookLM 认证

首次使用前：

```bash
notebooklm login
notebooklm list  # 验证认证成功
```

### 4. 环境检查

随时运行检查脚本验证环境：

```bash
./check_env.py
```

## 使用方式

### 微信公众号
```
把这篇微信文章生成播客 https://mp.weixin.qq.com/s/xxx
```

### 网页链接
```
把这个网页做成PPT https://example.com/article
```

### YouTube 视频
```
这个视频帮我画个思维导图 https://youtube.com/watch?v=xxx
```

### 本地文件
```
把这个PDF上传生成报告 /path/to/file.pdf
这个Markdown生成Quiz /path/to/notes.md
```

### 搜索关键词
```
搜索 'AI发展趋势 2026' 并生成报告
搜索关于'量子计算'的资料做成播客
```

### 混合多源
```
把这篇文章、这个视频和这个PDF一起做成PPT：
- https://example.com/article
- https://youtube.com/watch?v=xyz
- /Users/joe/research.pdf
```

### 支持的内容格式

| 用户说 | 生成格式 | 输出文件 |
|--------|---------|---------|
| "生成播客" / "做成音频" | Audio Podcast | `.mp3` |
| "做成PPT" / "生成幻灯片" | Slide Deck | `.pdf` |
| "画个思维导图" / "生成脑图" | Mind Map | `.json` |
| "生成Quiz" / "出题" | Quiz | `.md` |
| "做个视频" | Video | `.mp4` |
| "生成报告" / "写个总结" | Report | `.md` |
| "做个信息图" | Infographic | `.png` |
| "生成数据表" | Data Table | `.csv` |
| "做成闪卡" | Flashcards | `.md` |

## 文件结构

```
weixin-to-notebooklm/
├── SKILL.md           # 完整使用文档
├── README.md          # 本文件
├── install.sh         # 一键安装脚本
├── check_env.py       # 环境检查脚本
├── requirements.txt   # Python 依赖
└── wexin-read-mcp/    # MCP 服务器（自动克隆）
    ├── src/
    │   ├── server.py
    │   └── scraper.py
    └── requirements.txt
```

## 依赖项

### Python 依赖
- fastmcp >= 0.1.0
- playwright >= 1.40.0
- beautifulsoup4 >= 4.12.0
- lxml >= 4.9.0

### 外部工具
- [notebooklm-py](https://github.com/teng-lin/notebooklm-py) - NotebookLM CLI 工具
- [wexin-read-mcp](https://github.com/Bwkyd/wexin-read-mcp) - 微信公众号文章读取 MCP 服务器（可选，仅微信公众号需要）

## 故障排查

### MCP 工具未找到

```bash
# 测试 MCP 服务器
python ~/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/src/server.py

# 重新安装依赖
cd ~/.claude/skills/weixin-to-notebooklm/wexin-read-mcp
pip install -r requirements.txt
playwright install chromium
```

### NotebookLM 命令失败

```bash
# 检查认证状态
notebooklm status

# 重新登录
notebooklm login

# 验证
notebooklm list
```

### 环境检查失败

```bash
# 运行环境检查
./check_env.py

# 根据提示修复问题
```

## 注意事项

1. **频率限制**：每次请求间隔 > 2 秒，避免被微信封禁
2. **内容长度**：微信文章通常 1000-5000 字最合适
3. **版权遵守**：仅用于个人学习研究
4. **生成时间**：播客 2-5 分钟，视频 3-8 分钟，PPT 1-3 分钟

## 许可证

MIT License

## 相关项目

- [wexin-read-mcp](https://github.com/Bwkyd/wexin-read-mcp) - 微信文章读取 MCP 服务器
- [notebooklm-py](https://github.com/teng-lin/notebooklm-py) - NotebookLM Python CLI

---

**Skill 版本**：v1.0.0
**创建时间**：2026-01-25
**最后更新**：2026-01-25
