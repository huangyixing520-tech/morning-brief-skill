#!/bin/bash

# 私人订制早报 Skill 初始化脚本

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/root/.openclaw/workspace"
CONFIG_FILE="$SKILL_DIR/config/user-preferences.json"

echo "=== 私人订制早报 Skill 初始化 ==="
echo "技能目录: $SKILL_DIR"
echo "工作空间: $WORKSPACE_DIR"

# 检查目录结构
echo "1. 检查目录结构..."
mkdir -p "$SKILL_DIR/config"
mkdir -p "$SKILL_DIR/templates"
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/logs"
mkdir -p "$SKILL_DIR/data"
mkdir -p "$SKILL_DIR/sources"

echo "目录结构创建完成"

# 检查必要文件
echo "2. 检查必要文件..."

REQUIRED_FILES=(
    "SKILL.md"
    "config/sources.json"
    "templates/daily-brief.md"
    "templates/ai-section.md"
    "templates/news-section.md"
    "templates/money-section.md"
    "templates/action-section.md"
    "scripts/generate-brief.sh"
    "scripts/fetch-ai-news.sh"
    "scripts/fetch-global-news.sh"
    "scripts/fetch-money-ops.sh"
)

missing_files=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$SKILL_DIR/$file" ]; then
        echo "  ❌ 缺失: $file"
        missing_files=$((missing_files + 1))
    else
        echo "  ✅ 存在: $file"
    fi
done

if [ $missing_files -gt 0 ]; then
    echo "错误: 缺少 $missing_files 个必要文件"
    exit 1
fi

# 设置脚本权限
echo "3. 设置脚本执行权限..."
chmod +x "$SKILL_DIR/scripts/"*.sh

# 检查依赖工具
echo "4. 检查系统依赖..."
if command -v jq &> /dev/null; then
    echo "  ✅ jq 已安装"
else
    echo "  ⚠️  jq 未安装，部分功能可能受限"
    echo "  建议安装: apt-get install jq 或 yum install jq"
fi

if command -v python3 &> /dev/null; then
    echo "  ✅ python3 已安装"
else
    echo "  ❌ python3 未安装，配置生成需要python3"
    echo "  请先安装: apt-get install python3 或 yum install python3"
    exit 1
fi

if command -v openclaw &> /dev/null; then
    echo "  ✅ OpenClaw 已安装"
else
    echo "  ❌ OpenClaw 未安装"
    echo "  请先安装 OpenClaw: https://docs.openclaw.ai"
    exit 1
fi

# 用户偏好配置
echo "5. 配置用户偏好..."
echo "----------------------------------------"
echo "欢迎使用私人订制早报系统！"
echo "我将询问几个问题，为您定制专属早报内容。"
echo "----------------------------------------"

# 检查是否已有配置文件
reconfigure=false
if [ -f "$CONFIG_FILE" ]; then
    echo "检测到已存在的用户配置文件。"
    read -p "是否重新配置？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reconfigure=true
        echo "开始重新配置..."
    else
        echo "使用现有配置。"
        reconfigure=false
    fi
else
    reconfigure=true
fi

if [ "$reconfigure" = true ]; then
    # 收集用户信息
    echo ""
    echo "=== 基本信息 ==="
    read -p "您的称呼/姓名: " user_name
    read -p "您的职业 (如: AI产品经理、创业者、投资者等): " user_occupation
    
    echo ""
    echo "=== 兴趣领域 (可多选，用逗号分隔) ==="
    echo "可选: 人工智能, 科技, 金融, 健康, 教育, 创业, 投资, 市场, 政策, 学术"
    read -p "您感兴趣的领域: " user_interests
    
    echo ""
    echo "=== 核心需求 (可多选，用逗号分隔) ==="
    echo "可选: 行业资讯, 投资机会, 学习资源, 市场动态, 技术突破, 产品发布, 竞品动向, 政策解读"
    read -p "您的核心需求: " user_needs
    
    echo ""
    echo "=== 赚钱关注重点 (可多选，用逗号分隔) ==="
    echo "可选: 产品机会, 投资机会, 副业变现, SaaS模式, API经济, 内容变现, 电商机会"
    read -p "您关注的赚钱方向: " user_money_focus
    
    echo ""
    echo "=== 内容偏好 ==="
    echo "请为以下内容类型分配权重 (1-10分，10分表示最关注):"
    read -p "AI/技术资讯权重 (1-10): " ai_priority
    read -p "全球/行业新闻权重 (1-10): " news_priority
    read -p "赚钱/商业机会权重 (1-10): " money_priority
    
    echo ""
    echo "=== 交付设置 ==="
    read -p "早报发送时间 (格式: HH:MM，如08:00): " delivery_time
    read -p "发送频率 (每天/工作日/自定义): " delivery_frequency
    read -p "早报平台 (feishu/telegram/其他): " delivery_platform
    
    # 生成JSON配置
    echo ""
    echo "正在生成个性化配置..."
    
    python3 -c "
import json
import sys

