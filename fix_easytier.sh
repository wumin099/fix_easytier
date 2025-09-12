#!/bin/bash
LOG_FILE="/var/log/fix_easytier.log"

# 日志轮转（>5MB 就重命名为 .1）
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 5242880 ]; then
    mv "$LOG_FILE" "$LOG_FILE.1"
    echo "[$(date '+%F %T')] 日志过大，已轮转" > "$LOG_FILE"
fi

exec >> "$LOG_FILE" 2>&1

echo "==== $(date '+%F %T') EasyTier 自动修复开始 ===="

# 1. 确保 ip_forward=1
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -ne 1 ]; then
    echo "[修复] 启用 ip_forward"
    echo 1 > /proc/sys/net/ipv4/ip_forward
else
    echo "[OK] ip_forward 已启用"
fi

# 2. 确保 FORWARD 链默认 ACCEPT
forward_policy=$(iptables -S FORWARD | grep '^-P FORWARD' | awk '{print $3}')
if [ "$forward_policy" != "ACCEPT" ]; then
    echo "[修复] 设置 FORWARD 链默认 ACCEPT"
    iptables -P FORWARD ACCEPT
else
    echo "[OK] FORWARD 链策略正常"
fi

# 3. 确保 NAT MASQUERADE 规则存在
if ! iptables -t nat -C POSTROUTING -o tun0 -j MASQUERADE 2>/dev/null; then
    echo "[修复] 添加 NAT MASQUERADE 规则"
    iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
else
    echo "[OK] NAT MASQUERADE 规则已存在"
fi

echo "==== $(date '+%F %T') EasyTier 自动修复完成 ===="
echo ""
