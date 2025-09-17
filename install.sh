#!/bin/bash
set -e

# Fix EasyTier 安装脚本
echo "正在安装 Fix EasyTier ..."

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo "错误：此脚本必须以root权限运行" >&2
    exit 1
fi

# 复制主脚本
echo "复制主脚本到 /usr/local/bin/"
cp fix_easytier.sh /usr/local/bin/fix_easytier.sh
chmod +x /usr/local/bin/fix_easytier.sh

# 复制systemd服务文件
echo "配置systemd服务"
cp fix-easytier.service /etc/systemd/system/fix-easytier.service
cp fix-easytier.timer /etc/systemd/system/fix-easytier.timer

# 重新加载systemd配置
systemctl daemon-reload

# 启用并启动定时器
echo "启用定时服务"
systemctl enable --now fix-easytier.timer

# 立即运行一次服务进行初始化
echo "执行初始检查"
systemctl start fix-easytier.service

echo "安装完成 ✅"
echo "日志文件: /var/log/fix_easytier.log"
echo "定时器状态: systemctl status fix-easytier.timer"
echo "查看日志: tail -f /var/log/fix_easytier.log"
