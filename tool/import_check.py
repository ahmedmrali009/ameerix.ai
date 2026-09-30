"""Dev helper: for every top-level symbol defined in lib/, verify files that use it import its defining file."""
import re, pathlib, os
root = pathlib.Path('lib')
files = [f for f in root.glob('**/*.dart') if 'app_localizations' not in f.name]
defs = {}
decl = re.compile(r'^(?:abstract |sealed |final |base |mixin )*(?:class|enum|mixin|extension type|typedef)\s+([A-Z]\w*)|^(?:const|final)\s+(?:[\w<>?, ]+\s+)?([a-z]\w*)\s*=|^(?:[A-Z][\w<>?, ]*\s+)([a-z]\w*)\s*\(', re.M)
for f in files:
    for m in decl.finditer(f.read_text()):
        name = m.group(1) or m.group(2) or m.group(3)
        if name and not name.startswith('_') and name not in ('main','build'):
            defs.setdefault(name, set()).add(f.resolve())
defs['AppLocalizations'] = {(root/'l10n/app_localizations.dart').resolve()}
problems = 0
for f in files:
    src = f.read_text()
    code = re.sub(r"//.*|'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\"", '', src)
    imported = {f.resolve()}
    for imp in re.findall(r"import '([^']+)'", src):
        if imp.startswith('package:ameerix_web/'):
            imported.add((root / imp[len('package:ameerix_web/'):]).resolve())
        elif not imp.startswith(('package:', 'dart:')):
            imported.add((f.parent / imp).resolve())
    for name, where in defs.items():
        if re.search(r'(?<![\w.])' + re.escape(name) + r'\b', code) and not (where & imported):
            print(f'{f}: uses {name} without importing {[str(w.relative_to(pathlib.Path.cwd())) for w in where]}')
            problems += 1
print('problems:', problems)