config = {
    'user_profile': {
        'name': '$user_name',
        'occupation': '$user_occupation',
        'interests': [x.strip() for x in '$user_interests'.split(',') if x.strip()],
        'needs': [x.strip() for x in '$user_needs'.split(',') if x.strip()],
        'money_focus': [x.strip() for x in '$user_money_focus'.split(',') if x.strip()],
        'content_style': '简洁、实用、行动导向'
    },
    'content_preferences': {
        'ai_coverage': {
            'sections': ['技术突破', '产品发布', '商业案例', '竞品动向', '论文进展'],
            'priority': float('$ai_priority') if '$ai_priority' else 1.0,
            'depth': '中等技术细节，关注商业化应用'
        },
        'news_coverage': {
            'sections': ['科技政策', '经济事件', '市场波动', '地缘影响', '行业动态'],
            'priority': float('$news_priority') if '$news_priority' else 0.8,
            'focus': '对科技和投资有直接影响的事件'
        },
        'money_coverage': {
            'sections': ['产品机会', '变现模式', '投资风向', '副业灵感', '市场分析'],
            'priority': float('$money_priority') if '$money_priority' else 0.9,
            'approach': '具体可操作的赚钱思路，含市场规模分析'
        }
    },
    'delivery_settings': {
        'time': '$delivery_time' if '$delivery_time' else '08:00',
        'frequency': '$delivery_frequency' if '$delivery_frequency' else '每天',
        'platform': '$delivery_platform' if '$delivery_platform' else 'feishu',
        'format': 'markdown',
        'include_weather': False,
        'include_motivation': True,
        'max_items_per_section': 5
    },
    'advanced_options': {
        'enable_ai_analysis': True,
        'include_action_items': True,
        'track_competitors': [],
        'monitor_keywords': ['AI', '科技', '投资', '创业', '市场'],
        'learning_rate': 0.1,
        'cache_duration_hours': 6
    }
}

with open('$CONFIG_FILE', 'w', encoding='utf-8') as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print('配置文件已生成: $CONFIG_FILE')
"
    
    if [ $? -eq 0 ]; then
        echo "  ✅ 个性化配置生成成功"
    else
        echo "  ❌ 配置生成失败"
        exit 1
    fi
fi

# 测试配置文件
echo "6. 测试配置文件..."
if python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    echo "  ✅ user-preferences.json 格式正确"
else
    echo "  ❌ user-preferences.json 格式错误"
    exit 1
fi

if python3 -c "import json; json.load(open('$SKILL_DIR/config/sources.json'))" 2>/dev/null; then
    echo "  ✅ sources.json 格式正确"
else
    echo "  ❌ sources.json 格式错误"
    exit 1
fi

# 创建cron任务
echo "7. 配置定时任务..."
# 从配置中提取时间
delivery_time=$(python3 -c "
import json
import re
try:
    with open('$CONFIG_FILE', 'r', encoding='utf-8') as f:
        config = json.load(f)
    time_str = config.get('delivery_settings', {}).get('time', '08:00')
    # 解析时间格式 HH:MM
    match = re.match(r'(\d{1,2}):(\d{2})', time_str)
    if match:
        hour = match.group(1)
        minute = match.group(2)
        print(f'{minute} {hour} * * *')
    else:
        print('0 8 * * *')
except Exception as e:
    print('0 8 * * *')
")

CRON_JOB="$delivery_time cd $SKILL_DIR && ./scripts/generate-brief.sh"

# 检查是否已有该cron任务
if crontab -l 2>/dev/null | grep -q "generate-brief.sh"; then
    echo "  ✅ 定时任务已存在"
else
    echo "  添加cron任务: $CRON_JOB"
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    if [ $? -eq 0 ]; then
        echo "  ✅ 定时任务添加成功"
    else
        echo "  ❌ 定时任务添加失败"
        echo "  请手动添加: crontab -e"
    fi
fi

# 测试运行
echo "8. 测试运行..."
cd "$SKILL_DIR"
if ./scripts/generate-brief.sh --test 2>&1 | head -20; then
    echo "  ✅ 测试运行成功"
else
    echo "  ⚠️  测试运行遇到问题，但技能仍可安装"
fi

echo ""
echo "=== 初始化完成 ==="
echo ""
echo "技能名称: 私人订制早报"
echo "功能: 根据您的偏好定时发送个性化早报"
echo "发送平台: $(python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('delivery_settings', {}).get('platform', 'feishu'))
except:
    print('feishu')
")"
echo "发送时间: $(python3 -c "
import json
try:
    with open('$CONFIG_FILE', 'r') as f:
        config = json.load(f)
    print(config.get('delivery_settings', {}).get('time', '08:00'))
except:
    print('08:00')
")"
echo ""
echo "下一步:"
echo "1. 检查配置: $CONFIG_FILE"
echo "2. 手动测试: cd $SKILL_DIR && ./scripts/generate-brief.sh"
echo "3. 查看日志: tail -f $SKILL_DIR/logs/daily-*.log"
echo "4. 明天查看首份订制早报"
echo ""
echo "定制建议:"
echo "- 修改配置调整内容偏好: $CONFIG_FILE"
echo "- 添加数据源提升信息质量: $SKILL_DIR/config/sources.json"
echo "- 调整发送时间或频率"
echo ""
echo "祝您使用愉快！"