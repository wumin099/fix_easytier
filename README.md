# fix-easytier

自动修复 EasyTier IP 转发和 NAT MASQUERADE 规则。  
支持 systemd 服务和定时器，每 5 分钟自动运行一次，并记录日志到 `/var/log/fix_easytier.log`。

## 安装方法

1. 下载并解压仓库：
```bash
wget https://github.com/wumin099/fix_easytier/archive/refs/heads/main.zip
unzip main.zip
cd fix_easytier-main
bash install.sh
```

2. 执行安装：
```bash
bash install.sh
```

## 日志查看

```bash
tail -f /var/log/fix_easytier.log
```

## 服务管理

```bash
systemctl status fix-easytier.service
systemctl status fix-easytier.timer
systemctl stop|start fix-easytier.service
systemctl stop|start fix-easytier.timer
```
