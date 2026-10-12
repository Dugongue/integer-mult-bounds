"""Rebuild the selected response-circuit decomposition from the frozen rank-sector base.
All data-dependent relations are re-solved over Q; no discovery solver is required.
"""
from pathlib import Path
from fractions import Fraction as Q
from collections import Counter
import sys,json,gzip,hashlib
if not __debug__:raise RuntimeError('Assertions must remain enabled')
code,base,selection,out=map(Path,sys.argv[1:]);assert not out.exists()
sys.path.insert(0,str(code));import gk_word as g
b=json.loads(gzip.decompress(base.read_bytes()));sel=json.loads(selection.read_text())
w=g.build(b,sel);profile=g.profile(w);widths=g.widths_of(w)
for part in ['A','B','cut','cleanup','precondition']:
 for e in w.get(part,[]):
  q=Q(e[3],e[4])if e[0]=='add'else Q(e[2],e[3]);n=abs(q.numerator);d=q.denominator
  assert not d&(d-1),(part,e)
  if e[0]=='scale':assert n>0 and not n&(n-1),(part,e)
out.mkdir(parents=True);(out/'FULL-WORD.json.gz').write_bytes(g.dump(w));(out/'RETIMED-BASE.json.gz').write_bytes(g.dump(b));(out/'SELECTION.json').write_text(json.dumps(sel,indent=2)+'\n')
r=dict(status='EXACT_RESPONSE_RELATIONS_FRAME_AND_DYADIC_GATE',pivots=sum(len(c['pivots'])for c in sel['kernel']),profile=dict(profile),widths=dict(Counter(widths)),ordered_widths=widths,source_sha256=hashlib.sha256(base.read_bytes()).hexdigest(),selection_sha256=hashlib.sha256(selection.read_bytes()).hexdigest(),scope='Local constructor only; independent full-column, physical, runtime invoice and outer replay follow.')
(out/'CONSTRUCTION.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'],r['pivots'])
