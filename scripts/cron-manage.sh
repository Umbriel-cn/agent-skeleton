#!/usr/bin/env bash
# cron-manage — 系统 crontab 管理：改前必备份、改后回读验证、登记清单（防手工漂移）
# 用法：
#   cron-manage.sh add-sys <desc> <cron_expr> <regex> <cmd>   # 追加系统 crontab 行 + 登记
#   cron-manage.sh del-sys <desc>                              # 按 regex 精确删（命中>1 拒绝）
#   cron-manage.sh list                                        # 显示已登记清单
#   cron-manage.sh sync                                        # 只读对比，退出码 0=一致 1=漂移
set -uo pipefail
REG="$HOME/.config/cron-manage.sys"
BAK="$HOME/7stars/backups"

mkd() { mkdir -p "$BAK" "$HOME/.config"; }

cmd_add() {
    desc="$1"; expr="$2"; regex="$3"; cmd="$4"
    mkd
    bak="$BAK/crontab-bak-$(date +%Y%m%d-%H%M%S)"
    crontab -l > "$bak" 2>/dev/null || true
    echo "备份: $bak"
    { crontab -l 2>/dev/null; echo "# $desc"; echo "$expr $cmd"; } | crontab -
    # 回读验证
    crontab -l | grep -q "$regex" && echo "✅ 已追加「$desc」(回读通过)" || { echo "❌ 回读失败"; exit 1; }
    # 登记
    [ -f "$REG" ] || { echo "# 系统 crontab 登记清单" > "$REG"; }
    echo -e "$desc\t$expr\t$regex" >> "$REG"
    echo "✅ 已登记「$desc」"
}

cmd_del() {
    desc="$1"
    [ -f "$REG" ] || { echo "无登记清单"; exit 1; }
    regex=$(grep -P "^\Q$desc\E\t" "$REG" | cut -f3 | head -1)
    [ -n "$regex" ] || { echo "❌ 未登记「$desc」"; exit 1; }
    n=$(crontab -l 2>/dev/null | grep -c "$regex")
    [ "$n" -gt 1 ] && { echo "❌ 命中 $n 条，拒绝（regex 不唯一）"; exit 1; }
    crontab -l 2>/dev/null | grep -v "$regex" | crontab -
    grep -v -P "^\Q$desc\E\t" "$REG" > "$REG.tmp" && mv "$REG.tmp" "$REG"
    echo "✅ 已删「$desc」"
}

cmd_list() { [ -f "$REG" ] && cat "$REG" || echo "（空）"; }

cmd_sync() {
    [ -f "$REG" ] || { echo "清单与 crontab 一致（无登记）"; exit 0; }
    drift=0
    while IFS=$'\t' read -r d e r; do
        case "$d" in \#*|'') continue ;; esac
        crontab -l 2>/dev/null | grep -q "$r" || { echo "  ⚠️ 缺失: $d"; drift=1; }
    done < "$REG"
    [ "$drift" -eq 0 ] && { echo "✅ 一致"; exit 0; } || { echo "❌ 漂移"; exit 1; }
}

case "${1:-}" in
    add-sys) cmd_add "${2:?}" "${3:?}" "${4:?}" "${5:?}" ;;
    del-sys) cmd_del "${2:?}" ;;
    list)    cmd_list ;;
    sync)    cmd_sync ;;
    *) echo "用法: cron-manage.sh {add-sys|del-sys|list|sync} ..."; exit 1 ;;
esac
