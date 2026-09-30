#!/usr/bin/env bash
# bootstrap — R0 会话启动一键加载：记忆检索 + 读手册 + 任务总览
# 用法：每次新会话跑 bash $HOME/7stars/scripts/bootstrap.sh
# 只读，不写任何东西；输出给 agent 看
set -uo pipefail
MEM="${MEM_DIR:-$HOME/memory}"
RULES_DIR="${RULES_DIR:-7stars}"
KW="${1:-}"

# 1. 记忆检索（有关键词查关键词，没有就加载任务总览里的"进行中"）
if [ -n "$KW" ]; then
    echo "🔍 检索: $KW"
    MEM_DIR="$MEM" bash "$HOME/bin/recall" "$KW" 5 2>/dev/null || echo "  （recall 未装或无命中）"
else
    echo "═══ 任务总览 ═══"
    cat "$MEM/tasks/任务总览.md" 2>/dev/null || cat "$MEM/MEMORY.md" 2>/dev/null || echo "（memory 目录空，先建库）"
fi

# 2. 读手册（如存在）
if [ -f "$HOME/$RULES_DIR/OPS.md" ]; then
    echo "═══ OPS 定制说明 ═══"
    head -40 "$HOME/$RULES_DIR/OPS.md"
fi
