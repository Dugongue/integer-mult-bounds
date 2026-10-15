# SPDX-License-Identifier: Apache-2.0
"""Replay and verify an authenticated whole-helper owner reallocation.

This is a finite ownership and billing checker, not native/compiler correctness.
It uses only the Python standard library and has no personal Lean dependencies.
"""
from pathlib import Path
import argparse,collections,gzip,hashlib,json

def need(ok,message):
    if not ok:raise ValueError(message)
def read(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw)if p.suffix=='.gz'else raw)
def context(plan,providers,template):
    """Exact mathematical owner interface, excluding regenerated receipt hashes."""
    return {'order':plan['order'],'windows':plan['windows'],'pairs':plan['pairs'],'sides':plan['sides'],
            'provider_calls':[{k:c[k]for k in('stage','replica','provider','time','orientation')}for c in plan['provider_calls']],
            'providers':{pid:{k:d[k]for k in('widths','actual_paid_profile')}for pid,d in providers.items()},
            'public_calls':[{'stage':c['stage'],'replica':c['replica'],'owners':c['owners'][:224]}for c in template['calls']]}
def context_hash(plan,providers,template):
    raw=json.dumps(context(plan,providers,template),sort_keys=True,separators=(',',':')).encode()
    return hashlib.sha256(raw).hexdigest()
def check(fill,plan,providers,template):
    order=plan['order'];widths={pid:d['widths']for pid,d in providers.items()}
    callprovider={(c['stage'],c['replica']):c['provider']for c in plan['provider_calls']}
    for s,r,pid in fill['dispatch_overrides']:callprovider[s,r]=pid
    windows=plan['windows'];calls={(c['stage'],c['replica']):c for c in template['calls']}
    need(len(calls)==len(order),'one literal parent call per order entry')
    data={sr:{z[0]for z in c['owners'][:224]}for sr,c in calls.items()}
    need(all(len(fs)==224 for fs in data.values()),'full 224-field data boundary')
    helpers=collections.defaultdict(set);families=collections.defaultdict(set);bins=collections.defaultdict(list)
    for row in fill['rows']:
        need(type(row)is list and len(row)==6 and all(type(z)is int for z in row),'six exact integer fields')
        t,h,r,c,v,off=row;need(0<=t<len(order),'time bounds');sr=tuple(order[t]);pid=callprovider[sr]
        need(0<=h<len(widths[pid])and h not in helpers[t],'whole helper uniqueness');helpers[t].add(h)
        need(f'{r},{c}'in windows and 0<=v<112,'pending child and port')
        cap,ts=windows[f'{r},{c}'];need(t in ts,'actual immutable pending window')
        family=r*896+(2*plan['pairs'][str(c)]+plan['sides'][str(c)])*112+v
        need(family not in data[sr]and family not in families[t],'inactive distinct physical family');families[t].add(family)
        width=widths[pid][h];need(type(width)is int and 0<width<=cap,'positive actual provider width')
        need(0<=off and off+width<=cap,'pending prefix range');bins[r,c,v].append((off,width))
    need(set(helpers)==set(range(len(order))),'all invocations represented')
    for t,sr in enumerate(order):need(helpers[t]==set(range(len(widths[callprovider[tuple(sr)]]))),'complete invocation role set')
    idle=collections.Counter()
    for key,(cap,ts)in windows.items():
        r,c=map(int,key.split(','))
        for v in range(112):
            at=0
            for off,width in sorted(bins[r,c,v]):need(off==at,'contiguous disjoint exact prefix');at+=width
            if cap>at:idle[cap-at]+=1
    profile=collections.Counter(idle)
    for sr in order:
        for rank,n in providers[callprovider[tuple(sr)]]['actual_paid_profile'].items():profile[int(rank)]+=n
    return dict(sorted(profile.items())),dict(sorted(idle.items()))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source-fill',type=Path,required=True);ap.add_argument('--plan',type=Path,required=True)
    ap.add_argument('--providers',type=Path,required=True);ap.add_argument('--template',type=Path,required=True)
    ap.add_argument('--delta',type=Path,default=Path(__file__).with_name('OWNER-DELTA98.json'))
    ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();need(not a.out.exists(),'output must be fresh')
    delta=read(a.delta);raw=gzip.decompress(a.source_fill.read_bytes())
    need(hashlib.sha256(raw).hexdigest()==delta['source']['json_payload_sha256'],'authenticated predecessor fill bytes')
    fill=json.loads(raw);need(fill['columns']==delta['columns']and fill['dispatch_overrides']==delta['unchanged_dispatch'],'source schema and unchanged dispatch')
    rows={tuple(z[:2]):z for z in fill['rows']};need(len(rows)==len(fill['rows'])==delta['roles'],'whole unique source roles')
    changed=set()
    for patch in delta['changes']:
        old,new=patch['old'],patch['new'];need(all(type(x)is int for x in old+new),'typed exact patch')
        k=tuple(old[:2]);need(k==tuple(new[:2])and k not in changed,'preserve helper/time identities')
        need(rows.get(k)==old,'exact old row precondition');rows[k][:]=new;changed.add(k)
    plan,providers,template=read(a.plan),read(a.providers),read(a.template)
    need(context_hash(plan,providers,template)==delta['owner_context_sha256'],'authenticated mathematical owner interface')
    profile,idle=check(fill,plan,providers,template)
    need(profile=={int(k):n for k,n in delta['expected_profile'].items()},'complete derived paid profile')
    need(idle=={int(k):n for k,n in delta['expected_idle'].items()},'complete derived idle profile')
    need(sum(r*n for r,n in profile.items())==delta['rank_mass'],'conserved full rank mass')
    raw=json.dumps(fill,separators=(',',':')).encode();need(hashlib.sha256(raw).hexdigest()==delta['generated_json_payload_sha256'],'exact successor payload')
    a.out.mkdir(parents=True);(a.out/'FILL.json.gz').write_bytes(gzip.compress(raw,mtime=0))
    (a.out/'RESULT.json').write_text(json.dumps({'status':'PASS_AUTHENTICATED_OWNER_REALLOCATION','roles':len(rows),'changed_rows':len(changed),'profile':profile,'idle':idle},indent=2)+'\n')
    print('PASS_AUTHENTICATED_OWNER_REALLOCATION',len(rows),'roles',len(changed),'changed rows')
if __name__=='__main__':main()
