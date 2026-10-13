import { createPlugin, pkgRootFrom } from '@deepwhale-cn/dsh-guard-core/plugin';

export const { name, inject, apply } = createPlugin({
  name: 'ai-output-trust',
  pkgRoot: pkgRootFrom(import.meta.url),
  skillFile: 'skill/ai-output-trust.md',
  binFile: 'bin/cli.mjs',
  description: '检查代码有没有直接执行 AI 输出 —— eval/exec/SQL/文件路径，这是 agent 最危险的一类',
  whenToUse: 'TODO：写清什么时候该用（用户会说的话也列上）',
});
