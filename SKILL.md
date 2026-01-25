---
name: weixin-to-notebooklm
description: 从微信读书获取内容并上传到NotebookLM，支持自然语言生成各类内容（播客/PPT/思维导图/Quiz等）
user-invocable: true
homepage: https://github.com/Bwkyd/wexin-read-mcp
---

# 微信读书 → NotebookLM 智能处理器

自动从微信公众号获取文章内容，上传到 NotebookLM，并根据自然语言指令生成各类内容。

## 前置条件

### 1. 安装 wexin-read-mcp

MCP 服务器已安装在：`~/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/`

**配置 MCP**（需要手动添加到 Claude 配置文件）：

**macOS**: 编辑 `~/.claude/config.json`

```json
{
  "primaryApiKey": "any",
  "mcpServers": {
    "weixin-reader": {
      "command": "python",
      "args": [
        "/Users/joe/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/src/server.py"
      ]
    }
  }
}
```

**配置后需要重启 Claude Code。**

### 2. notebooklm 认证

首次使用前必须认证：

```bash
notebooklm login
notebooklm list  # 验证认证成功
```

## 触发方式

### 基础触发

- `/weixin-to-notebooklm [链接]`
- "把这篇微信文章传到NotebookLM"
- "上传这篇文章到NotebookLM"

### 带处理意图的触发

- "把这篇微信文章**生成播客**"
- "这篇文章帮我**做成PPT**"
- "帮我**画个思维导图**，链接：xxx"
- "这篇文章**生成一个Quiz**"
- "用这篇文章**做个视频**"

## 自然语言 → NotebookLM 功能映射

| 用户说的话 | 识别意图 | NotebookLM 命令 |
|-----------|---------|----------------|
| "生成播客" / "做成音频" / "转成语音" | audio | `generate audio` |
| "做成PPT" / "生成幻灯片" / "做个演示" | slide-deck | `generate slide-deck` |
| "画个思维导图" / "生成脑图" / "做个导图" | mind-map | `generate mind-map` |
| "生成Quiz" / "出题" / "做个测验" | quiz | `generate quiz` |
| "做个视频" / "生成视频" | video | `generate video` |
| "生成报告" / "写个总结" / "整理成文档" | report | `generate report` |
| "做个信息图" / "可视化" | infographic | `generate infographic` |
| "生成数据表" / "做个表格" | data-table | `generate data-table` |
| "做成闪卡" / "生成记忆卡片" | flashcards | `generate flashcards` |

**如果没有明确指令**，默认只上传不生成任何内容，等待用户后续指令。

## 工作流程

### Step 1: 解析用户意图

从用户输入中提取：
1. **微信文章 URL**（必须）
2. **处理意图**（可选）：播客/PPT/思维导图/Quiz 等

**示例**：
```
输入："把这篇文章生成播客 https://mp.weixin.qq.com/s/abc123"
解析：
  - URL: https://mp.weixin.qq.com/s/abc123
  - 意图: audio
```

### Step 2: 获取微信文章内容

使用 MCP 工具 `read_weixin_article` 获取文章。

**返回数据**：
```json
{
  "success": true,
  "title": "文章标题",
  "author": "作者",
  "publish_time": "发布时间",
  "content": "文章内容（纯文本）"
}
```

### Step 3: 创建 TXT 文件

将内容转换为标准格式：

```
标题：{title}
作者：{author}
发布时间：{publish_time}

{content}
```

**保存路径**：`/tmp/weixin_{sanitized_title}_{timestamp}.txt`

**为什么用 TXT？**
- 轻量快速，上传更稳定
- NotebookLM 对纯文本处理效果更好
- 无需额外依赖（PDF 需要额外库）

### Step 4: 上传到 NotebookLM

调用 `notebooklm` skill：

```bash
notebooklm create "{title}"  # 创建新笔记本
notebooklm source add /tmp/weixin_xxx.txt --wait  # 上传文件并等待处理完成
```

**等待处理完成很重要**，否则后续生成会失败。

### Step 5: 根据意图生成内容（可选）

如果用户指定了处理意图，自动调用对应命令：

| 意图 | 命令 | 等待 | 下载 |
|------|------|------|------|
| audio | `notebooklm generate audio` | `artifact wait` | `download audio ./output.mp3` |
| slide-deck | `notebooklm generate slide-deck` | `artifact wait` | `download slide-deck ./output.pdf` |
| mind-map | `notebooklm generate mind-map` | `artifact wait` | `download mind-map ./map.json` |
| quiz | `notebooklm generate quiz` | `artifact wait` | `download quiz ./quiz.md --format markdown` |
| video | `notebooklm generate video` | `artifact wait` | `download video ./output.mp4` |
| report | `notebooklm generate report` | `artifact wait` | `download report ./report.md` |
| infographic | `notebooklm generate infographic` | `artifact wait` | `download infographic ./infographic.png` |
| flashcards | `notebooklm generate flashcards` | `artifact wait` | `download flashcards ./cards.md --format markdown` |

