#!/bin/bash

# insert.sh - 通用文件插入工具
# 用途：读取并显示指定文件内容
# 使用场景：在 Claude Code skill 中动态插入外部规则文件

set -e  # 遇到错误立即退出

# 颜色输出定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 使用方法提示
usage() {
    echo -e "${YELLOW}用法:${NC} insert.sh <文件路径> [章节关键词]"
    echo -e "${YELLOW}示例:${NC}"
    echo "  insert.sh references/syslawer/GB-01.md"
    echo "  insert.sh references/syslawer/INDEX.md \"数据编码\""
    exit 1
}

# 错误处理函数
error_exit() {
    echo -e "${RED}错误:${NC} $1" >&2
    exit 1
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        usage
    fi

    local filepath="$1"
    local section_keyword="${2:-}"

    # 检查文件是否存在
    if [ ! -f "$filepath" ]; then
        error_exit "文件不存在: $filepath"
    fi

    # 检查文件可读性
    if [ ! -r "$filepath" ]; then
        error_exit "文件不可读: $filepath"
    fi

    # 获取脚本所在目录作为基准
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local skill_root="$(dirname "$script_dir")"

    # 如果路径是相对路径，相对于 skill 根目录解析
    if [[ "$filepath" != /* ]]; then
        filepath="${skill_root}/${filepath}"
    fi

    # 如果没有指定章节，直接输出整个文件
    if [ -z "$section_keyword" ]; then
        echo -e "${GREEN}--- 开始插入 ${filepath} ---${NC}"
        cat "$filepath"
        echo -e "${GREEN}--- 结束插入 ${filepath} ---${NC}"
    else
        # 如果有章节关键词，提取相关内容
        echo -e "${GREEN}--- 开始插入 ${filepath} （章节：${section_keyword}）---${NC}"

        # 查找包含章节关键词的行，并显示其后内容直到下一个标题或文件结束
        local line_num=$(grep -n "$section_keyword" "$filepath" | head -1 | cut -d: -f1)

        if [ -z "$line_num" ]; then
            error_exit "章节关键词 '${section_keyword}' 未找到"
        fi

        # 从匹配行开始，提取到下一个 # 标题之前的内容
        awk -v start="$line_num" '
            NR >= start {
                if (NR == start) print
                else if (/^#/) exit
                else print
            }
        ' "$filepath"

        echo -e "${GREEN}--- 结束插入 ${filepath} ---${NC}"
    fi
}

# 执行主函数
main "$@"
