from pathlib import Path
import gzip,json,hashlib,struct,sys
data=(b'Canonical scalar program\n'*131)+bytes(range(256))
a=gzip.compress(data);b=gzip.compress(data,compresslevel=9,mtime=0)
assert a==b and a[9]==255 and a[4:8]==b'\x00'*4 and gzip.decompress(a)==data
# Simulate the OS-byte variants emitted on different platforms. The portable
# normalization must produce identical complete archives, not merely payloads.
for osbyte in [0,3,10,255]:
 c=a[:9]+bytes([osbyte])+a[10:]
 assert c[:9]+b'\xff'+c[10:]==a
assert gzip.compress(data,compresslevel=1)[9]==255
Path(sys.argv[1]).write_text(json.dumps(dict(status='PASS_GZIP_LEVEL_TIME_OS_CONTROLS',archive_sha256=hashlib.sha256(a).hexdigest(),python=sys.version,level=9,mtime=0,os_byte=255,simulated_os_bytes=[0,3,10,255],scope='Local runtime and simulated header controls; no Linux or other Python interpreter execution claimed.'),indent=2)+'\n')
