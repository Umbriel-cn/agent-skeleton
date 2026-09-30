# 默认建议定时任务

用 `bash $RULES_DIR/scripts/cron-manage.sh add-sys <desc> <cron_expr> <regex> <cmd>` 逐个装。
cron 本体是系统自带，这里只列「值得排的任务」，按依赖分三档。

## 零依赖（任何装了骨架的机器都能跑）
```
# 记忆归档：每月 1 号把旧 session 归档
cron-manage.sh add-sys "记忆归档" "0 3 1 * *" "记忆归档" \
  "bash $HOME/bin/memory-cleanup.sh >> $HOME/7stars/backups/cron-memory-cleanup.log 2>&1"
```
（memory-cleanup.sh 随 bin/ 一起装；没有的话先装 bin）

## 需要本机/账号配置（按你的环境选）
- 安全巡检：要写自己的检测逻辑，`security-check.sh` 是本机主脑私有版，不随骨架发
- 每日备份：要定备份目标（本地/云），`daily-backup.sh` 本机主脑私有
- 灵魂包备份+可信校验：需要 cfr2（或你的云）+ age 密钥，没有就不装
- cc-connect 会话提醒：第三问选了 cc-connect 才有意义，用 cc-connect 自己的 cron，不走系统 crontab

## 私有运营（本机主脑专属，勿抄）
知乎数据/问题巡检、CDP 流量抓取、DeepSeek 余额、dida 续期——绑定具体平台账号，不通用。
