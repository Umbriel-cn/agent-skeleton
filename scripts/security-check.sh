#!/usr/bin/env bash
# security-check — 通用安全巡检：只报警不自动改（自动修复逻辑各环境不同，留给使用者加）
# 检查项（通用，不依赖本机专属配置）：
#   1. 磁盘占用 > 90% 告警
#   2. 监听端口异常（非常见端口有监听）
#   3. crontab 是否漂移（有登记清单时，调 cron-manage.sh sync）
#   4. 日志目录无写权限
# 用法：bash security-check.sh [--quiet]
# cron: 15 0 * * * bash $HOME/7stars/scripts/security-check.sh --quiet
set -uo pipefail
QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1
RULES_DIR="${RULES_DIR:-7stars}"
FAILS=()

check() { # check <条件> <说明>
    if eval "$1" 2>/dev/null; then :; else FAILS+=("$2"); fi
}

# 1. 磁盘
used=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')
[ -n "$used" ] && [ "$used" -gt 90 ] && FAILS+=("磁盘占用 ${used}% > 90%")

# 2. 监听端口（常见放行，其余提醒，不阻断）
# ponytail: 不写死 IP/服务名，只提示"有非预期监听"，细节由使用者判
nonstd=$(ss -tln 2>/dev/null | awk 'NR>1 {split($4,a,":"); print a[length(a)]}' | sort -un | grep -vE '^(22|80|443|8080|8081|3000|5173|8787|20128)$' | head -10 || true)
[ -n "$nonstd" ] && FAILS+=("非标准端口监听: $nonstd（逐一确认是否预期）")

# 3. crontab 漂移
if [ -f "$HOME/.config/cron-manage.sys" ] && [ -x "$HOME/$RULES_DIR/scripts/cron-manage.sh" ]; then
    "$HOME/$RULES_DIR/scripts/cron-manage.sh" sync >/dev/null 2>&1 || FAILS+=("crontab 与登记清单漂移（cron-manage.sh sync 查差异）")
fi

# 4. 日志目录可写
[ -d "$HOME/$RULES_DIR/backups" ] && [ -w "$HOME/$RULES_DIR/backups" ] || FAILS+=("$RULES_DIR/backups 不存在或不可写")

# 输出
if [ ${#FAILS[@]} -eq 0 ]; then
    [ "$QUIET" -eq 0 ] && echo "✅ 安全巡检通过（磁盘 ${used:-?}%、监听正常、cron 无漂移、日志可写）"
    exit 0
else
    echo "❌ 安全巡检异常（${#FAILS[@]} 项）："
    for f in "${FAILS[@]}"; do echo "  • $f"; done
    exit 1
fi
