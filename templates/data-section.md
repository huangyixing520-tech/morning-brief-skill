### 📈 **AI相关数据点**

{{#if stock_data}}
#### 📊 AI股票表现
{{#each stock_data}}
- **{{stock}}** - {{price_change}} ({{percent_change}}) {{#if reason}}原因：{{reason}}{{/if}}
{{/each}}
{{/if}}

{{#if crypto_ai}}
#### 🪙 AI加密货币
{{#each crypto_ai}}
- **{{token}}** - {{price}} {{price_change_24h}} {{#if news}}（{{news}}）{{/if}}
{{/each}}
{{/if}}

{{#if tool_trends}}
#### 🛠️ AI工具热度
{{#each tool_trends}}
- **{{tool}}** - {{trend}} {{#if user_growth}}用户增长：{{user_growth}}{{/if}}
{{/each}}
{{/if}}

{{#if job_market}}
#### 💼 AI岗位需求
{{#each job_market}}
- **{{role}}** - {{demand_level}}，平均薪资：{{avg_salary}}
{{/each}}
{{/if}}

### 📊 **投资市场数据**
{{investment_data}}

### 📱 **产品指标参考**
{{product_metrics}}