// 合规：AI 输出先当不可信输入处理
const result = await callModel(prompt);
const raw = result.choices[0].message.content;

// 1) 解析成结构化数据并校验
const parsed = safeJsonParse(raw);
if (!schema.validate(parsed)) throw new Error('invalid model output');

// 2) 只走白名单分支
const ALLOWED = new Set(['list', 'count']);
if (!ALLOWED.has(parsed.action)) throw new Error('action not allowed');

// 3) 参数化查询 + 路径断言
db.query('SELECT * FROM users WHERE id = ?', [Number(parsed.id)]);
const target = path.resolve(SAFE_ROOT, path.basename(parsed.file));
if (!target.startsWith(SAFE_ROOT)) throw new Error('path escape');
fs.writeFileSync(target, data);
