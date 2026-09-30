#!/usr/bin/env bash
# agent-skeleton 首检 — 缺什么列什么，逐项确认
# 用法：bash check.sh [CLAUDE.md 目标路径，默认 $HOME/.claude/CLAUDE.md]
set -uo pipefail

TARGET="${1:-$HOME/.claude/CLAUDE.md}"
PASS=0; WARN=0; ASK=()
ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }
ask()  { echo "  ❓ $1"; ASK+=("$1"); }

echo "═══ agent-skeleton 首检 ═══"
echo "目标 CLAUDE.md: $TARGET"
echo

echo "── 第一问：agent 叫什么？（名字/寄语/话头注入身份段）"
echo "  现在跑：bash $(dirname "$0")/install.sh <名字> <寄语> [话头]"
echo "  （install 会生成 CLAUDE.md + memory 目录 + bin 工具）"
echo

echo "── 第二问：调度/多 agent 规则用不用？"
if [ -d "$HOME/.claude/rules" ] && grep -ql "多agent\|multi-agent" "$HOME/.claude/rules/"*.md 2>/dev/null; then
    ok "已检测到多 agent 规则"
else
    ask "未启用。需要时在 CLAUDE.md 追加 rules/code-review-pipeline.md 的内容"
fi

echo
echo "── 第三问：消息通道接哪个？（cc-connect/飞书/自建）"
if command -v cc-connect >/dev/null 2>&1; then
    ok "检测到 cc-connect: $(which cc-connect)"
else
    ask "cc-connect 未安装。选其他通道的填到 CLAUDE.md 通信段"
fi

echo
echo "── 路径/服务探测 ──"
[ -d "$HOME/memory" ] && ok "memory 目录: $HOME/memory" || warn "memory 目录不存在（install.sh 会建）"
[ -x "$HOME/bin/recall" ] && ok "recall: $HOME/bin/recall" || warn "recall 未装（install.sh 会装）"
[ -x "$HOME/bin/remember" ] && ok "remember: $HOME/bin/remember" || warn "remember 未装"
# 本机服务探测：按你实际装的服务加（name:port），探测 127.0.0.1
# 例：for svc in "searxng:8080"; do ...
echo "  （本机服务探测：如装了本地搜索/路由服务，在此补 name:port）"
[ -f "$HOME/.claude/settings.json" ] && ok "settings.json 在" || warn "settings.json 不存在"

echo
echo "═══ 结果：✅$PASS  ⚠️$WARN  ❓${#ASK[@]} ═══"
[ ${#ASK[@]} -gt 0 ] && printf '需处理：\n'; [ ${#ASK[@]} -gt 0 ] && for a in "${ASK[@]}"; do echo "  • $a"; done
echo
echo "下一步：装完 install.sh 后重跑本脚本，目标 0 ⚠️ 0 ❓"
