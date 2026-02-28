### 🌐 **全球头条**

{{#if policy}}
#### 📜 政策影响
{{#each policy}}
- **{{region}}** - {{policy_detail}} ({{impact_on_tech}})
{{/each}}
{{/if}}

{{#if economy}}
#### 📊 经济事件
{{#each economy}}
- **{{event}}** - {{description}} {{#if market_impact}}→ {{market_impact}}{{/if}}
{{/each}}
{{/if}}

{{#if markets}}
#### 📉 市场波动
{{#each markets}}
- **{{market}}** - {{movement}} ({{reason}})
{{/each}}
{{/if}}

{{#if geopolitics}}
#### 🗺️ 地缘动态
{{#each geopolitics}}
- **{{situation}}** - {{detail}} {{#if tech_implication}}*科技影响：{{tech_implication}}*{{/if}}
{{/each}}
{{/if}}

{{#if industry}}
#### 🏭 行业动态
{{#each industry}}
- **{{industry_name}}** - {{development}} {{#if link}}[报道]({{link}}){{/if}}
{{/each}}
{{/if}}

### 🔍 **深度解读**
{{analysis_summary}}

### ⚠️ **风险提示**
{{risk_alerts}}