# fix_easytier

自动修复 EasyTier 节点转发和 NAT 规则的脚本。

## 功能
- 确保 `ip_forward=1`
- 确保 `FORWARD` 链默认策略为 `ACCEPT`
- 确保存在 `NAT MASQUERADE` 规则
- 日志轮转（单文件最大 5MB，最多保留 5 份）

## 安装方法
```bash
git clone https://github.com/wumin099/fix_easytier.git
cd fix_easytier
sudo bash install.sh
```

## 验证方法
查看服务和定时器是否运行：
```bash
systemctl status fix-easytier.service
systemctl status fix-easytier.timer
```

检查日志：
```bash
tail -f /var/log/fix_easytier.log
```

## 卸载方法
```bash
sudo systemctl disable --now fix-easytier.timer
sudo rm -f /usr/local/bin/fix_easytier.sh /etc/systemd/system/fix-easytier.* /var/log/fix_easytier.log*
sudo systemctl daemon-reload
```

## License
MIT
