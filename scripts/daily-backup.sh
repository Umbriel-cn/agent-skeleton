#!/usr/bin/env bash
# daily-backup — 通用每日备份：把「会丢的东西」打成一个 tar 放到 backups 目录
# 默认备份 $HOME/.claude（身份层）+ $HOME/memory（记忆库）
# 用法：bash daily-backup.sh [备份目标目录，默认 $HOME/7stars/backups]
# cron: 0 0 * * * bash $HOME/7stars/scripts/daily-backup.sh
# 保留最近 BACKUP_KEEP 份（默认 7），更早的自动删
set -uo pipefail
TARGET_DIR="${1:-$HOME/7stars/backups}"
KEEP="${BACKUP_KEEP:-7}"
RULES_DIR="${RULES_DIR:-7stars}"

STAMP="$(date +%Y%m%d)"
OUT="$TARGET_DIR/daily-backup-$STAMP.tar.gz"
mkdir -p "$TARGET_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 每日备份 → $OUT"
# 收集存在的源
SOURCES=()
[ -d "$HOME/.claude" ] && SOURCES+=("$HOME/.claude")
[ -d "$HOME/memory" ] && SOURCES+=("$HOME/memory")
[ -d "$HOME/$RULES_DIR" ] && SOURCES+=("$HOME/$RULES_DIR")
[ ${#SOURCES[@]} -eq 0 ] && { echo "❌ 没有可备份目录"; exit 1; }

tar czf "$OUT" "${SOURCES[@]}" 2>/dev/null
sz=$(du -h "$OUT" | cut -f1)
echo "  完成: $sz ($OUT)"

# 保留最近 KEEP 份
ls -1t "$TARGET_DIR"/daily-backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP+1)) | while read -r old; do
    rm -f "$old" && echo "  清理旧备份: $(basename "$old")"
done
echo "✅ 每日备份完成"
