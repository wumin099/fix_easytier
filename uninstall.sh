#!/bin/bash
set -e

echo "正在卸载 Fix EasyTier ..."

if [ "$EUID" -ne 0 ]; then
    echo "错误：此脚本必须以 root 权限运行" >&2
    exit 1
fi

echo "停止服务..."
systemctl disable --now fix-easytier.timer 2>/dev/null || true
systemctl disable --now fix-easytier.service 2>/dev/null || true

echo "删除文件..."
rm -f /usr/local/bin/fix_easytier.sh
rm -f /etc/systemd/system/fix-easytier.service
rm -f /etc/systemd/system/fix-easytier.timer

systemctl daemon-reload

echo "卸载完成 ✅"
echo "注意：原有的防火墙规则不会被恢复"
