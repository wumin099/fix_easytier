#!/bin/bash
set -e

echo "正在安装 Fix EasyTier ..."

if [ "$EUID" -ne 0 ]; then
    echo "错误：此脚本必须以 root 权限运行" >&2
    exit 1
fi

echo "设置系统时区为 Asia/Shanghai"
timedatectl set-timezone Asia/Shanghai || true

if ! command -v iptables >/dev/null 2>&1 && ! command -v nft >/dev/null 2>&1; then
    echo "错误：未检测到 iptables 或 nft，请先安装其中之一"
    exit 1
fi

echo "复制主脚本到 /usr/local/bin/"
cp fix_easytier.sh /usr/local/bin/fix_easytier.sh
chmod +x /usr/local/bin/fix_easytier.sh

echo "配置 systemd 服务"
cp fix-easytier.service /etc/systemd/system/fix-easytier.service
cp fix-easytier.timer /etc/systemd/system/fix-easytier.timer

systemctl daemon-reload
echo "启用定时服务"
systemctl enable --now fix-easytier.timer

echo "执行初始检查"
systemctl start fix-easytier.service

echo "安装完成 ✅"
echo "日志文件: /var/log/fix_easytier.log"
echo "定时器状态: systemctl status fix-easytier.timer"
echo "查看日志: tail -f /var/log/fix_easytier.log"
