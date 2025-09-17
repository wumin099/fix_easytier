#!/bin/bash

# Fix EasyTier - 自动修复IP转发与NAT规则
# 版本: 2.0

LOG_FILE="/var/log/fix_easytier.log"
MAX_LOG_SIZE=$((5*1024*1024))  # 5MB
MAX_LOG_BACKUPS=5

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo "错误：此脚本必须以root权限运行" >&2
    exit 1
fi

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 初始重定向到日志文件
exec >> "$LOG_FILE" 2>&1

# 日志轮转函数
rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE" 2>/dev/null || echo 0) -ge $MAX_LOG_SIZE ]; then
        echo "$(date '+%F %T') 日志文件达到 ${MAX_LOG_SIZE} 字节，执行轮转"
        
        # 删除最旧的日志文件
        [ -f "$LOG_FILE.$MAX_LOG_BACKUPS" ] && rm -f "$LOG_FILE.$MAX_LOG_BACKUPS"
        
        # 轮转日志文件
        for i in $(seq $((MAX_LOG_BACKUPS-1)) -1 1); do
            [ -f "$LOG_FILE.$i" ] && mv "$LOG_FILE.$i" "$LOG_FILE.$((i+1))"
        done
        
        # 移动当前日志文件
        mv "$LOG_FILE" "$LOG_FILE.1"
        
        # 重新打开日志文件
        exec >> "$LOG_FILE" 2>&1
        echo "$(date '+%F %T') 日志轮转完成"
    fi
}

# 执行日志轮转
rotate_logs

echo "==== $(date '+%F %T') EasyTier 自动修复开始 ===="

# 1. 确保 ip_forward=1
if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null)" -ne 1 ]; then
    echo "[修复] 启用 ip_forward"
    if echo 1 > /proc/sys/net/ipv4/ip_forward; then
        echo "[成功] ip_forward 已启用"
    else
        echo "[错误] 无法启用 ip_forward"
        exit 1
    fi
else
    echo "[OK] ip_forward 已启用"
fi

# 2. 确保 FORWARD 链默认 ACCEPT
forward_policy=$(iptables -S FORWARD 2>/dev/null | grep '^-P FORWARD' | awk '{print $3}')
if [ "$forward_policy" != "ACCEPT" ]; then
    echo "[修复] 设置 FORWARD 链默认 ACCEPT"
    if iptables -P FORWARD ACCEPT; then
        echo "[成功] FORWARD 链策略已设置"
    else
        echo "[错误] 无法设置 FORWARD 链策略"
        exit 1
    fi
else
    echo "[OK] FORWARD 链策略正常"
fi

# 3. 确保 NAT MASQUERADE 规则存在（检查所有tun接口）
tun_interfaces=$(ip link show 2>/dev/null | grep -E 'tun[0-9]+|tap[0-9]+' | awk -F: '{print $2}' | tr -d ' ')

if [ -z "$tun_interfaces" ]; then
    echo "[信息] 未找到tun/tap虚拟接口"
else
    for tun_if in $tun_interfaces; do
        if ! iptables -t nat -C POSTROUTING -o "$tun_if" -j MASQUERADE 2>/dev/null; then
            echo "[修复] 为接口 $tun_if 添加 NAT MASQUERADE 规则"
            if iptables -t nat -A POSTROUTING -o "$tun_if" -j MASQUERADE; then
                echo "[成功] 接口 $tun_if 的 NAT 规则已添加"
            else
                echo "[警告] 无法为接口 $tun_if 添加 NAT 规则（可能接口未启动）"
            fi
        else
            echo "[OK] 接口 $tun_if 的 NAT MASQUERADE 规则已存在"
        fi
    done
fi

echo "==== $(date '+%F %T') EasyTier 自动修复完成 ===="
echo ""
