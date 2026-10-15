"""Fresh Lean kernel and transitive axiom audit, using only Mathlib build paths.

Pass --lean LEAN_EXE --mathlib MATHLIB_CHECKOUT --packages LAKE_PACKAGES
--out EXTERNAL_DIRECTORY. No personal project library is put in LEAN_PATH.
"""
from pathlib import Path
import argparse,hashlib,json,os,re,subprocess
HERE=Path(__file__).resolve().parent
ALLOWED={'propext','Classical.choice','Quot.sound'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def need(ok,msg):
    if not ok:raise ValueError(msg)
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--lean',type=Path,required=True);ap.add_argument('--mathlib',type=Path,required=True);ap.add_argument('--packages',type=Path);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    spec=json.loads((HERE/'EXPORTS.json').read_text());a.out.mkdir(parents=True,exist_ok=False)
    packages=a.packages or a.mathlib/'.lake/packages'
    libs=[a.mathlib/'.lake/build/lib/lean']+[p/'.lake/build/lib/lean' for p in packages.iterdir() if p.is_dir() and (p/'.lake/build/lib/lean').is_dir()]
    libs=list(dict.fromkeys(map(str,libs)));need(all(Path(p).is_dir() for p in libs),'compiled Mathlib and dependencies')
    env=dict(os.environ,LEAN_PATH=os.pathsep.join(libs))
    version=subprocess.check_output([str(a.lean),'--version'],text=True).strip()
    need('4.33.0' in version,'pinned Lean4.33.0')
    mathlib_revision=subprocess.check_output(['git','-C',str(a.mathlib),'rev-parse','HEAD'],text=True).strip()
    need(mathlib_revision==spec['mathlib_revision'],'exact pinned Mathlib revision')
    status=subprocess.check_output(['git','-C',str(a.mathlib),'status','--porcelain','--untracked-files=no'],text=True)
    need(not status.strip(),'unchanged tracked Mathlib sources')
    records=[]
    for filename,exports in spec['files'].items():
        source=HERE/filename;raw=source.read_bytes()
        imports=re.findall(r'^import\s+([^\s]+)',raw.decode(),re.M)
        need(all(x.startswith('Mathlib.') for x in imports),'only Mathlib imports')
        target=a.out/filename
        target.write_bytes(raw+b'\n'+''.join('#print axioms '+name+'\n' for name in exports).encode())
        run=subprocess.run([str(a.lean),str(target)],env=env,cwd=a.mathlib,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=240)
        log=run.stdout;need(run.returncode==0,filename+' Lean rejected: '+log[-5000:])
        parsed={}
        for name,body in re.findall(r"'([^']+)' depends on axioms:\s*\[([^]]*)\]",log,re.S):parsed[name]=[x.strip() for x in body.split(',') if x.strip()]
        for name in re.findall(r"'([^']+)' does not depend on any axioms",log):parsed[name]=[]
        need(set(exports)<=set(parsed),'every theorem has an actual axiom report')
        need(all(set(parsed[name])<=ALLOWED for name in exports),'unsupported axiom')
        need(source.read_bytes()==raw,'source changed during Lean check')
        (a.out/(filename+'.log')).write_text(log,encoding='utf-8')
        records.append(dict(source=filename,source_sha256=sha(source),kernel_exit_code=0,axioms={name:parsed[name] for name in exports},stdout_sha256=hashlib.sha256(log.encode()).hexdigest()))
    result=dict(status='PASS_FRESH_MATHLIB_ONLY_KERNEL_AND_AXIOM_AUDIT',lean_version=version,mathlib_revision=mathlib_revision,scope='These exact declarations only; no Python, whole supplier, fixed-tape implementation or outer multiplication formalization.',sources=records,exports=sum(len(v) for v in spec['files'].values()))
    (a.out/'KERNEL.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],result['exports'],'checked exports',flush=True)
if __name__=='__main__':main()
