# AI 输出信任边界

检查代码有没有**直接执行 AI 输出** —— eval / shell / SQL / 文件路径。

## 一、为什么这是 agent 最危险的一类问题

**AI 输出是不可信输入。**

它与「用户输入」不同的地方在于：用户输入至少是人打的，而 AI 输出**可以被提示注入控制**，
也可能自己「发挥」出一段你没预期的东西。

OWASP 把它单列为 **LLM05 Improper Output Handling** —— 未校验的模型输出进入下游组件，
**可导致远程代码执行**。

## 二、它查什么

| 级别 | 项 | 后果 |
|---|---|---|
| 🔴 **严重** | `eval(aiResponse)` / `new Function(...)` | 任意代码执行 |
| 🔴 **严重** | 把 AI 输出拼进 `exec` / `spawn` | 命令注入 |
| 🟠 高 | 把 AI 输出拼进 SQL | 越权查询 / 删库 |
| 🟠 高 | 文件路径来自 AI 输出 | 路径穿越 `../../` |

## 三、它**不会**误报「只是调了模型」

变量识别用的是**精确命名**（`aiResponse` / `llmOutput` / `modelOutput` …），
不是「看到 `.content` 就报」。

所以这段**不会**报：
```js
const raw = result.choices[0].message.content;
const parsed = safeJsonParse(raw);
if (!schema.validate(parsed)) throw new Error('invalid');
```
（调了模型、也读了输出，但**当成了不可信输入处理**）

而这段**会**报：
```js
eval(aiResponse);
```

## 四、正确的做法

```
AI 输出 → 解析成结构化数据 → Schema 校验 → 白名单分支
        → 参数化查询（不要拼字符串）
        → 路径规范化 + 断言仍在允许根目录内
```

## 五、怎么用

```bash
<cli 路径> --demo          # 看检出效果
<cli 路径> --list-rules    # 列出规则和依据
<cli 路径> --html r.html
```

**退出码 1 = 有 critical/high 命中**。

## 六、边界

- **只查四种明确的高危用法**（eval / shell / SQL / 路径）。
  其它「间接信任」—— 比如把 AI 输出当成配置项、日志级别、URL —— **不在范围内**。
- **靠变量命名识别**：如果你们的代码里 AI 输出变量不叫这些名字（如叫 `x`），会漏。
  建议统一命名（`ai*` / `llm*` / `model*`），这本身也是好习惯。
- **不做数据流分析**：不做跨函数追踪，只看调用点附近。
- 与 `dsh-ci-guard` 分工：那个查 GitHub Actions 的脚本注入；
  这个查**运行时**代码把模型输出当可信输入。

## 七、覆盖面

4 类高危用法。依据 OWASP Top 10 for LLM Applications · LLM05。
