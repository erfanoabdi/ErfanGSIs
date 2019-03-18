#!/usr/bin/env python3

# Used to fix system.img from Motorola firmware after using simg2img on the sparsechunk files
# by SuperR. @XDA

from __future__ import print_function
import sys, os, re, argparse

if int(''.join(str(i) for i in sys.version_info[0:2])) < 35:
	print('Python 3.5 or newer is required.')
	sys.exit(1)

def existf(filename):
	try:
		if os.path.isdir(filename):
			return 2
		if os.stat(filename).st_size > 0:
			return 0
		else:
			return 1
	except OSError:
		return 2

parser = argparse.ArgumentParser(description="Fix Motorola img files to be valid ext4.")
parser.add_argument("broken", help="Path to the broken.img")
parser.add_argument("fixed", help="Path to the new fixed.img")
args = parser.parse_args()

b = args.broken
n = args.fixed
    
if existf(b) != 0:
    print('\n'+b+' does not exist.\n')
    sys.exit()

with open(b, 'rb') as f:
    data = f.read(500000)

moto = re.search(b'\x4d\x4f\x54\x4f', data)
if not moto:
    print('\nThis does not appear to be a Motorola img\n')
    sys.exit()

result = []
for i in re.finditer(b'\x53\xEF', data):
    result.append(i.start() - 1080)

offset = 0
for i in result:
    if data[i] == 0:
        offset = i
        break        

if offset > 0:
    print('\nFixing '+b+' ...')
    with open(n, 'wb') as o, open(b, 'rb') as f:
        data = f.seek(offset)
        data = f.read(15360)
        while data:
            devnull = o.write(data)
            data = f.read(15360)

if existf(n) != 0:
    try:
        os.remove(n)
    except:
        pass
    print('\nERROR: '+b+' was not fixed\n')
else:
    print('\nSUCCESS: '+b+' was fixed\n')

sys.exit()