**生成流程**：
1. 发起生成请求（返回 task_id）
2. 等待生成完成（`artifact wait <task_id>`）
3. 下载生成的文件到本地
4. 告知用户文件路径

## 完整示例

### 示例 1：只上传不处理

**用户输入**：
```
/weixin-to-notebooklm https://mp.weixin.qq.com/s/abc123xyz
```

**执行流程**：
1. 获取文章内容
2. 创建 TXT 文件
3. 上传到 NotebookLM
4. 完成

**输出**：
```
✅ 微信文章已上传到 NotebookLM！

📄 文章：深度学习的未来趋势
👤 作者：张三
📅 发布：2026-01-20

📓 Notebook ID：abc123de-xxxx-xxxx
📎 Source ID：def456gh-xxxx-xxxx

💬 你可以继续：
- "生成播客"
- "做成PPT"
- "画个思维导图"
- 或者用 NotebookLM 网页端查看
```

### 示例 2：上传并生成播客

**用户输入**：
```
把这篇文章生成播客 https://mp.weixin.qq.com/s/abc123xyz
```

**执行流程**：
1. 获取文章内容
2. 创建 TXT 文件
3. 上传到 NotebookLM 并等待处理完成
4. 生成播客（`generate audio`）
5. 等待播客生成完成（约 2-5 分钟）
6. 下载播客到本地

**输出**：
```
✅ 微信文章已转换为播客！

📄 文章：深度学习的未来趋势
👤 作者：张三
📅 发布：2026-01-20

🎙️ 播客已生成：
📁 文件：/tmp/weixin_深度学习的未来趋势_podcast.mp3
⏱️ 时长：约 8 分钟
📊 大小：12.3 MB

💡 你也可以：
- "做成PPT"
- "画个思维导图"
- "生成Quiz"
```

### 示例 3：上传并生成 PPT

**用户输入**：
```
这篇文章帮我做成PPT https://mp.weixin.qq.com/s/abc123xyz
```

**执行流程**：
1-3. 同上
4. 生成幻灯片（`generate slide-deck`）
5. 等待生成完成
6. 下载 PDF 格式的幻灯片

**输出**：
```
✅ 微信文章已转换为PPT！

📄 文章：深度学习的未来趋势
👤 作者：张三

📊 PPT 已生成：
📁 文件：/tmp/weixin_深度学习的未来趋势_slides.pdf
📄 页数：15 页
📦 大小：2.4 MB

💡 可以用 Keynote/PowerPoint 打开编辑
```

### 示例 4：批量处理（高级）

**用户输入**：
```
把这些文章都生成播客：
1. https://mp.weixin.qq.com/s/abc123
2. https://mp.weixin.qq.com/s/def456
3. https://mp.weixin.qq.com/s/ghi789
```

**执行流程**：
1. 依次处理每篇文章
2. 为每篇文章创建独立的 Notebook
3. 生成独立的播客文件

**输出**：
```
✅ 批量处理完成！

🎙️ 播客 1：深度学习的未来趋势
📁 /tmp/weixin_深度学习_podcast.mp3 (12.3 MB)

🎙️ 播客 2：GPT-5 的技术突破
📁 /tmp/weixin_GPT5_podcast.mp3 (9.8 MB)

🎙️ 播客 3：AI 伦理的思考
📁 /tmp/weixin_AI伦理_podcast.mp3 (11.2 MB)

💾 所有文件已保存到 /tmp/
```

## 错误处理

### URL 格式错误
```
❌ 错误：URL 格式不正确

必须是微信公众号文章链接：
https://mp.weixin.qq.com/s/xxx

你提供的链接：https://example.com
```

### 文章获取失败
```
❌ 错误：无法获取文章内容

可能原因：
1. 文章已被删除
2. 文章需要登录查看（暂不支持）
3. 网络连接问题
4. 微信反爬虫拦截（请稍后重试）

建议：
- 检查链接是否正确
- 等待 2-3 秒后重试
- 或手动复制文章内容
```

### NotebookLM 认证失败
```
❌ 错误：NotebookLM 认证失败

请运行以下命令重新登录：
  notebooklm login

然后验证：
  notebooklm list
```

