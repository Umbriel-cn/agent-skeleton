# agent-skeleton

给 Claude Code 系 agent 装的通用骨架：身份模板 + 操作规则 + 纯 Markdown 记忆机制 + 首检脚本。
一条命令起步，三问注入你的人格层。

## 目录
```
CLAUDE.md.template   身份/规则占位模板
rules/               选择层规则（多 agent 协作流水线，默认不用）
bin/                 recall / remember（纯 Markdown 记忆检索与写入）
scripts/install.sh   生成 CLAUDE.md + memory 目录 + bin 工具
scripts/check.sh     首检：缺什么列什么
```

## 安装
```bash
git clone <repo> /tmp/agent-skeleton && cd /tmp/agent-skeleton
bash scripts/install.sh <agent名字> <寄语> [话头]
bash scripts/check.sh
```

## 定时任务
cron 本体系统自带，不装额外东西。`crons/README.md` 列默认建议任务（零依赖的给，私有的不抄），用 `cron-manage.sh` 装。

## 首检三问
1. agent 叫什么 → 注入身份段
2. 调度/多 agent 规则用不用 → 需要时把 `rules/code-review-pipeline.md` 内容并入
3. 消息通道接哪个（cc-connect / 飞书 / 自建，按需选）

## 设计原则
- 原则存骨架，值存首检：allow 清单按原则生成 + 逐项过，不盲继承旧快照
- 路径一律 `$HOME`，不写死用户目录
- 记忆机制进骨架（bin/recall、bin/remember），记忆内容不进

## 安全
公开仓库，零私有内容：发布前跑发布方提供的 grep 硬校验（人名/账号/内网地址/会话 key 全 0 命中）。
skeleton-sync dry test 22:02
