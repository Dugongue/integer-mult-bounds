# SPDX-License-Identifier: Apache-2.0
"""Behavioral public-CLI checks for the literal owner relocation certificate."""
from pathlib import Path
import argparse,copy,gzip,hashlib,json,subprocess,sys
def read(p):return json.loads(gzip.decompress(p.read_bytes())if p.suffix=='.gz'else p.read_bytes())
def write(p,x):p.write_text(json.dumps(x,separators=(',',':'))+'\n')
ap=argparse.ArgumentParser();ap.add_argument('--source-fill',type=Path,required=True);ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--providers',type=Path,required=True);ap.add_argument('--template',type=Path,required=True);ap.add_argument('--delta',type=Path,default=Path(__file__).with_name('OWNER-DELTA98.json'));ap.add_argument('--work',type=Path,required=True);a=ap.parse_args();a.work.mkdir(parents=True,exist_ok=False)
original=read(a.delta);source=read(a.source_fill);final=copy.deepcopy(source);lookup={tuple(z[:2]):z for z in final['rows']}
for c in original['changes']:lookup[tuple(c['old'][:2])][:]=c['new']
rows=final['rows'];tests=[]
def run(name,delta=None,plan=None,providers=None,template=None,sourcefill=None,expected=None,out=None):
    dp=a.work/(name+'.json');write(dp,original if delta is None else delta)
    target=a.work/(name+'-out')if out is None else out
    args=[sys.executable,'-I','-O','-B',str(Path(__file__).with_name('replay_owner_delta.py')),'--source-fill',str(sourcefill or a.source_fill),'--plan',str(plan or a.plan),'--providers',str(providers or a.providers),'--template',str(template or a.template),'--delta',str(dp),'--out',str(target)]
    r=subprocess.run(args,capture_output=True,text=True,timeout=45)
    if expected is None:
        if r.returncode:raise ValueError(name+': '+r.stderr)
    elif r.returncode==0 or expected not in r.stderr:raise ValueError(name+' wrong rejection: '+r.stdout+r.stderr)
    tests.append({'name':name,'accepted':r.returncode==0,'expected_guard':expected});print('PASS',name,flush=True)
run('honest')
for name,edit,guard in[
    ('old-row-precondition',lambda d:d['changes'][0]['old'].__setitem__(5,d['changes'][0]['old'][5]+1),'exact old row precondition'),
    ('repeated-patch',lambda d:d['changes'].append(copy.deepcopy(d['changes'][0])),'preserve helper/time identities'),
    ('changed-time',lambda d:d['changes'][0]['new'].__setitem__(0,d['changes'][0]['new'][0]+1),'preserve helper/time identities'),
    ('boolean-offset',lambda d:d['changes'][0]['new'].__setitem__(5,False),'typed exact patch'),
    ('missing-child',lambda d:d['changes'][0]['new'].__setitem__(3,99999),'pending child and port'),
    ('undercharged-profile',lambda d:d['expected_profile'].__setitem__('1',d['expected_profile']['1']-1),'complete derived paid profile'),
    ('wrong-mass',lambda d:d.__setitem__('rank_mass',d['rank_mass']-1),'conserved full rank mass')]:
    d=copy.deepcopy(original);edit(d);run(name,delta=d,expected=guard)
# A moved width-four role is appended after three width-nine occupants.
d=copy.deepcopy(original);c=next(c for c in d['changes']if c['new'][5]==27 and c['old'][2:5]!=c['new'][2:5]);c['new'][5]=0;run('overlapping-prefix',delta=d,expected='contiguous disjoint exact prefix')
d=copy.deepcopy(original);c=d['changes'][0];t,h=c['new'][:2];other=next(z for z in rows if z[0]==t and z[1]!=h);c['new'][2:]=other[2:];run('same-call-family-collision',delta=d,expected='inactive distinct physical family')
for name,origin,arg,mutate in[
    ('wrong-width',a.providers,'providers',lambda x:next(iter(x.values()))['widths'].__setitem__(0,99)),
    ('changed-window',a.plan,'plan',lambda x:next(iter(x['windows'].values()))[1].pop()),
    ('changed-public-data',a.template,'template',lambda x:x['calls'][0]['owners'][0].__setitem__(0,999999))]:
    x=read(origin);mutate(x);fp=a.work/(name+'-input.json');write(fp,x);run(name,**{arg:fp},expected='authenticated mathematical owner interface')
gz=a.work/'equivalent-source.gz';gz.write_bytes(gzip.compress(gzip.decompress(a.source_fill.read_bytes()),compresslevel=1,mtime=123456));run('gzip-reencoding',sourcefill=gz)
run('occupied-output',expected='output must be fresh',out=a.work/'honest-out')
result={'status':'PASS_OWNER_DELTA_PUBLIC_CLI_CONTROLS','scope':'Actual optimized public CLI, semantic malformed-ownership/source/context/profile controls and equivalent gzip. This does not rerun full native/global invoice/outer admission.','tests':tests,'source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in[Path(__file__),Path(__file__).with_name('replay_owner_delta.py'),a.delta]}}
write(a.work/'RESULT.json',result);print(result['status'],len(tests))
