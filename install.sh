#!/bin/bash
set -e

SCRIPT_NAME="fix_easytier.sh"
SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"
SERVICE_PATH="/etc/systemd/system/fix-easytier.service"
TIMER_PATH="/etc/systemd/system/fix-easytier.timer"
LOG_FILE="/var/log/fix_easytier.log"

echo "[*] 设置时区为 Asia/Kuala_Lumpur..."
timedatectl set-timezone Asia/Kuala_Lumpur || echo "[警告] 无法设置时区，请检查系统 timedatectl 支持"

echo "[*] 拷贝脚本到 /usr/local/bin..."
install -m 755 "$SCRIPT_NAME" "$SCRIPT_PATH"

echo "[*] 拷贝 systemd 单元文件..."
install -m 644 fix-easytier.service "$SERVICE_PATH"
install -m 644 fix-easytier.timer "$TIMER_PATH"

echo "[*] 重新加载 systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "[*] 启用并启动定时任务..."
systemctl enable --now fix-easytier.timer

echo "[*] 确保日志文件存在..."
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

echo "[*] 安装完成！"
echo "    - 服务文件: $SERVICE_PATH"
echo "    - 定时器文件: $TIMER_PATH"
echo "    - 脚本文件: $SCRIPT_PATH"
echo "    - 日志文件: $LOG_FILE"
echo ""
echo "使用方法:"
echo "  systemctl status fix-easytier.timer   # 查看定时任务状态"
echo "  systemctl status fix-easytier.service # 查看最近一次运行"
echo "  tail -f $LOG_FILE                     # 实时查看日志"
