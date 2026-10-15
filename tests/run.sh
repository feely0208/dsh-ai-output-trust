#!/bin/bash
set -uo pipefail
export PATH="/usr/local/bin:$PATH"
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }
echo ""; echo "  @deepwhale-cn/dsh-ai-output-trust · 双向验证"
echo "  ────────────────────────────────────────────────"
J=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --json 2>&1)
for rid in AIT-EVAL AIT-SHELL AIT-SQL AIT-FS; do
  c=$(echo "$J" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='$rid']))" 2>/dev/null)
  [ "${c:-0}" -gt 0 ] && ok "$rid 报出" || bad "$rid 未报出"
done
M=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${M:-1}" = "0" ] && ok "合规样本 0 命中（同样调模型但做了校验）" || bad "误报 ${M} 条"
echo ""; echo "  【能力验证】工具必须能区分「用了 AI 输出」和「信任 AI 输出」"
# 合规样本里也有 const raw = ...choices[0].message.content —— 变量名叫 raw 不是 aiResponse
K=$(echo "$J" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(len([f for f in d['findings'] if 'raw' in (f.get('evidence') or '')]))" 2>/dev/null)
[ "${K:-1}" = "0" ] && ok "未因「调用了模型」而误报" || bad "把模型调用本身当成问题了"
echo ""; echo "  【溯源】每条规则必须带 source"
python3 - <<'PY' && ok "全部规则均有 source" || bad "有规则缺 source"
import json,glob,sys
for f in glob.glob('rules/*.json'):
    r=json.load(open(f,encoding='utf-8'))
    if not r.get('source'): print('缺:',r.get('id'),file=sys.stderr); sys.exit(1)
PY
echo ""; echo "  ────────────────────────────────────────────────"
echo "  通过 $PASS · 失败 $FAIL"; echo ""
[ "$FAIL" -eq 0 ] || exit 1
