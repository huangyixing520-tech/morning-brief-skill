#!/bin/bash

# Morning Brief Skill 初始化脚本

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/root/.openclaw/workspace"

echo "=== Morning Brief Skill 初始化 ==="
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
    "config/user-preferences.json"
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

if command -v openclaw &> /dev/null; then
    echo "  ✅ OpenClaw 已安装"
else
    echo "  ❌ OpenClaw 未安装"
    echo "  请先安装 OpenClaw: https://docs.openclaw.ai"
    exit 1
fi

# 测试配置文件
echo "5. 测试配置文件..."
if python3 -c "import json; json.load(open('$SKILL_DIR/config/user-preferences.json'))" 2>/dev/null; then
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
echo "6. 配置定时任务..."
CRON_JOB="0 8 * * * cd $SKILL_DIR && ./scripts/generate-brief.sh"

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
echo "7. 测试运行..."
cd "$SKILL_DIR"
if ./scripts/generate-brief.sh --test 2>&1 | head -20; then
    echo "  ✅ 测试运行成功"
else
    echo "  ⚠️  测试运行遇到问题，但技能仍可安装"
fi

echo ""
echo "=== 初始化完成 ==="
echo ""
echo "技能名称: Morning Brief"
echo "功能: 每天早上8点发送AI资讯、全球新闻和赚钱机会早报"
echo "发送平台: Feishu"
echo "用户: OneStar (AI产品经理)"
echo ""
echo "下一步:"
echo "1. 检查配置: $SKILL_DIR/config/user-preferences.json"
echo "2. 手动测试: cd $SKILL_DIR && ./scripts/generate-brief.sh"
echo "3. 查看日志: tail -f $SKILL_DIR/logs/daily-*.log"
echo "4. 明天早上8点查看首份早报"
echo ""
echo "定制建议:"
echo "- 修改配置调整内容偏好"
echo "- 添加数据源提升信息质量"
echo "- 调整发送时间或频率"
echo ""
echo "祝你使用愉快！"