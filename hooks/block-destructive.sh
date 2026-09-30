#!/usr/bin/env bash
# PreToolUse hook（Bash）— 拦截不可恢复的破坏性命令
# 机制：读 stdin 的 JSON（{"tool_input":{"command":"..."}}），命中拦截词就 exit 2 阻断
# 装法：settings.json 里 hooks.PreToolUse[matcher=Bash].hooks[].command 指到这里
# 依赖：只用 grep -E（无前瞻，GNU/ugrep 通吃）+ python3 解析
set -u
input=$(cat 2>/dev/null)
cmd=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
[ -z "$cmd" ] && exit 0

block() { echo "🚫 [block-destructive] 拦截: $1" >&2; exit 2; }

# rm -rf 指向 / 或 ~ 下敏感目录（放行 /tmp、/var）
if echo "$cmd" | grep -qE 'rm[[:space:]]+-rf[[:space:]]+/.*' && \
   ! echo "$cmd" | grep -qE 'rm[[:space:]]+-rf[[:space:]]+/tmp|/var/'; then
    block "rm -rf /系统目录"
fi
echo "$cmd" | grep -qE 'rm[[:space:]]+-rf[[:space:]]+~/?(memory|7stars)' && block "删记忆库/规则库"
# git 破坏性
echo "$cmd" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard' && block "git reset --hard"
echo "$cmd" | grep -qE 'git[[:space:]]+clean[[:space:]]+-[fx]+' && block "git clean -f"
if echo "$cmd" | grep -qE 'git[[:space:]]+push[[:space:]]+(-f|--force)([^-]|$)' && \
   ! echo "$cmd" | grep -qE 'git[[:space:]]+push[[:space:]]+--force-with-lease'; then
    block "git push --force"
fi
# 低级破坏
echo "$cmd" | grep -qE '\bmkfs' && block "mkfs 格式化"
echo "$cmd" | grep -qE '\bdd[[:space:]].*of=/dev/' && block "dd 写裸设备"
echo "$cmd" | grep -qE '\bshred\b' && block "shred 粉碎"
echo "$cmd" | grep -qE '>[[:space:]]*/dev/sd' && block "重定向裸盘"
echo "$cmd" | grep -qE 'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/' && block "chmod -R 777 /"

exit 0