### 生成任务失败
```
❌ 错误：播客生成失败

可能原因：
1. 文章内容太短（< 100 字）
2. 文章内容太长（> 50万字）
3. NotebookLM 服务异常

建议：
- 检查文章长度是否适中
- 稍后重试
- 或尝试其他格式（如生成报告）
```

## 高级功能

### 1. 多意图处理

用户可以一次性指定多个处理任务：

```
这篇文章帮我生成播客和PPT https://mp.weixin.qq.com/s/abc123
```

Skill 会依次执行：
1. 生成播客
2. 生成 PPT

### 2. 自定义 Notebook

默认每篇文章创建新 Notebook，也可以指定已有 Notebook：

```
把这篇文章加到我的【AI研究】笔记本 https://mp.weixin.qq.com/s/abc123
```

Skill 会：
1. 搜索名为"AI研究"的 Notebook
2. 将文章添加为新 Source
3. 基于所有 Sources 生成内容

### 3. 自定义生成指令

为生成任务添加具体要求：

```
这篇文章生成播客，要求：轻松幽默的风格，时长控制在5分钟
```

Skill 会将要求作为 instructions 传给 NotebookLM。

## 注意事项

1. **频率限制**：
   - 每次请求间隔 > 2 秒，避免被微信封禁
   - NotebookLM 生成任务有并发限制（最多 3 个同时进行）

2. **内容长度**：
   - 微信文章通常 1000-5000 字，适合生成播客（3-8 分钟）
   - 超过 10000 字的长文可能需要更长生成时间
   - 少于 500 字的短文可能生成效果不佳

3. **版权遵守**：
   - 仅用于个人学习研究
   - 遵守微信公众号的版权规定
   - 生成的内容不得用于商业用途

4. **生成时间**：
   - 播客：2-5 分钟
   - 视频：3-8 分钟
   - PPT：1-3 分钟
   - 思维导图：1-2 分钟
   - Quiz/闪卡：1-2 分钟

5. **文件清理**：
   - TXT 源文件保存在 `/tmp/`，系统重启后自动清理
   - 生成的文件（MP3/PDF/MD 等）默认保存在 `/tmp/`
   - 可以指定自定义保存路径

## 相关 Skills

- `notebooklm` - NotebookLM 核心功能
- `notebooklm-deep-analyzer` - 深度分析 NotebookLM 内容
- `markitdown` - 转换其他格式文档

## 配置 MCP（重要）

⚠️ **第一次使用前必须配置**

编辑 `~/.claude/config.json`：

```json
{
  "primaryApiKey": "any",
  "mcpServers": {
    "weixin-reader": {
      "command": "python",
      "args": [
        "/Users/joe/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/src/server.py"
      ]
    }
  }
}
```

**配置后重启 Claude Code！**

## 故障排查

### 1. MCP 工具未找到

```bash
# 测试 MCP 服务器
python ~/.claude/skills/weixin-to-notebooklm/wexin-read-mcp/src/server.py

# 如果报错，检查依赖
cd ~/.claude/skills/weixin-to-notebooklm/wexin-read-mcp
pip install -r requirements.txt
playwright install chromium
```

### 2. NotebookLM 命令失败

```bash
# 检查认证状态
notebooklm status

# 重新登录
notebooklm login

# 验证
notebooklm list
```

### 3. 文件权限问题

```bash
# 确保临时目录可写
chmod 755 /tmp

# 测试写入
touch /tmp/test.txt && rm /tmp/test.txt
```

### 4. 生成任务卡住

```bash
# 检查任务状态
notebooklm artifact list

# 如果显示 "pending" 超过 10 分钟，取消重试
# （目前 CLI 不支持取消，需要在网页端操作）
```

## 典型使用场景

### 场景 1：快速学习

```
我想学习这篇文章，帮我生成播客，上下班路上听
链接：https://mp.weixin.qq.com/s/abc123
```

→ 生成 8 分钟播客，通勤时间听完

### 场景 2：分享给团队

```
这篇文章不错，做成PPT分享给团队
https://mp.weixin.qq.com/s/abc123
```

→ 生成 15 页 PPT，直接用于团队分享

### 场景 3：复习巩固

```
这篇技术文章帮我出题，想测试一下掌握程度
https://mp.weixin.qq.com/s/abc123
```

→ 生成 10 道选择题 + 5 道简答题

### 场景 4：可视化理解

```
这篇文章概念比较多，画个思维导图帮我理清结构
https://mp.weixin.qq.com/s/abc123
```

→ 生成思维导图，一目了然

---

**Skill 创建时间**：2026-01-25
**最后更新**：2026-01-25
**版本**：v1.0.0
