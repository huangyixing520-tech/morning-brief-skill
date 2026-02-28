### 💡 **产品机会**

{{#if product_opportunities}}
{{#each product_opportunities}}
- **{{opportunity}}** - {{market_size}}，{{why_now}} {{#if implementation}}→ 实施思路：{{implementation}}{{/if}}
{{/each}}
{{/if}}

### 🏦 **变现模式**

{{#if monetization_models}}
{{#each monetization_models}}
- **{{model}}** - {{description}} {{#if example}}（例如：{{example}}）{{/if}} {{#if revenue_potential}}*收入潜力：{{revenue_potential}}*{{/if}}
{{/each}}
{{/if}}

### 📈 **投资风向**

{{#if investment_trends}}
{{#each investment_trends}}
- **{{sector}}** - {{trend_detail}} {{#if notable_deals}}（{{notable_deals}}）{{/if}}
{{/each}}
{{/if}}

### 🛠️ **副业灵感**

{{#if side_project_ideas}}
{{#each side_project_ideas}}
- **{{idea}}** - {{description}} {{#if effort}}所需精力：{{effort}} | 潜在收益：{{potential}} {{/if}}
{{/each}}
{{/if}}

### 📊 **市场分析**

{{market_analysis}}

### 🎯 **快速验证思路**
{{validation_ideas}}