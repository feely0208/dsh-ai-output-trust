// 违规：直接把 AI 输出当代码/命令/SQL/路径用
const result = await callModel(prompt);
const aiResponse = result.choices[0].message.content;

eval(aiResponse);
exec('ls ' + llmOutput);
db.query('SELECT * FROM users WHERE id = ' + aiOutput);
fs.writeFileSync(aiResponse, data);
