#!/bin/bash

# 系统心跳报告脚本
# 每天8:10运行，发送系统状态报告到Feishu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACE_DIR="/root/.openclaw/workspace"
LOG_DIR="$SKILL_DIR/logs"

# 确保OpenClaw命令在PATH中
export PATH=$PATH:/root/.nvm/versions/node/v22.22.0/bin

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/heartbeat-$(date '+%Y-%m-%d').log"
}

# 获取系统状态
get_system_status() {
    local today=$(date +%Y-%m-%d)
    local sent_marker="$WORKSPACE_DIR/.morning-brief-sent-$today"
    
    # 检查早报状态
    local brief_status="❌ 未发送"
    local brief_time="未知"
    
    if [ -f "$sent_marker" ]; then
        brief_status="✅ 已发送"
        brief_time=$(cat "$sent_marker" 2>/dev/null || echo "未知时间")
    fi
    
    # 检查cron任务状态
    local cron_status="✅ 正常"
    if ! crontab -l 2>/dev/null | grep -q "generate-brief.sh"; then
        cron_status="⚠️ 早报任务未找到"
    fi
    
    if ! crontab -l 2>/dev/null | grep -q "monitor.sh"; then
        cron_status="$cron_status, 监控任务未找到"
    fi
    
    # 检查OpenClaw服务
    local openclaw_status="✅ 正常"
    if ! command -v openclaw &> /dev/null; then
        openclaw_status="❌ 未找到命令"
    fi
    
    # 检查网络连接
    local network_status="✅ 正常"
    if ! curl -Is https://www.bbc.com/news >/dev/null 2>&1; then
        network_status="⚠️ BBC不可访问"
    fi
    
    # 检查磁盘空间
    local disk_status=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    local disk_status_text="✅ 正常 ($disk_status% 已用)"
    if [ "$disk_status" -gt 90 ]; then
        disk_status_text="⚠️ 空间紧张 ($disk_status% 已用)"
    elif [ "$disk_status" -gt 95 ]; then
        disk_status_text="❌ 空间不足 ($disk_status% 已用)"
    fi
    
    # 检查内存使用
    local mem_total=$(free -m | awk 'NR==2 {print $2}')
    local mem_used=$(free -m | awk 'NR==2 {print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    local mem_status_text="✅ 正常 ($mem_percent% 已用)"
    
    if [ "$mem_percent" -gt 80 ]; then
        mem_status_text="⚠️ 内存紧张 ($mem_percent% 已用)"
    fi
    
    # 返回状态JSON
    cat << EOF
{
    "brief": {
        "status": "$brief_status",
        "time": "$brief_time"
    },
    "cron": "$cron_status",
    "openclaw": "$openclaw_status",
    "network": "$network_status",
    "disk": "$disk_status_text",
    "memory": "$mem_status_text",
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
}

# 生成心跳报告消息
generate_heartbeat_message() {
    local status_json="$1"
    
    # 解析JSON（使用简单的文本处理，因为环境可能没有jq）
    local brief_status=$(echo "$status_json" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
    local brief_time=$(echo "$status_json" | grep -o '"time": "[^"]*"' | cut -d'"' -f4)
    local cron_status=$(echo "$status_json" | grep -o '"cron": "[^"]*"' | cut -d'"' -f4)
    local openclaw_status=$(echo "$status_json" | grep -o '"openclaw": "[^"]*"' | cut -d'"' -f4)
    local network_status=$(echo "$status_json" | grep -o '"network": "[^"]*"' | cut -d'"' -f4)
    local disk_status=$(echo "$status_json" | grep -o '"disk": "[^"]*"' | cut -d'"' -f4)
    local memory_status=$(echo "$status_json" | grep -o '"memory": "[^"]*"' | cut -d'"' -f4)
    local timestamp=$(echo "$status_json" | grep -o '"timestamp": "[^"]*"' | cut -d'"' -f4)
    
    cat << EOF
💓 **系统心跳报告** ($timestamp)

## 📰 早报状态
- **状态**: $brief_status
- **时间**: $brief_time

## ⚙️ 系统健康
- **Cron任务**: $cron_status
- **OpenClaw服务**: $openclaw_status
- **网络连接**: $network_status
- **磁盘空间**: $disk_status
- **内存使用**: $memory_status

## 🚨 异常处理
- **监控系统**: 已部署（每30分钟检查一次）
- **自动重试**: 08:30后检测到未发送将自动重试
- **告警通知**: 异常时会发送Feishu告警

## 📊 日志位置
- 早报日志: $LOG_DIR/daily-$(date '+%Y-%m-%d').log
- 监控日志: $LOG_DIR/monitor-$(date '+%Y-%m-%d').log
- 心跳日志: $LOG_DIR/heartbeat-$(date '+%Y-%m-%d').log

---
*系统状态: $([ "$brief_status" = "✅ 已发送" ] && echo "一切正常 🌟" || echo "需要关注 ⚠️")*
EOF
}

# 发送心跳报告到Feishu
send_heartbeat_report() {
    local message="$1"
    
    log "INFO" "发送心跳报告到Feishu..."
    
    # 使用超时防止卡死
    local timeout_cmd="timeout"
    if ! command -v timeout &> /dev/null; then
        timeout_cmd=""
    fi
    
    if [ -n "$timeout_cmd" ]; then
        if $timeout_cmd 20 openclaw message send --channel feishu \
            --message "$message" \
            --target "user:ou_52a96f7895175933d2998f0ecc2eddf3" 2>&1; then
            log "INFO" "心跳报告发送成功"
            return 0
        else
            local exit_status=$?
            log "ERROR" "心跳报告发送失败，退出状态: $exit_status"
            return $exit_status
        fi
    else
        if openclaw message send --channel feishu \
            --message "$message" \
            --target "user:ou_52a96f7895175933d2998f0ecc2eddf3" >/dev/null 2>&1 & then
            log "INFO" "心跳报告已后台启动"
            return 0
        else
            log "ERROR" "无法启动心跳报告发送"
            return 1
        fi
    fi
}

# 主函数
main() {
    log "INFO" "=== 开始系统心跳检查 ==="
    
    # 获取系统状态
    local system_status=$(get_system_status)
    log "DEBUG" "系统状态: $system_status"
    
    # 生成心跳消息
    local heartbeat_message=$(generate_heartbeat_message "$system_status")
    
    # 发送心跳报告
    send_heartbeat_report "$heartbeat_message"
    local send_result=$?
    
    if [ $send_result -eq 0 ]; then
        log "INFO" "=== 系统心跳检查完成，报告已发送 ==="
    else
        log "ERROR" "=== 系统心跳检查完成，但报告发送失败 ==="
    fi
    
    return $send_result
}

# 执行主函数
main "$@"