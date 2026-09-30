#!/usr/bin/env bash
# agent-skeleton 首检 — 缺什么列什么，逐项确认
# 用法：bash check.sh [CLAUDE.md 目标路径，默认 $HOME/.claude/CLAUDE.md]
# 探测三层：通用层（必配）/ 选择层（按需开）/ 本机参数（按实际填）
set -uo pipefail

TARGET="${1:-$HOME/.claude/CLAUDE.md}"
RULES_DIR="${RULES_DIR:-7stars}"
RH="$HOME/$RULES_DIR"
PASS=0; WARN=0; ASK=()
ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }
ask()  { echo "  ❓ $1"; ASK+=("$1"); }

echo "═══ agent-skeleton 首检 ═══"
echo "目标 CLAUDE.md: $TARGET"
echo

echo "── 通用层（必配，install.sh 自动生成）──"
[ -f "$TARGET" ] && ok "CLAUDE.md 在" || { warn "CLAUDE.md 未生成 — 先跑 install.sh"; }
# 身份段是否还留占位符（未填名字/寄语/话头）
rem=$(grep -oE '\{\{[A-Z_]+\}\}' "$TARGET" 2>/dev/null | sort -u)
[ -n "$rem" ] && { ask "CLAUDE.md 残留占位符: $(echo $rem)"; } || ok "身份段已填（无残留占位符）"
[ -d "$HOME/memory" ] && ok "memory 目录: $HOME/memory" || warn "memory 目录不存在（install.sh 会建）"
[ -x "$HOME/bin/recall" ] && ok "recall 已装" || warn "recall 未装（install.sh 会装）"
[ -x "$HOME/bin/remember" ] && ok "remember 已装" || warn "remember 未装"

echo
echo "── $RULES_DIR 规则/知识层（install.sh 生成骨架）──"
for d in decisions references backups scripts; do
    [ -d "$RH/$d" ] && ok "$RH/$d/" || warn "$RH/$d/ 缺（install.sh 会建）"
done
[ -f "$RH/OPS.md" ] && ok "OPS.md（定制说明）" || warn "OPS.md 缺 — 填首检三问的答案和本机参数"
[ -x "$RH/scripts/cron-manage.sh" ] && ok "cron-manage.sh（改 crontab 必备份+登记）" || warn "cron-manage.sh 缺"
# 系统 crontab 登记清单：有登记则报漂移，无则跳过
if [ -f "$HOME/.config/cron-manage.sys" ]; then
    if "$RH/scripts/cron-manage.sh" sync >/dev/null 2>&1; then ok "crontab 登记与系统一致"; else warn "crontab 有漂移 — cron-manage.sh sync 查差异"; fi
else
    echo "  （无 crontab 登记，跳过）"
fi

echo
echo "── 选择层（按需开，默认关）──"
echo "  多 agent 协作（rules/code-review-pipeline.md）："
if [ -d "$HOME/.claude/rules" ] && grep -ql "多agent\|multi-agent\|code-review-pipeline" "$HOME/.claude/rules/"*.md 2>/dev/null; then
    ok "已启用多 agent 规则"
else
    echo "  （关 — 单人单 agent 不用；要开把该文件内容并入 rules/）"
fi

echo
echo "── 第三问：消息通道接哪个？──"
if command -v cc-connect >/dev/null 2>&1; then
    ok "cc-connect: $(which cc-connect)"
else
    ask "cc-connect 未装。选飞书/自建的写进 OPS.md 通道段"
fi

echo
echo "── 本机参数（填 OPS.md，不写死进仓库）──"
[ -f "$HOME/.claude/settings.json" ] && ok "settings.json 在（allow 清单按原则生成，逐项过）" || warn "settings.json 不存在"
echo "  （本机服务 127.0.0.1:port、内网通道、备份远端 → 填 OPS.md，不进公开仓库）"

echo
echo "═══ 结果：✅$PASS  ⚠️$WARN  ❓${#ASK[@]} ═══"
[ ${#ASK[@]} -gt 0 ] && { echo "需处理："; for a in "${ASK[@]}"; do echo "  • $a"; done; }
echo
echo "目标 0 ⚠️ 0 ❓。装完 install.sh 重跑本脚本。"
