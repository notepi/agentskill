# 文件插入工具配置说明

## 目录结构
```
inject/
├── insert.sh           # 主插入脚本
├── CONFIG.md           # 本配置文件
├── refs/              # 文件缓存目录（可选）
└── namespace.conf     # 命名空间映射（可选）
```

## 使用方法

### 基础用法
在 SKILL.md 中，使用以下指令调用插入工具：

```bash
# 插入完整文件
bash .claude/skills/cso-get/inject/insert.sh references/syslawer/GB-01.md

# 插入特定章节（按关键词匹配）
bash .claude/skills/cso-get/inject/insert.sh references/syslawer/INDEX.md "数据编码"
```

### 在 Claude Code 中的实际调用

由于 Claude Code skill 不支持直接调用 Bash，你需要在 SKILL.md 中添加明确的指示：

```markdown
当需要插入规则文件时，请执行以下步骤：
1. 调用 Bash 工具执行插入脚本
2. 读取并显示文件内容
3. 将内容整合到最终输出中

**示例指令：**
请执行脚本：bash .claude/skills/cso-get/inject/insert.sh references/syslawer/GB-01.md
```

## 支持的文件类型

- `.md` Markdown 文件（推荐）
- `.txt` 文本文件
- `.conf` 配置文件
- `.yml/.yaml` YAML 文件

## 章节提取规则

当使用章节关键词时，脚本会：
1. 查找包含该关键词的第一行
2. 从该行开始提取内容
3. 直到遇到下一个 `#` 标题或文件结尾

示例：
```bash
# 提取 [GB-01] 章节的内容
bash insert.sh references/syslawer/INDEX.md "[GB-01]"

# 提取 "数据编码" 相关的内容
bash insert.sh references/syslawer/DD.md "唯一合法格式"
```

## 错误处理

脚本提供详细的错误信息：
- 文件不存在：显示具体路径
- 文件不可读：显示权限问题
- 章节未找到：显示关键词

## 最佳实践

1. **路径使用相对路径**：相对于 skill 根目录
2. **文件命名规范**：使用有意义的文件名，如 `GB-01-recon-level.md`
3. **版本控制**：规则文件使用 Git 管理
4. **缓存机制**：对于大文件，可以在 refs/ 目录创建缓存
5. **命名空间管理**：使用 namespace.conf 映射常用路径

## 扩展功能

### 添加缓存（可选）
对于频繁查询的文件，可在脚本中添加缓存逻辑：
```bash
# 检查缓存
if [ -f "refs/$(basename $filepath).cache" ]; then
    cat "refs/$(basename $filepath).cache"
else
    # 生成缓存
    cat "$filepath" > "refs/$(basename $filepath).cache"
fi
```

### 命名空间映射（可选）
在 namespace.conf 中定义别名：
```ini
[aliases]
GB-01 = references/syslawer/GB-01.md
GB-02 = references/syslawer/GB-02.md
DD = references/syslawer/DD.md
```

然后在脚本中支持：
```bash
bash insert.sh GB-01  # 自动解析为完整路径
```
