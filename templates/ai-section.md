### 🔥 **今日AI热点**

{{#if breakthroughs}}
#### 🚀 技术突破
{{#each breakthroughs}}
- **{{title}}** - {{summary}} {{#if link}}[详情]({{link}}){{/if}}
{{/each}}
{{/if}}

{{#if products}}
#### 📦 产品发布  
{{#each products}}
- **{{name}}** - {{description}} {{#if link}}[查看]({{link}}){{/if}}
{{/each}}
{{/if}}

{{#if business}}
#### 💼 商业案例
{{#each business}}
- **{{company}}** - {{achievement}} ({{impact}})
{{/each}}
{{/if}}

{{#if competitors}}
#### 🏃‍♂️ 竞品动向
{{#each competitors}}
- **{{competitor}}** - {{move}} {{#if significance}}*{{significance}}*{{/if}}
{{/each}}
{{/if}}

{{#if research}}
#### 📚 论文进展
{{#each research}}
- **{{paper_title}}** - {{key_finding}} {{#if link}}[arXiv]({{link}}){{/if}}
{{/each}}
{{/if}}

### 📈 **趋势观察**
{{trend_analysis}}

### 💡 **产品灵感**
{{product_insights}}