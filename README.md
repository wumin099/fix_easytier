# Fix EasyTier 自动修复工具

该项目用于自动修复 EasyTier 在 Linux 上可能遇到的 **IP 转发** 和 **NAT 规则** 问题，保证隧道网络正常通信。

## 功能
- 自动启用 `ip_forward`
- 修复 `FORWARD` 链策略为 `ACCEPT`
- 确保存在 `MASQUERADE` 规则 (`tun0` 接口)
- 每 5 分钟自动检查并修复
- 日志轮转（5MB * 5份），日志路径：`/var/log/fix_easytier.log`

## 安装方法
```bash
git clone https://github.com/wumin099/fix_easytier.git
cd fix_easytier
chmod +x install.sh
./install.sh
验证方法
手动执行一次修复：

bash
复制代码
sudo /usr/local/bin/fix_easytier.sh
检查 systemd 定时器状态：

bash
复制代码
systemctl status fix-easytier.timer
systemctl list-timers | grep fix-easytier
查看日志：

bash
复制代码
tail -f /var/log/fix_easytier.log
卸载方法
bash
复制代码
systemctl disable --now fix-easytier.timer
rm -f /usr/local/bin/fix_easytier.sh
rm -f /etc/systemd/system/fix-easytier.service
rm -f /etc/systemd/system/fix-easytier.timer
systemctl daemon-reload
