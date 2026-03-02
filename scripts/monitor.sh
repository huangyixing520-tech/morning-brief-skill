#!/bin/bash

# 早报系统监控脚本
# 每30分钟运行一次，检查早报是否已发送
# 如果08:30后仍未发送，则触发重试并告警

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
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/monitor-$(date '+%Y-%m-%d').log"
}

# 发送Feishu消息函数
send_feishu_alert() {
    local level="$1"
    local message="$2"
    
    local alert_message="🚨 **早报系统监控告警** ($level)
    
时间: $(date '+%Y-%m-%d %H:%M:%S')
状态: $message

详细信息已记录到日志文件。
如需查看完整日志: tail -f $LOG_DIR/monitor-$(date '+%Y-%m-%d').log"
    
    log "ALERT" "发送告警到Feishu: $message"
    
    # 发送告警消息，超时10秒
    timeout 10 openclaw message send --channel feishu \
        --message "$alert_message" \
        --target "user:ou_52a96f7895175933d2998f0ecc2eddf3" 2>&1 | \
        tee -a "$LOG_DIR/monitor-$(date '+%Y-%m-%d').log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "INFO" "告警消息发送成功"
    else
        log "ERROR" "告警消息发送失败"
    fi
}

# 清理旧文件
cleanup_old_files() {
    log "INFO" "开始清理旧文件..."
    
    # 清理7天前的标记文件
    find "$WORKSPACE_DIR" -name ".morning-brief-sent-*" -mtime +7 -delete 2>/dev/null
    local cleaned_markers=$?
    if [ $cleaned_markers -eq 0 ]; then
        log "INFO" "已清理7天前的早报标记文件"
    fi
    
    # 清理7天前的日志文件
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null
    local cleaned_logs=$?
    if [ $cleaned_logs -eq 0 ]; then
        log "INFO" "已清理7天前的日志文件"
    fi
    
    # 清理data目录中的旧数据文件
    local data_dir="$SKILL_DIR/data"
    if [ -d "$data_dir" ]; then
        find "$data_dir" -name "*.json" -mtime +7 -delete 2>/dev/null
        log "INFO" "已清理7天前的数据文件"
    fi
    
    log "INFO" "文件清理完成"
}

# 主监控逻辑
main() {
    log "INFO" "=== 开始早报系统监控检查 ==="
    
    # 执行文件清理
    cleanup_old_files
    
    # 获取当前时间
    local current_time=$(date +%H:%M)
    local today=$(date +%Y-%m-%d)
    local sent_marker="$WORKSPACE_DIR/.morning-brief-sent-$today"
    
    log "INFO" "当前时间: $current_time, 今天日期: $today"
    log "INFO" "标记文件路径: $sent_marker"
    
    # 检查标记文件是否存在
    if [ -f "$sent_marker" ]; then
        local sent_time=$(cat "$sent_marker" 2>/dev/null || echo "unknown")
        log "INFO" "早报已发送 (发送时间: $sent_time)"
        log "INFO" "=== 监控检查完成，状态正常 ==="
        return 0
    fi
    
    log "WARNING" "早报标记文件不存在，早报可能未发送"
    
    # 检查是否已经过了08:30
    if [[ "$current_time" > "08:30" ]]; then
        log "ERROR" "当前时间 $current_time 已超过08:30，早报未发送，触发重试"
        
        # 发送告警
        send_feishu_alert "ERROR" "早报未在08:30前发送，正在触发重试"
        
        # 触发重试
        log "INFO" "开始执行早报重试..."
        cd "$SKILL_DIR" && ./scripts/generate-brief.sh 2>&1 | \
            tee -a "$LOG_DIR/monitor-$(date '+%Y-%m-%d').log"
        
        local retry_result=${PIPESTATUS[0]}
        
        if [ $retry_result -eq 0 ]; then
            log "INFO" "早报重试执行成功"
            send_feishu_alert "INFO" "早报重试发送成功"
        else
            log "ERROR" "早报重试执行失败，退出码: $retry_result"
            send_feishu_alert "CRITICAL" "早报重试发送失败，退出码: $retry_result"
        fi
        
        log "INFO" "=== 监控检查完成，已触发重试 ==="
        return $retry_result
    else
        log "INFO" "当前时间 $current_time 尚未到08:30，继续等待"
        log "INFO" "=== 监控检查完成，等待中 ==="
        return 0
    fi
}

# 执行主函数
main "$@"