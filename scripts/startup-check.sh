#!/usr/bin/env bash
# startup-check — 一次性自检（跑过就忘）：环境基础 + 记忆库 + 通道
# 全部通过 → 一句话"自检通过"；有异常 → 只报异常项
# 本机专属检查（服务端口/隧道/密钥）加在 [可定制] 段
set -uo pipefail
RULES_DIR="${RULES_DIR:-7stars}"
FAILS=()

# python3 / node（记忆脚本和 cc-connect 依赖）
command -v python3 >/dev/null 2>&1 || FAILS+=("python3 未装")
command -v node >/dev/null 2>&1 || FAILS+=("node 未装")

# 记忆库可检索
if [ -d "$HOME/memory" ] && [ -d "$HOME/memory/facts" ]; then
    mkdir -p "$HOME/memory/misc" && touch "$HOME/memory/misc/.selftest" && rm -f "$HOME/memory/misc/.selftest" \
        || FAILS+=("memory 目录不可写")
else
    FAILS+=("memory 目录缺失（先跑 install.sh）")
fi

# 7stars 骨架在
[ -d "$HOME/$RULES_DIR" ] || FAILS+=("$RULES_DIR 缺失（install.sh 会建）")

# 消息通道
command -v cc-connect >/dev/null 2>&1 || FAILS+=("cc-connect 未装（第三问选的其他通道可忽略）")

# [可定制] 本机服务/隧道/密钥检查，按实际加，例：
# timeout 1 bash -c "exec 3<>/dev/tcp/127.0.0.1/8080" 2>/dev/null || FAILS+=("搜索服务 8080 不通")

if [ ${#FAILS[@]} -eq 0 ]; then
    echo "自检通过"
else
    echo "自检异常（${#FAILS[@]} 项）："
    for f in "${FAILS[@]}"; do echo "  ❌ $f"; done
    exit 1
fi
