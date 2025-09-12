# Fix EasyTier

用于修复 EasyTier 转发与 NAT 规则的自动化脚本。

## 功能
- 自动启用 `ip_forward`
- 确保 `FORWARD` 链为 `ACCEPT`
- 确保 NAT `MASQUERADE` 规则存在
- 支持日志轮转（超过 5MB 自动切分）

## 安装

```bash
git clone https://github.com/wumin099/fix_easytier.git
cd fix_easytier
bash install.sh
```

## 验证脚本执行结果

查看 systemd 状态：
```bash
systemctl status fix-easytier.service
```

手动执行一次修复：
```bash
bash /usr/local/bin/fix_easytier.sh
```

查看日志：
```bash
cat /var/log/fix_easytier.log
```

## 卸载

```bash
systemctl disable --now fix-easytier.timer
rm -f /etc/systemd/system/fix-easytier.service
rm -f /etc/systemd/system/fix-easytier.timer
rm -f /usr/local/bin/fix_easytier.sh
systemctl daemon-reload
```

## 定时任务
脚本默认每 **5 分钟** 执行一次，确保网络规则持续有效。
