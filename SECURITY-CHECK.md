# 发布前硬校验口径

公开仓库 grep 必须 0 命中（人名/账号/内网/会话 key）。**口径**：

**算泄漏（必须清 0）：** 人名（开明/承影/七星名）、账号（umbriel/Lawscn/oc_* 会话 key）、内网地址（127.0.0.1:20128、/home/umbriel）、本机专属服务名（9router/obscura 等非公开）、私有路径。

**不算泄漏（可提）：** 公开开源工具名（cc-connect 是 GitHub 公开项目）。它是「第三问消息通道」的选项之一，提它帮新用户装。

发布前跑（排除本校验文档自身，它字面列了泄漏词）：
```bash
grep -rE "开明|承影|七星|umbriel|Umbriel|/home/umbriel|to-law|Lawscn|127\.0\.0\.1:20128|oc_[0-9a-z]{8}" \
  --exclude-dir=.git --exclude=SECURITY-CHECK.md .
```
exit=1（0 命中）= 通过。
