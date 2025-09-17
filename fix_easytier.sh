#!/bin/bash

# Fix EasyTier - 自动修复IP转发与NAT规则
# 版本: 2.1 (优化版，支持 iptables/nftables)

LOG_FILE="/var/log/fix_easytier.log"
MAX_LOG_SIZE=$((5*1024*1024))  # 5MB
MAX_LOG_BACKUPS=5

if [ "$EUID" -ne 0 ]; then
    echo "错误：此脚本必须以 root 权限运行" >&2
    exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"
exec >> "$LOG_FILE" 2>&1

rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE" 2>/dev/null || echo 0) -ge $MAX_LOG_SIZE ]; then
        echo "$(date '+%F %T') 日志文件达到 ${MAX_LOG_SIZE} 字节，执行轮转"
        [ -f "$LOG_FILE.$MAX_LOG_BACKUPS" ] && rm -f "$LOG_FILE.$MAX_LOG_BACKUPS"
        for i in $(seq $((MAX_LOG_BACKUPS-1)) -1 1); do
            [ -f "$LOG_FILE.$i" ] && mv "$LOG_FILE.$i" "$LOG_FILE.$((i+1))"
        done
        mv "$LOG_FILE" "$LOG_FILE.1"
        exec >> "$LOG_FILE" 2>&1
        echo "$(date '+%F %T') 日志轮转完成"
    fi
}

rotate_logs
echo "==== $(date '+%F %T') EasyTier 自动修复开始 ===="

if command -v iptables >/dev/null 2>&1; then
    FW_TOOL="iptables"
elif command -v nft >/dev/null 2>&1; then
    FW_TOOL="nft"
else
    echo "[错误] 未检测到 iptables 或 nft，请先安装其中之一"
    exit 1
fi
echo "[信息] 使用防火墙工具: $FW_TOOL"

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

if [ "$FW_TOOL" = "iptables" ]; then
    forward_policy=$(iptables -S FORWARD 2>/dev/null | grep '^-P FORWARD' | awk '{print $3}')
    if [ "$forward_policy" != "ACCEPT" ]; then
        echo "[修复] 设置 FORWARD 链默认 ACCEPT"
        iptables -P FORWARD ACCEPT && echo "[成功] FORWARD 链策略已设置"
    else
        echo "[OK] FORWARD 链策略正常"
    fi
else
    nft list ruleset | grep -q 'hook forward' || echo "[警告] nftables 未检测到 forward 链，请检查配置"
fi

tun_interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -E 'tun|tap' || true)
if [ -z "$tun_interfaces" ]; then
    echo "[信息] 未找到 tun/tap 虚拟接口"
else
    for tun_if in $tun_interfaces; do
        if [ "$FW_TOOL" = "iptables" ]; then
            if ! iptables -t nat -C POSTROUTING -o "$tun_if" -j MASQUERADE 2>/dev/null; then
                echo "[修复] 为接口 $tun_if 添加 NAT MASQUERADE 规则"
                iptables -t nat -A POSTROUTING -o "$tun_if" -j MASQUERADE                     && echo "[成功] $tun_if 的 NAT 规则已添加"
            else
                echo "[OK] $tun_if 的 NAT MASQUERADE 规则已存在"
            fi
        else
            if ! nft list ruleset | grep -q "oifname \"$tun_if\" masquerade"; then
                echo "[修复] 为接口 $tun_if 添加 nft MASQUERADE 规则"
                nft add rule ip nat POSTROUTING oifname "$tun_if" masquerade                     && echo "[成功] $tun_if 的 NAT 规则已添加"
            else
                echo "[OK] $tun_if 的 NAT MASQUERADE 规则已存在"
            fi
        fi
    done
fi

echo "==== $(date '+%F %T') EasyTier 自动修复完成 ===="
echo ""
