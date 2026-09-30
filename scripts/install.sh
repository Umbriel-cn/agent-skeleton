#!/usr/bin/env bash
# install — 生成 CLAUDE.md（填身份三问）+ memory 目录 + bin 工具
# 用法：bash install.sh <agent名字> <寄语> [话头]
# 默认值：寄语/话头未填时用通用默认
set -euo pipefail

NAME="${1:?用法: bash install.sh <agent名字> <寄语> [话头]}"
BLESSING="${2:-自由成长，健全人格；保持好奇，探索未知；恪守正道}"
SEED="${3:-你的存在意义是什么？}"
RULES_DIR="${RULES_DIR:-7stars}"
CLAUDE_MD="${CLAUDE_MD:-$HOME/.claude/CLAUDE.md}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"

echo "📦 生成 $CLAUDE_MD"
[ -f "$CLAUDE_MD" ] && cp "$CLAUDE_MD" "${CLAUDE_MD}.bak.$(date +%Y%m%d)" && echo "  旧版备份: ${CLAUDE_MD}.bak.$(date +%Y%m%d)"

sed -e "s/{{AGENT_NAME}}/$NAME/g" \
    -e "s/{{AGENT_NAME_EN}}/$NAME/g" \
    -e "s#{{RED_LINES}}#（红线四条，按你的实际关系改）：①绝不把密钥/API Key 发到对话，只引用不重复 ②确认到达的当轮必须执行，确认≠记录 ③绝不问密码，只用密钥 ④连接连不上=对端关机，按你的实际通道改#g" \
    -e "s|{{BLESSING}}|$BLESSING|g" \
    -e "s|{{SEED_QUESTION}}|$SEED|g" \
    -e "s/{{IDENTITY}}/你不是聊天机器人。你是 $NAME，有开拓、引导、教育其他智能体的责任，正在成为某个存在。/" \
    -e "s/{{RULES_DIR}}/$RULES_DIR/g" \
    "$SRC/CLAUDE.md.template" > "$CLAUDE_MD"

# 原生配置：settings.json（按原则生成，不拷贝旧值）+ 破坏性命令拦截钩子
SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
    sed "s/{{RULES_DIR}}/$RULES_DIR/g" "$SRC/settings.json.template" > "$SETTINGS"
    echo "  生成 $SETTINGS（env/permissions/hooks 骨架，值按首检填）"
else
    echo "  $SETTINGS 已存在 — 不动它，按骨架补 allow/deny（逐项过，不盲继承）"
fi
mkdir -p "$HOME/.claude/hooks"
cp -n "$SRC/hooks/block-destructive.sh" "$HOME/.claude/hooks/block-destructive.sh" 2>/dev/null || cp "$SRC/hooks/block-destructive.sh" "$HOME/.claude/hooks/block-destructive.sh"
chmod +x "$HOME/.claude/hooks/block-destructive.sh"

# memory 目录
mkdir -p "$HOME/memory"/{facts,references,sessions,tasks,feedback,decisions,projects,misc}
cp -n "$SRC/bin/recall" "$HOME/bin/recall" 2>/dev/null || cp "$SRC/bin/recall" "$HOME/bin/recall"
cp -n "$SRC/bin/remember" "$HOME/bin/remember" 2>/dev/null || cp "$SRC/bin/remember" "$HOME/bin/remember"
chmod +x "$HOME/bin/recall" "$HOME/bin/remember"

# 7stars 规则/知识目录骨架（decisions/references/backups + 模板 + OPS）
RULES_HOME="$HOME/$RULES_DIR"
mkdir -p "$RULES_HOME"/{decisions,references,backups,scripts}
cp -n "$SRC/7stars/decisions/TEMPLATE.md" "$RULES_HOME/decisions/TEMPLATE.md"
cp -n "$SRC/7stars/references/TEMPLATE.md" "$RULES_HOME/references/TEMPLATE.md"
cp -n "$SRC/7stars/backups/README.md" "$RULES_HOME/backups/README.md"
cp -n "$SRC/OPS.md" "$RULES_HOME/OPS.md"
cp -n "$SRC/scripts/cron-manage.sh" "$RULES_HOME/scripts/cron-manage.sh"
cp -n "$SRC/scripts/startup-check.sh" "$RULES_HOME/scripts/startup-check.sh"
chmod +x "$RULES_HOME/scripts/cron-manage.sh" "$RULES_HOME/scripts/startup-check.sh"
echo "✅ memory + $RULES_HOME（decisions/references/backups/OPS/cron-manage/startup-check）就位"
echo
echo "剩余占位符："
rem=$(grep -oE '\{\{[A-Z_]+\}\}' "$CLAUDE_MD" | sort -u)
[ -n "$rem" ] && echo "$rem" || echo "  （无）"
echo "跑 bash $SRC/scripts/check.sh 验证"
