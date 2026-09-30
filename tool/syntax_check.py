"""Dev helper: parse every Dart file with tree-sitter and report syntax errors."""
import sys, pathlib
from tree_sitter_language_pack import get_parser
p = get_parser('dart')
bad = 0
for f in sorted(pathlib.Path('.').glob('**/*.dart')):
    if 'app_localizations' in f.name: continue
    src = f.read_bytes(); tree = p.parse(src)
    errs = []
    def walk(n):
        if n.type == 'ERROR' or n.is_missing:
            errs.append(n)
        for c in n.children: walk(c)
    walk(tree.root_node)
    if errs:
        bad += 1
        for e in errs[:4]:
            line = e.start_point[0]+1
            print(f"{f}:{line}: {'MISSING '+e.type if e.is_missing else 'ERROR'}: {src.splitlines()[line-1].decode()[:120].strip()}")
print('files with errors:', bad)
