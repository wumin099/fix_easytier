# Fix EasyTier

用于自动修复 **EasyTier** 的 IP 转发与 NAT 规则，保证隧道网络稳定运行。

## 🚀 功能特性

- ✅ 自动启用 IP 转发 (`net.ipv4.ip_forward`)
- ✅ 设置正确的 iptables FORWARD 链策略
- ✅ 为所有 tun/tap 接口添加 NAT MASQUERADE 规则
- ✅ 自动日志轮转（5MB × 5份）
- ✅ Systemd 定时任务管理
- ✅ 完善的错误处理和日志记录
- ✅ 支持 iptables 与 nftables

## 📦 安装

```bash
git clone https://github.com/yourusername/fix_easytier.git
cd fix_easytier
chmod +x install.sh uninstall.sh
sudo ./install.sh
```

## 🧹 卸载

```bash
cd fix_easytier
sudo ./uninstall.sh
```

## 📜 日志管理

- 日志文件：`/var/log/fix_easytier.log`
- 每 5 分钟执行一次并记录日志
- 自动轮转：单个文件最大 5MB，最多保留 5 个备份
- 实时查看日志：`sudo tail -f /var/log/fix_easytier.log`

## 🔍 验证执行结果

```bash
# 检查 ip_forward 是否开启
sysctl net.ipv4.ip_forward

# 检查 FORWARD 策略
iptables -S FORWARD | grep '^-P FORWARD'

# 检查 NAT 规则
iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE

# 检查所有 tun 接口
ip link show | grep tun
```

## ⚙️ 服务管理

```bash
# 查看定时器状态
sudo systemctl status fix-easytier.timer

# 查看最近执行结果
sudo systemctl status fix-easytier.service

# 手动立即执行一次
sudo systemctl start fix-easytier.service

# 启用定时器
sudo systemctl enable --now fix-easytier.timer

# 禁用定时器
sudo systemctl disable --now fix-easytier.timer
```

## 🕒 定时设置

- 启动延迟: 系统启动后 1 分钟开始执行
- 执行间隔: 每 5 分钟执行一次
- 服务名: `fix-easytier.service`
- 定时器: `fix-easytier.timer`
