# fix_easytier

自动修复 EasyTier 节点的 IP 转发和 NAT 规则，确保网络正常互通。

## 安装

```bash
git clone https://github.com/wumin099/fix_easytier.git
cd fix_easytier
bash install.sh
```

## 日志查看

脚本每 **5 分钟**由 systemd 定时器自动执行一次，执行日志会追加到：

```
/var/log/fix_easytier.log
```

可以用以下命令查看最新日志：

```bash
tail -f /var/log/fix_easytier.log
```

日志会自动轮转，最多保留最近 5 个日志文件，每个日志最大 5MB。

## 卸载脚本

```bash
systemctl stop fix-easytier.timer
systemctl stop fix-easytier.service
systemctl disable fix-easytier.timer
systemctl disable fix-easytier.service
rm -f /usr/local/bin/fix_easytier.sh
rm -f /etc/systemd/system/fix-easytier.service
rm -f /etc/systemd/system/fix-easytier.timer
rm -f /var/log/fix_easytier.log
```
