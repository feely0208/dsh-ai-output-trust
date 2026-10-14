# @deepwhale-cn/dsh-ai-output-trust

[![Listed on dsh-plugin.org](https://dsh-plugin.org/badges/listed.svg)](https://dsh-plugin.org/plugins/feely0208/dsh-ai-output-trust)


**关键词**：AI 输出 · AI 安全 · 提示注入 · 提示词注入 · 大模型安全 · 任意代码执行 · LLM 安全 · 大模型
**Keywords**: AI output trust · prompt injection · LLM security · code execution · OWASP LLM
**AI 输出信任边界** —— 检查代码有没有直接执行 AI 输出。

## 不装它会怎样

你的 agent 里有这么一行：

```js
eval(aiResponse);
```

想法是「让模型生成一小段脚本，我执行它」。

**但 AI 输出是不可信输入** —— 它可能被提示注入控制，也可能自己发挥。
你等于把**任意代码执行权交给了一个概率模型**。

OWASP 把这单列为 **LLM05 Improper Output Handling**。

## 它查什么

| 级别 | 内容 |
|---|---|
| 🔴 严重 | `eval(aiResponse)` / `new Function(...)` |
| 🔴 严重 | AI 输出拼进 `exec` / `spawn` |
| 🟠 高 | AI 输出拼进 SQL |
| 🟠 高 | 文件路径来自 AI 输出（路径穿越）|

## 它不会误报「只是调了模型」

变量识别用**精确命名**，不是「看到 `.content` 就报」。

**这段不报**（调了模型，但当成不可信输入处理）：
```js
const raw = result.choices[0].message.content;
const parsed = safeJsonParse(raw);
if (!schema.validate(parsed)) throw new Error('invalid');
```

**这段报**：
```js
eval(aiResponse);
```

## 正确的做法

```
AI 输出 → 结构化解析 → Schema 校验 → 白名单分支
        → 参数化查询
        → 路径规范化 + 断言在允许根目录内
```

## 安装

```bash
dsh plugin --profile web add @deepwhale-cn/dsh-ai-output-trust
# 或纯 CLI
npx @deepwhale-cn/dsh-ai-output-trust
```

## 用法

```bash
dsh-ai-output-trust --demo          # 看检出效果
dsh-ai-output-trust --list-rules    # 列出规则和依据
dsh-ai-output-trust --html r.html
```

![dsh-ai-output-trust 检查报告示例](https://www.deepwhale.org.cn/plugin-assets/dsh-ai-output-trust/report.png)

![dsh-ai-output-trust 演示模式输出](https://www.deepwhale.org.cn/plugin-assets/dsh-ai-output-trust/demo.png)

![dsh-ai-output-trust 规则与依据](https://www.deepwhale.org.cn/plugin-assets/dsh-ai-output-trust/rules.png)

## 边界

- **只查四种明确的高危用法**（eval / shell / SQL / 路径）。其它「间接信任」不在范围。
- **靠变量命名识别** —— 建议统一命名（`ai*` / `llm*` / `model*`），否则会漏。
- **不做数据流分析**，只看调用点附近。
- 与 [dsh-ci-guard](https://github.com/feely0208/dsh-ci-guard) 分工：那个查 GitHub Actions 脚本注入，这个查运行时。

本插件是一个工具。使用者必须遵守所在地区法律法规，**对使用本项目造成的任何后果自行承担责任。**


---

## 深鲸网安守护系列（共 22 个）

> 一个插件做一件事。**安全问题是链式的** —— 配套用才完整。

**国内合规** ｜ [等保对照](https://github.com/feely0208/dsh-cn-mlps) · [日志留存](https://github.com/feely0208/dsh-cn-log-retention) · [备案公示](https://github.com/feely0208/dsh-cn-filing) · [用户同意](https://github.com/feely0208/dsh-consent-guard) · [个人信息权利](https://github.com/feely0208/dsh-data-rights) · [未成年人保护](https://github.com/feely0208/dsh-minor-guard) · [影响评估](https://github.com/feely0208/dsh-pipia) · [数据分类分级](https://github.com/feely0208/dsh-data-classify) · [算法备案](https://github.com/feely0208/dsh-algorithm-filing) · [数据出境](https://github.com/feely0208/dsh-cn-data-export)

**AI 与 Agent 治理** ｜ [**AI 输出信任**](https://github.com/feely0208/dsh-ai-output-trust) · [外部内容信任](https://github.com/feely0208/dsh-content-trust) · [MCP 安全](https://github.com/feely0208/dsh-mcp-audit) · [Agent 权限](https://github.com/feely0208/dsh-agent-scope)

**数据与凭据** ｜ [敏感数据](https://github.com/feely0208/dsh-data-scan) · [密钥轮换](https://github.com/feely0208/dsh-key-rotate)

**供应链与构建** ｜ [开源许可](https://github.com/feely0208/dsh-license-guard) · [依赖投毒](https://github.com/feely0208/dsh-dep-audit) · [CI 安全](https://github.com/feely0208/dsh-ci-guard)

**权限与应急** ｜ [最小权限](https://github.com/feely0208/dsh-least-privilege) · [告警外发](https://github.com/feely0208/dsh-alert-relay) · [应急证据包](https://github.com/feely0208/dsh-incident-package)

都在 DSH 插件市场（dsh-plugin.org）和 npm 上，`dsh plugin --profile web add <包名>` 即可安装。

## License

MIT © 深鲸 DeepWhale
