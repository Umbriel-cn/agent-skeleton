# 备份目录

改关键文件（settings.json / 脚本 / 规则）前，先备份到这里：

```bash
mkdir -p $HOME/7stars/backups/<改的东西>-$(date +%Y%m%d)
cp <原文件> $HOME/7stars/backups/<改的东西>-$(date +%Y%m%d)/
```

回滚点 = 这里对应的备份。不进公开仓库的敏感内容（记忆库全量、密钥）走单独的备份通道，不堆这个目录。
