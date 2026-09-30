#!/usr/bin/env bash
# memory-index-build — 给纯 Markdown 记忆库建索引（读 $HOME/memory，不依赖 obsidian）
# 生成：$HOME/memory/_index/TIMELINE.md（最近会话）+ _index/INDEX_BY_TAG.md（标签统计）
# 用法：bash memory-index-build.sh
# cron: 45 0 * * * bash $HOME/7stars/scripts/memory-index-build.sh
set -uo pipefail
MEM="${MEM_DIR:-$HOME/memory}"
IDX="$MEM/_index"
mkdir -p "$IDX"

# 1. TIMELINE：最近 10 个 session（按 mtime）
echo "## 会话时间线" > "$IDX/TIMELINE.md"
echo "" >> "$IDX/TIMELINE.md"
ls -1t "$MEM/sessions/"*.md 2>/dev/null | head -10 | while read -r f; do
    echo "- $(basename "$f" .md)" >> "$IDX/TIMELINE.md"
done

# 2. INDEX_BY_TAG：统计各分类下文件数
{
    echo "## 分类索引"
    echo ""
    for d in facts references sessions tasks feedback decisions projects misc; do
        n=$(ls "$MEM/$d/" 2>/dev/null | wc -l)
        echo "- $d: $n"
    done
} > "$IDX/INDEX_BY_TAG.md"

echo "✅ 索引已更新: $IDX"
