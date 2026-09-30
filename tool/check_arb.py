#!/usr/bin/env python3
"""Checks every ARB file against the English template: same keys, same placeholders, valid JSON."""
import json, re, sys, pathlib
d = pathlib.Path(__file__).resolve().parent.parent / 'lib' / 'l10n'
en = json.loads((d / 'app_en.arb').read_text(encoding='utf-8'))
keys = {k for k in en if not k.startswith('@')}
ph = re.compile(r'\{(\w+)\}')
ok = True
for f in sorted(d.glob('app_*.arb')):
    if f.name == 'app_en.arb':
        continue
    try:
        data = json.loads(f.read_text(encoding='utf-8'))
    except Exception as e:
        print(f'{f.name}: INVALID JSON: {e}'); ok = False; continue
    other = {k for k in data if not k.startswith('@')}
    missing, extra = keys - other, other - keys
    bad = [k for k in keys & other if set(ph.findall(en[k])) != set(ph.findall(data[k]))]
    empty = [k for k in other if isinstance(data[k], str) and not data[k].strip()]
    status = 'OK' if not (missing or extra or bad or empty) else 'FAIL'
    if status == 'FAIL': ok = False
    print(f'{f.name}: {status} ({len(other)} keys)' + (f' missing={sorted(missing)}' if missing else '') + (f' extra={sorted(extra)}' if extra else '') + (f' placeholders={bad}' if bad else '') + (f' empty={empty}' if empty else ''))
sys.exit(0 if ok else 1)
