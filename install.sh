#!/bin/bash
set -e

echo "[*] 设置系统时区为 Asia/Shanghai"
timedatectl set-timezone Asia/Shanghai || true

echo "[*] 安装 fix_easytier 脚本和 systemd 单元..."
install -m 755 fix_easytier.sh /usr/local/bin/fix_easytier.sh
install -m 644 fix-easytier.service /etc/systemd/system/fix-easytier.service
install -m 644 fix-easytier.timer /etc/systemd/system/fix-easytier.timer

echo "[*] 重新加载 systemd..."
systemctl daemon-reload

echo "[*] 启用并启动 fix-easytier 服务和定时器..."
systemctl enable --now fix-easytier.timer

echo "[*] 安装完成，日志文件位于 /var/log/fix_easytier.log"
