---
name: personalized-morning-brief
description: "私人订制早报系统。根据用户偏好自动采集相关资讯，每天早上定时发送个性化早报。支持AI资讯、全球新闻、赚钱机会等多维度定制。"
---

# 私人订制早报 Skill

专为不同用户设计的个性化早报系统。根据用户职业、兴趣和需求，自动收集相关资讯，生成结构化早报并定时发送。系统会在首次安装时主动询问用户偏好，实现真正的私人订制。

## 个性化定制

系统会在首次安装时主动询问用户偏好，实现真正的私人订制：

### 1. 基本信息收集
- **职业身份**（如：AI产品经理、创业者、投资者、学生等）
- **兴趣领域**（如：人工智能、科技、金融、健康、教育等）
- **核心需求**（如：行业资讯、投资机会、学习资源、市场动态等）

### 2. 内容偏好定制
- **资讯类型**：AI动态、全球新闻、赚钱机会、技术突破、政策解读等
- **深度要求**：简要概览、深度分析、技术细节、商业洞察
- **关注重点**：特定行业、公司、技术趋势、市场机会

### 3. 交付偏好设置
- **发送时间**：早上8点、9点或其他时间
- **发送频率**：每天、工作日、每周特定日期
- **内容长度**：精简版、标准版、详细版

### 示例用户画像
- **AI产品经理**：关注AI技术突破、产品发布、竞品动向、变现模式
- **创业者**：关注市场机会、投资风向、创业案例、政策支持
- **投资者**：关注宏观经济、行业趋势、公司财报、投资策略
- **学生/研究者**：关注学术进展、技术趋势、学习资源、职业发展

## 系统架构

```
数据采集 → 内容处理 → 模板渲染 → 定时发送
    ↓           ↓           ↓          ↓
多源抓取   智能筛选    Markdown    Feishu推送
```

## 核心功能

### 1. 多源数据采集
- **AI资讯**: TechCrunch, 36氪, AI论文平台, Twitter趋势
- **全球新闻**: Bloomberg, Reuters, 国内主流媒体
- **赚钱机会**: VC投资动态, SaaS趋势, 副业灵感, 市场分析

### 2. 智能内容筛选
- 基于用户偏好个性化加权
- 去重和相关性排序
- 关键信息提取和摘要

### 3. 结构化早报模板
```
🤖 AI前沿动态
  • [突破性论文] ...
  • [产品发布] ...
  • [趋势分析] ...

🌍 全球要闻速览  
  • [政策影响] ...
  • [市场波动] ...
  • [地缘事件] ...

💰 赚钱机会挖掘
  • [产品机会] ...
  • [变现模式] ...
  • [投资风向] ...

🎯 今日行动建议
  • [产品构思] ...
  • [实验建议] ...
  • [关注清单] ...
```

### 4. 定时自动发送
- 每天早上8:00 (GMT+8) 自动触发
- 通过Feishu通道发送到用户
- 支持工作日/周末配置

## 快速开始

### 1. 安装
```bash
# 在工作空间创建skill目录
mkdir -p ~/.openclaw/workspace/skills/morning-brief

# 复制所有文件到目录
cp -r morning-brief/* ~/.openclaw/workspace/skills/morning-brief/
```

### 2. 配置
编辑配置文件设置用户偏好：
```bash
# 编辑配置文件
vim ~/.openclaw/workspace/skills/morning-brief/config/user-preferences.json
```

### 3. 测试运行
```bash
# 手动测试早报生成
cd ~/.openclaw/workspace/skills/morning-brief
./scripts/generate-brief.sh --test
```

### 4. 设置定时任务
```bash
# 创建cron任务
echo "0 8 * * * cd /root/.openclaw/workspace/skills/morning-brief && ./scripts/generate-brief.sh" | crontab -
```

## 文件结构

```
morning-brief/
├── SKILL.md                    # 本文件
├── config/
│   ├── user-preferences.json   # 用户偏好配置
│   ├── sources.json           # 数据源配置
│   └── channels.json          # 发送通道配置
├── templates/
│   ├── daily-brief.md         # 早报主模板
│   ├── ai-section.md          # AI资讯模板
│   ├── news-section.md        # 新闻模板
│   └── money-section.md       # 赚钱机会模板
├── scripts/
│   ├── generate-brief.sh      # 主生成脚本
│   ├── fetch-ai-news.sh       # AI资讯采集
│   ├── fetch-global-news.sh   # 全球新闻采集
│   └── fetch-money-ops.sh     # 赚钱机会采集
├── sources/
│   ├── ai-sources.txt         # AI资讯源列表
│   ├── news-sources.txt       # 新闻源列表
│   └── money-sources.txt      # 赚钱机会源列表
├── logs/
│   ├── daily-2026-02-28.log   # 每日运行日志
│   └── error.log              # 错误日志
└── examples/
    └── sample-brief.md        # 示例早报
```

## 配置说明

### 用户偏好 (user-preferences.json)
```json
{
  "user_profile": {
    "occupation": "AI产品经理",
    "interests": ["人工智能", "创业", "科技投资", "SaaS"],
    "money_focus": ["产品机会", "投资机会", "副业变现"]
  },
  "content_preferences": {
    "ai_coverage": ["技术突破", "产品发布", "商业案例"],
    "news_priority": ["科技政策", "经济事件", "市场数据"],
    "money_sections": ["产品机会", "变现模式", "投资风向"]
  },
  "delivery_settings": {
    "time": "08:00",
    "timezone": "GMT+8",
    "weekdays_only": true,
    "platform": "feishu"
  }
}
```

### 数据源配置 (sources.json)
```json
{
  "ai_sources": [
    {"name": "TechCrunch AI", "url": "https://techcrunch.com/category/artificial-intelligence/"},
    {"name": "36氪AI", "url": "https://36kr.com/tag/人工智能"},
    {"name": "arXiv AI", "url": "https://arxiv.org/list/cs.AI/recent"}
  ],
  "news_sources": [
    {"name": "Bloomberg", "url": "https://www.bloomberg.com/technology"},
    {"name": "Reuters Tech", "url": "https://www.reuters.com/technology/"}
  ],
  "money_sources": [
    {"name": "VC投资动态", "url": "https://news.crunchbase.com/"},
    {"name": "SaaS趋势", "url": "https://www.saastr.com/"}
  ]
}
```

## 定制化选项

### 内容调整
向AI发送指令调整早报内容：
- "增加更多技术深度分析"
- "减少全球新闻，专注AI"
- "加入具体的产品构思案例"
- "添加天气信息"

### 发送调整
- 调整发送时间："改为9点发送"
- 修改频率："只在工作日发送"
- 添加渠道："同时发送到Telegram"

### 功能扩展
- "加入竞争对手监控"
- "添加AI股票表现"
- "生成语音播报版本"

## 技术依赖

- OpenClaw的`web_search`和`web_fetch`工具
- `exec`用于脚本执行和cron管理
- `message`用于Feishu消息发送
- `memory_search`用于个性化内容推荐

## 故障排除

### 常见问题
1. **早报未发送**: 检查cron任务状态和网络连接
2. **内容重复**: 清理缓存和去重数据库
3. **格式错误**: 检查模板文件和Markdown渲染

### 日志检查
```bash
# 查看最新运行日志
tail -f ~/.openclaw/workspace/skills/morning-brief/logs/daily-*.log
```

## 更新维护

定期更新数据源和优化算法以保持内容质量。用户反馈会自动集成到个性化模型中。

---

*专为AI产品经理打造，让每个早晨都充满机遇和洞察。*