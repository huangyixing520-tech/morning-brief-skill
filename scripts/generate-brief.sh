#!/bin/bash

# Morning Brief Generator
# 每天早上8点自动运行的早报生成脚本

# 设置PATH确保openclaw命令可用
export PATH=$PATH:/root/.nvm/versions/node/v22.22.0/bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACE_DIR="/root/.openclaw/workspace"
LOG_DIR="$SKILL_DIR/logs"
CONFIG_DIR="$SKILL_DIR/config"
TEMPLATE_DIR="$SKILL_DIR/templates"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/daily-$(date '+%Y-%m-%d').log"
}

# 错误处理
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# 检查依赖
check_dependencies() {
    log "INFO" "检查系统依赖..."
    
    # 检查OpenClaw命令
    if ! command -v openclaw &> /dev/null; then
        error_exit "OpenClaw命令行工具未安装"
    fi
    
    log "INFO" "依赖检查通过"
}

# 加载配置
load_config() {
    log "INFO" "加载配置文件..."
    
    if [ ! -f "$CONFIG_DIR/user-preferences.json" ]; then
        error_exit "用户配置文件不存在: $CONFIG_DIR/user-preferences.json"
    fi
    
    if [ ! -f "$CONFIG_DIR/sources.json" ]; then
        error_exit "数据源配置文件不存在: $CONFIG_DIR/sources.json"
    fi
    
    # 可以在这里解析JSON，简化版直接引用
    log "INFO" "配置加载完成"
}

# 获取当前日期信息
get_date_info() {
    local current_date=$(date '+%Y-%m-%d')
    local current_weekday=$(date '+%A')
    local current_time=$(date '+%H:%M')
    
    echo "{\"date\":\"$current_date\",\"weekday\":\"$current_weekday\",\"time\":\"$current_time\"}"
}

# 获取天气信息（可选）
get_weather_info() {
    # 简化版，可以调用天气API
    echo "晴转多云，15-22°C"
}

# 生成早报内容
generate_brief() {
    log "INFO" "开始生成早报..."
    
    local date_info=$(get_date_info)
    local weather_info=$(get_weather_info)
    
    # 这里应该调用各个采集脚本并整合
    # 暂时生成一个示例早报
    
    local example_brief="# 🌅 早安，OneStar！

$(date '+%Y-%m-%d %A') | $weather_info

---

## 🤖 **AI前沿动态**

### 🔥 今日AI热点
- **OpenAI发布新模型** - 多模态能力大幅提升，支持视频生成和复杂推理
- **国内AI公司融资动态** - 多家初创公司完成千万级融资
- **arXiv最新论文** - 新算法提升训练效率40%

### 📈 趋势观察
多模态AI成为竞争焦点，各大公司加速布局视频生成和具身智能。

---

## 🌍 **全球要闻速览**

### 📊 经济事件
- **美联储利率决策** - 维持不变，对科技股影响有限
- **欧洲科技政策** - 新AI法案通过，关注合规要求

### ⚠️ 风险提示
关注地缘政治对芯片供应链的影响。

---

## 💰 **赚钱机会挖掘**

### 💡 产品机会
- **AI客服优化工具** - 中小企业需求旺盛，市场空间约50亿
- **个性化学习助手** - 教育+AI结合，用户付费意愿强

### 🏦 变现模式
- **API按需计费** - 适合技术型产品，边际成本低
- **SaaS订阅制** - 稳定现金流，客户生命周期价值高

---

## 🎯 **今日行动建议**

1. **调研AI客服市场** - 分析现有竞品和用户痛点
2. **学习多模态AI技术** - 了解最新进展和实现方式
3. **联系潜在合作伙伴** - 寻找教育或客服领域的合作机会

---

**早报统计**：共 12 条资讯 | 生成时间：$(date '+%H:%M')  
**明日预告**：关注AI投资峰会和产品发布会

---
*让每个早晨都充满机遇和洞察。*"
    
    echo "$example_brief"
}

# 发送到Feishu
# 创建发送标记文件
create_sent_marker() {
    local marker_file="/root/.openclaw/workspace/.morning-brief-sent-$(date +%Y-%m-%d)"
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$marker_file"
    log "INFO" "创建早报发送标记文件: $marker_file"
}

send_to_feishu() {
    local content="$1"
    
    log "INFO" "发送早报到Feishu..."
    
    # 将内容写入临时文件避免命令行长度限制
    local temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    
    # 发送消息到Feishu，使用timeout防止卡死
    local timeout_cmd="timeout"
    if ! command -v timeout &> /dev/null; then
        timeout_cmd=""  # 如果timeout命令不存在，直接运行
    fi
    
    # 直接调用openclaw命令，使用临时文件内容
    if [ -n "$timeout_cmd" ]; then
        # 使用30秒超时
        if $timeout_cmd 30 openclaw message send --channel feishu --message "$content" --target "user:ou_52a96f7895175933d2998f0ecc2eddf3" 2>&1; then
            log "INFO" "早报发送成功"
            create_sent_marker
        else
            local exit_status=$?
            if [ $exit_status -eq 124 ]; then
                log "WARNING" "发送命令超时（30秒），但消息可能仍在后台发送"
                # 超时情况下不确定是否成功，不创建标记文件
            else
                log "ERROR" "发送命令失败，退出状态: $exit_status"
            fi
        fi
    else
        # 没有timeout命令，在后台运行并立即返回
        if openclaw message send --channel feishu --message "$content" --target "user:ou_52a96f7895175933d2998f0ecc2eddf3" >/dev/null 2>&1 & then
            log "INFO" "发送命令已后台启动（无法确认是否成功）"
            # 后台启动，假设成功，创建标记文件
            create_sent_marker
        else
            log "ERROR" "无法启动发送命令"
        fi
    fi
    
    # 清理临时文件
    rm -f "$temp_file"
    
    log "INFO" "早报发送流程完成"
}

# 主函数
main() {
    log "INFO" "=== 开始早报生成流程 ==="
    
    # 检查依赖
    check_dependencies
    
    # 加载配置
    load_config
    
    # 生成早报内容
    local brief_content=$(generate_brief)
    
    # 发送到Feishu
    send_to_feishu "$brief_content"
    
    log "INFO" "=== 早报生成流程完成 ==="
}

# 执行主函数
main "$@"