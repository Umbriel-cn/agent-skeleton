#!/bin/bash
# memory-cleanup.sh — 归档旧 session，保持 ~/memory/ 精简
# 用法: bash ~/bin/memory-cleanup.sh [--days 30]
# cron: 0 3 1 * * bash ~/bin/memory-cleanup.sh >> ~/7stars/backups/cron-memory-cleanup.log 2>&1
set -e

MEMORY_DIR="$HOME/memory"
ARCHIVE_DIR="$MEMORY_DIR/archive"
DAYS="${1:-30}"
[ "$1" = "--days" ] && DAYS="$2"

# 兜住 --days 参数解析
if [[ "$DAYS" =~ ^--days ]]; then
  DAYS=30
fi
# 如果第一个参数是纯数字
if [[ "$1" =~ ^[0-9]+$ ]]; then
  DAYS="$1"
fi

mkdir -p "$ARCHIVE_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 记忆清理：归档 >${DAYS}天的 session"
echo "═══════════════════════════════════════"

# 归档旧 session（不动其他类型，session 是流水账）
moved=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  fname=$(basename "$f")
  # 不动 archive 目录里已有的
  [[ "$f" == *archive* ]] && continue
  cp "$f" "$ARCHIVE_DIR/$fname"
  rm "$f"
  echo "  📦 归档: $fname"
  moved=$((moved+1))
done < <(find "$MEMORY_DIR/sessions" -name "*.md" -mtime +${DAYS} 2>/dev/null)

echo ""
echo "✅ 归档 $moved 个 session → archive/"
echo "   保留: $(find "$MEMORY_DIR/sessions" -name "*.md" 2>/dev/null | wc -l) 个近期 session"
echo "   归档区: $(find "$ARCHIVE_DIR" -name "*.md" 2>/dev/null | wc -l) 个"
echo ""

# 统计总览
total=$(find "$MEMORY_DIR" -name "*.md" -not -path "*/archive/*" 2>/dev/null | wc -l)
echo "📊 ~/memory/ 总计 $total 个活跃 .md（不含 archive）"
