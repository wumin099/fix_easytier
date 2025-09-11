#!/bin/bash
set -e

echo "[*] 安装 fix_easytier 脚本和 systemd 单元..."

# 复制脚本
cp fix_easytier.sh /usr/local/bin/fix_easytier.sh
chmod +x /usr/local/bin/fix_easytier.sh

# 复制 systemd 单元
cp fix-easytier.service /etc/systemd/system/fix-easytier.service
cp fix-easytier.timer /etc/systemd/system/fix-easytier.timer

echo "[*] 重新加载 systemd..."
systemctl daemon-reload

echo "[*] 启用并启动 fix-easytier 服务和定时器..."
systemctl enable --now fix-easytier.service
systemctl enable --now fix-easytier.timer

echo "[*] 安装完成，日志文件位于 /var/log/fix_easytier.log"
