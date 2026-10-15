"""Read-only complete finite conditional replay; Lean kernel check is separate."""
from pathlib import Path
import argparse,gzip,hashlib,json,os,shutil,subprocess,sys,tempfile
P=Path(__file__).resolve().parent
def need(ok,msg):
    if not ok:raise ValueError(msg)
def read(p):return json.loads(p.read_bytes())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def snapshot():return {p.relative_to(P).as_posix():sha(p) for p in P.rglob('*') if p.is_file()}
def cut_guard(word):
    v=word['report']['v'];centres=set(word['centers'])
    for g in word['cut']:
        need(isinstance(g,list) and len(g)>=3 and g[0]=='add','cut contains only ADDs')
        need(g[2] in centres and v<=g[1]<2*v,'cut requires centre source and target-row destination')
def replay(work,cache):
    before=snapshot();manifest=read(P/'MANIFEST.json')
    need(set(before)==set(manifest)|{'MANIFEST.json'} and all(before[k]==v for k,v in manifest.items()),'exact package manifest')
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PYTHONUTF8='1',PYTHONINTMAXSTRDIGITS='0',OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1');env.pop('PYTHONOPTIMIZE',None)
    def run(*args):subprocess.run([sys.executable,'-B',*map(str,args)],check=True,env=env)
    cut_controls=[]
    for case in ['base','extra']:
        word=json.loads(gzip.decompress((P/f'new/borrow/words/BORROW-WORD-43{case}.json.gz').read_bytes()))
        cut_guard(word)
        for field,value,label in [(2,0,'noncentre_source'),(1,0,'nontarget_destination')]:
            bad=json.loads(json.dumps(word));bad['cut'][0][field]=value
            try:cut_guard(bad)
            except ValueError:cut_controls.append(case+'_'+label)
            else:raise ValueError('cut mutation accepted')
    (work/'CUT-CONTROLS.json').write_text(json.dumps(dict(rejected=cut_controls),indent=2)+'\n')
    run(P/'ownership/replay_owner_delta.py','--source-fill',P/'provenance/PR2474-FILL.json.gz','--plan',P/'new/PLAN.json','--providers',P/'new/BORROW-PROVIDERS.json','--template',P/'GLOBAL-TEMPLATE.json.gz','--out',work/'owner-replay')
    need(gzip.decompress((work/'owner-replay/FILL.json.gz').read_bytes())==gzip.decompress((P/'new/borrow-fill/FILL.json.gz').read_bytes()),'independently reconstructed full fill')
    run(P/'ownership/test_owner_delta.py','--source-fill',P/'provenance/PR2474-FILL.json.gz','--plan',P/'new/PLAN.json','--providers',P/'new/BORROW-PROVIDERS.json','--template',P/'GLOBAL-TEMPLATE.json.gz','--work',work/'OWNER-CONTROLS')
    # The predecessor rewrites its timing-bearing local audit receipts. Keep its
    # full replay in a byte-identical external copy, preserving published files.
    working=work/'working-package';shutil.copytree(P,working)
    args=[working/'verify_release.py','--main',Path.cwd(),'--work',work/'release','--jobs','2']
    if cache:args+=['--native-cache',cache.resolve()]
    run(*args)
    strict=work/'release/verify/strict';owners=work/'release/verify/parent/layout/packing74/candidate/OWNERS.json.gz'
    need(sha(owners)==before['OWNERS.json.gz'],'admitted exact immutable owner archive')
    run(P/'hosted_owner_binding.py','--hosted',strict/'global/hosted/GLOBAL-TEMPLATE.json.gz','--owners',owners,'--assembly',strict/'ASSEMBLY.json','--out',work/'HOSTED-OWNER-BINDING.json')
    run(P/'ordinary_bootstrap.py','--out',work/'ORDINARY-BOOTSTRAP.json')
    release=read(work/'release/RELEASE-RECEIPT.json');supplier=read(work/'release/verify/RESULT.json');ordinary=read(work/'ORDINARY-BOOTSTRAP.json');link=read(work/'HOSTED-OWNER-BINDING.json');invoice=read(strict/'global/audit/PREFIX-AND-INVOICE.json')
    need(release['status']=='PASS_RELEASE' and supplier['status']=='PASS_T74_EXACT_FILL_COMPLETE_FINITE_ADMISSION','complete supplier and outer')
    need(link['status']=='PASS_HOSTED_OWNERS_CROSS_STAGE_BINDING' and link['roles']==285714 and len(link['mutations_rejected'])==2,'complete owner time/digest binding')
    need(snapshot()==before,'published source changed during replay')
    result=dict(status='PASS_COMPLETE_NEW_CONDITIONAL_KAPPA_PACKAGE',kappa_decimal=release['kappa_decimal'],source_manifest_sha256=before['MANIFEST.json'],roles=supplier['roles'],physical=invoice['physical'],row=supplier['physical_row_coefficient'],supplier_controls=supplier['controls'],ordinary_bootstrap_levels=ordinary['levels'],source_unchanged=True,hosted_owner_binding=True,hosted_owner_binding_controls=2,owner_cli_cases=15,cut_controls_rejected=4,scope='Complete finite conditional construction; inherited all-size/compiler/fixed-tape/precision/recovery/analytic premises remain explicit. Lean files certify only their displayed reusable theorems; fresh kernel replay is separate.')
    (work/'RESULT.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2),flush=True)
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path);ap.add_argument('--native-cache',type=Path);a=ap.parse_args()
    if a.out:
        need(not a.out.resolve().is_relative_to(P),'external output required');a.out.mkdir(parents=True,exist_ok=False);replay(a.out,a.native_cache)
    else:
        with tempfile.TemporaryDirectory(prefix='joint-owner-') as t:replay(Path(t),a.native_cache)
if __name__=='__main__':main()
