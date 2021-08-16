#!/usr/bin/env - python3
import sys
import re

hashes = []
for arg in sys.argv[1:]:
    m = re.search(r'[0-9a-z]+', arg)
    if m is not None:
        hashes.append(m.group(0))
if len(hashes) >= 2:
    print(' '.join(hashes))
else:
    print('__null__')

