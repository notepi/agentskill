# Claude Code Skill 设计规范

> 基于官方文档和社区最佳实践整理
> 创建日期：2024-01-11

## 目录
1. [核心概念](#核心概念)
2. [SKILL.md 文件规范](#skillmd-文件规范)
3. [Description 优化（最关键）](#description-优化最关键)
4. [目录结构标准](#目录结构标准)
5. [触发短语优化](#触发短语优化)
6. [反模式（要避免）](#反模式要避免)
7. [Token 优化策略](#token-优化策略)
8. [测试清单](#测试清单)
9. [官方示例](#官方示例)
10. [性能优化](#性能优化)

---

## 核心概念

### Skill 是什么？
Skill 是 Claude Code 的模块化扩展，通过加载特定领域知识，将通用 AI 转变为专业助手。

### 工作原理
```
用户输入 → Claude 分析 → 匹配 Description → 加载 Skill → 执行
```

### 关键指标
- **触发率**：关键短语出现的命中率（目标 80%+）
- **Token 成本**：单次加载消耗的 token 量（目标 < 5k）
- **成功率**：正确理解用户意图并执行的比例

---

## SKILL.md 文件规范

### 文件结构

```yaml
---
name: skill-name                    # 必需：小写、数字、连字符，≤64字符
description: "技能描述"            # 必需：最关键字段，≤1024字符
version: 1.0.0                      # 可选
author: Your Name                   # 可选
tags: [tag1, tag2]                  # 可选
---

# 技能内容（Markdown 格式）
```

### 行数和 Token 限制

```
├─ SKILL.md：≤ 500 行
├─ Token 总量：≤ 5,000 tokens
└─ 超过此限制会影响加载速度和成本
```

### 内容格式要求

**✅ 推荐：**
- 使用第三人称命令式（"Create...", "Run..."）
- 动词开头，明确具体
- 分步说明，条理清晰

**❌ 避免：**
- 第一人称（"I will help you..."）
- 模糊描述（"This helps with stuff"）
- 过长的段落

---

## Description 优化（最关键）

### 触发率对比

| 描述质量 | 触发率 | 示例 |
|---------|-------|------|
| **优秀** | 80-84% | 包含具体动词+完整短语+同义词 |
| **一般** | 50-60% | 只有基本描述 |
| **较差** | ~20% | 模糊简短 |

### 最佳模板（复制即可用）

```yaml
description: This skill should be used when the user asks to "create X", "build X", "generate X", or "implement X", or asks "how to create X", "what's the best way to X", or works with X-related tasks. It can do [specific capabilities] and outputs [specific outputs].
```

### 关键要素

1. **具体动词**（至少 3-5 个）：
   ```
   create, build, generate, make, implement, setup, configure, initialize
   ```

2. **完整短语**（用户实际会说的）：
   ```
   "create a React component"
   "setup database connection"
   "initialize git repository"
   ```

3. **问题形式**：
   ```
   "how to create X"
   "what's the best way to X"
   "can you help me build X"
   ```

4. **同义词覆盖**：
   ```
   component / module / widget
   project / app / application
   test / testing / unit test
   ```

### 示例对比

**✅ 优秀示例（推荐）：**
```yaml
description: This skill should be used when the user asks to "create a React component", "build React UI", "generate React code", or "make React elements", or asks "how to create React components", "what's the best way to build React UI", or works with React development tasks. It can create functional components, class components, hooks, and related files.
```

**❌ 较差示例（避免）：**
```yaml
description: I help you with React components.
```

---

## 目录结构标准

### 标准结构

```
.claude/skills/your-skill/
├── SKILL.md                    # 主文件（必需）
├── references/                  # 参考文档（可选）
│   ├── detailed-guide.md
│   └── best-practices.md
├── examples/                    # 示例代码（可选）
│   ├── example-1.js
│   └── config-sample.json
└── scripts/                     # 实用脚本（可选）
    ├── helper.sh
    └── validate.py
```

### 各目录用途

**references/**
- 详细的技术说明
- API 文档
- 配置指南
- 故障排查文档

**examples/**
- 工作代码示例
- 配置文件示例
- 完整项目模板

**scripts/**
- 辅助脚本
- 验证工具
- 自动化命令

### 渐进式披露（Progressive Disclosure）

Claude Code 使用 3 层加载机制：

```
用户询问
  ↓
1. 加载 Metadata（name, description, version）
    ↓ 关键词匹配成功
2. 加载 SKILL.md（核心指令）
    ↓ 需要更多细节
3. 加载 references/, examples/, scripts/
```

**好处：**
- 不用的资源不加载，节省 token
- 快速响应简单请求
- 深层资源按需加载

---

## 触发短语优化

### 测试方法论

创建 skill 后必须进行 5 项测试：

1. **直接调用**
   ```
   用户说："Please use [skill name] to create a component"
   期望：✅ 100% 触发
   ```

2. **关键词触发**
   ```
   用户说："create a React component"
   期望：✅ 应该触发
   ```

3. **间接提及**
   ```
   用户说："I want to build something with React"
   期望：⚠️ 可能触发（看 description 质量）
   ```

4. **边界测试（不应触发）**
   ```
   用户说："what's for dinner"
   期望：❌ 绝对不触发
   ```

5. **稳定性测试**
   ```
   连续使用 3-5 次相同短语
   期望：✅ 每次都应触发
   ```

### 优化清单

- [ ] 包含至少 3-5 个具体动词
- [ ] 包含完整短语（不仅是单词）
- [ ] 包含问题形式（"how to...", "what's..."）
- [ ] 包含同义词（component/module/widget）
- [ ] 不超过 1024 字符
- [ ] 使用第三人称（"This skill should..."）

---

## 反模式（要避免）

### ❌ 反模式 1：过度膨胀

**错误示范：**
```
SKILL.md：800 行
├─ 详细说明 A（200 行）
├─ 详细说明 B（200 行）
├─ 代码示例 A（150 行）
├─ 代码示例 B（150 行）
└─ 大量内联代码
```

**正确做法：**
```
SKILL.md：250 行（核心指令）
├─ references/guide-a.md（200 行）
├─ examples/sample-a.js（150 行）
└─ scripts/detailed-setup.sh（复杂逻辑）
```

### ❌ 反模式 2：硬编码路径

**错误示范：**
```bash
# 不可移植
rm -rf /Users/yourname/temp/
cd /home/user/projects/
```

**正确做法：**
```bash
# 可移植
rm -rf "$TEMP_DIR"
cd "$PROJECT_ROOT"
```

### ❌ 反模式 3：第一人称描述

**错误示范：**
```yaml
description: I will help you create projects and set up development environments.
```

**正确做法：**
```yaml
description: This skill should be used when the user asks to "create projects", "setup development environments", or "initialize repositories"...
```

### ❌ 反模式 4：缺少错误处理

**错误示范：**
```bash
# 直接执行，不检查
docker build -t myapp .
npm install
```

**正确做法：**
```bash
# 检查前置条件
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if [ -f package.json ]; then
    npm install
fi
```

### ❌ 反模式 5：跨平台不兼容

**错误示范：**
```bash
# 仅适用于 macOS
open index.html

# 仅适用于 Linux
xdg-open index.html

# 仅适用于 Windows
start index.html
```

**正确做法：**
```bash
# 跨平台检测
if [[ "$OSTYPE" == "darwin"* ]]; then
    open index.html
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open index.html
fi
```

---

## Token 优化策略

### 优化前后对比

| 优化手段 | 优化前 | 优化后 | 节省 |
|---------|--------|--------|------|
| 将详细说明移到 references/ | 8000 tokens | 2500 tokens | 70% |
| 代码示例移到 examples/ | 5000 tokens | 1500 tokens | 70% |
| 长脚本移到 scripts/ | 3000 tokens | 1000 tokens | 65% |
| 删除重复内容 | 4000 tokens | 2500 tokens | 35% |

### 实用技巧

**1. 使用引用链接**
```markdown
# 优化前（200 tokens）
## 详细配置
这里有很多配置说明...
...
（150 行内容）

# 优化后（20 tokens）
## 详细配置
见 `references/detailed-config.md`
```

**2. 使用摘要 + 详细链接**
```markdown
# 优化前
## API 说明
GET /users - 获取用户列表
POST /users - 创建用户
PUT /users/:id - 更新用户
DELETE /users/:id - 删除用户
（详细说明 100 行）

# 优化后
## API 说明
基础 CRUD 操作，详见 `references/api-reference.md`
```

**3. 脚本外置**
```markdown
# 优化前
```bash
#!/bin/bash
# 复杂脚本 200 行...
...
```

# 优化后
运行 `scripts/complex-setup.sh` 完成配置
```

---

## 测试清单

创建 skill 后必须完成的 10 项检查：

### 文件结构
- [ ] SKILL.md 存在且格式正确
- [ ] YAML frontmatter 在文件顶部
- [ ] name 字段使用小写+连字符
- [ ] description 字段 ≤ 1024 字符
- [ ] 文件总行数 ≤ 500 行
- [ ] Token 总量 ≤ 5000 tokens

### 内容质量
- [ ] 使用第三人称描述
- [ ] 包含具体动词和完整短语
- [ ] 包含至少 3-5 个触发变体
- [ ] 使用命令式/动词开头句式
- [ ] 避免模糊和笼统的描述

### 功能测试
- [ ] 测试 1：直接调用（"Please use [skill name]"）
- [ ] 测试 2：关键词触发（"create X"）
- [ ] 测试 3：间接提及（"I need to..."）
- [ ] 测试 4：不应触发（无关短语）
- [ ] 测试 5：重复稳定性（测试 3-5 次）

### 代码质量
- [ ] 所有脚本有错误处理
- [ ] 没有硬编码的绝对路径
- [ ] 支持跨平台（macOS/Linux/Windows）
- [ ] 敏感信息使用环境变量
- [ ] 复杂逻辑移到 scripts/ 目录

---

## 官方示例

### 安装官方技能

Anthropic 提供官方技能库：

```bash
# PDF 文档处理
/plugin install document-skills@anthropic-agent-skills

# Web 应用测试
/plugin install web-app-testing@anthropic-agent-skills

# 品牌规范应用
/plugin install brand-guidelines@anthropic-agent-skills
```

### 官方技能列表

来自 `github.com/anthropics/skills`：

1. **PDF Skill** - PDF 文本提取、合并/分割、合同分析
2. **Skill Creator** - 帮助创建自定义 skills
3. **Web App Testing** - 使用 Playwright 的自动化测试
4. **MCP Builder** - 生成 MCP 服务器
5. **Brand Guidelines** - 应用品牌颜色和排版

### 社区资源

- **travisvn/awesome-claude-skills** - 精选 skills 列表
- **meetrais/claude-agent-skills** - 示例实现
- **sjnims/plugin-dev** - 综合开发工具包

---

## 性能优化

### 渐进式披露（官方推荐）

3 层加载机制：

```
用户询问
  ↓
┌─────────────────────────────────────┐
│ 第 1 层：加载 Metadata              │
│ （name, description, version）       │
│ 成本：~50 tokens                    │
└─────────────────────────────────────┘
  ↓ 关键词匹配
┌─────────────────────────────────────┐
│ 第 2 层：加载 SKILL.md              │
│ （核心指令）                         │
│ 成本：500-2000 tokens               │
└─────────────────────────────────────┘
  ↓ 需要更多细节
┌─────────────────────────────────────┐
│ 第 3 层：加载辅助资源               │
│ （references/, examples/, scripts/）│
│ 成本：动态计算                      │
└─────────────────────────────────────┘
```

### 优势

- **快速响应**：简单请求只加载基础内容
- **成本控制**：不用的资源不消耗 token
- **按需加载**：只在需要时加载详细内容

### 实现方式

在 SKILL.md 中使用引用：

```markdown
## 详细说明
见 `references/detailed-guide.md`

## 代码示例
见 `examples/sample-code.js`

## 复杂脚本
运行 `scripts/setup.sh`
```

---

## 总结

### 最重要的 5 条建议

1. **描述决定一切**：花 80% 时间优化 description 字段
2. **保持精简**：SKILL.md < 500 行，token < 5k
3. **渐进式披露**：细节放在 references/、examples/、scripts/
4. **充分测试**：5 项测试确保触发率 80%+
5. **避免反模式**：硬编码、跨平台不兼容、缺少错误处理

### 效果对比

| 指标 | 普通 skill | 优化后 skill | 提升 |
|-----|-----------|-------------|------|
| 触发率 | ~20% | 80-84% | 4 倍 |
| Token 使用 | 8000+ | 2000-3000 | 节省 70% |
| 首次响应 | 慢 | 快 | 显著改善 |
| 成功率 | 60% | 90%+ | 大幅提高 |

---

## 参考资料

- [Claude Code 技能文档](https://code.claude.com/docs/en/skills)
- [Claude Platform Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Anthropic 官方 Skills 仓库](https://github.com/anthropics/skills)
- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills)
- [AgentSkill.space](https://agentskill.space) - 150+ 免费 skills

---

**文档版本**：1.0.0
**最后更新**：2024-01-11
**创建者**：Claude Code
