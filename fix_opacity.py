import os
import re

dirs = [
    r'c:\Users\loli\localboost\client\lib',
    r'c:\Users\loli\localboost\shared\lib',
    r'c:\Users\loli\localboost\merchant\lib',
]
count = 0
for d in dirs:
    for root, _, files in os.walk(d):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8') as fh:
                    content = fh.read()
                if '.withOpacity(' in content:
                    new = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
                    with open(path, 'w', encoding='utf-8') as fh:
                        fh.write(new)
                    count += 1
print(f'Patched {count} files')
