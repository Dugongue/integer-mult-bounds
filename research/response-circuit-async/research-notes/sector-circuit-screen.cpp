#include <array>
#include <vector>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <numeric>
#include <cmath>
#include <map>
using namespace std;const int P=1000003;using Vec=array<int,120>;
long long pw(long long a,int n){long long b=1;for(;n;n>>=1,a=a*a%P)if(n&1)b=b*a%P;return b;}
struct Row{int group,f;array<bool,512>span{};Vec col{};};
struct DS{array<int,560>p;DS(){iota(p.begin(),p.end(),0);}int get(int x){return p[x]==x?x:p[x]=get(p[x]);}void link(int a,int b){p[get(a)]=get(b);}};
struct Comp{int e;vector<int>d,p;double score;};
double ent(int r){return r?r*log(73.0/r):0;}
vector<Comp>components(const vector<Row>&a,const vector<int>&ids,int e){array<Vec,120>b{};array<array<int,560>,120>cf{};DS ds;vector<int>dd,pp;for(int h:ids){Vec v=a[h].col;array<int,560>c{};c[h]=1;bool indep=false;for(int t=0;t<120;t++)if(v[t]){if(b[t][t]){int z=v[t];for(int j=t;j<120;j++)v[j]=(v[j]-(long long)z*b[t][j]%P+P)%P;for(int j:dd)c[j]=(c[j]-(long long)z*cf[t][j]%P+P)%P;}else{auto q=pw(v[t],P-2);for(int j=t;j<120;j++)b[t][j]=v[j]*q%P;for(int j:dd)cf[t][j]=c[j]*q%P;cf[t][h]=q;indep=true;break;}}if(indep)dd.push_back(h);else{pp.push_back(h);for(int j:dd)if(c[j])ds.link(h,j);}}
map<int,Comp>cs;for(int h:dd)cs[ds.get(h)].d.push_back(h);for(int h:pp)cs[ds.get(h)].p.push_back(h);vector<Comp>out;for(auto&[_,c]:cs)if(!c.p.empty()){c.e=e;c.score=c.d.size()*ent(1)+c.p.size()*2.4;for(int h:c.d)c.score+=ent(a[h].f-1)-ent(a[h].f);for(int h:c.p)c.score+=ent(a[h].f-1)-ent(a[h].f);out.push_back(c);}return out;}
int main(int argc,char**argv){ifstream in(argv[1]);vector<Row>a(560);for(int z=0;z<560;z++){int h,g,n;in>>h>>g>>n;a[h].group=g;a[h].f=round(log2(n));while(n--){int x;in>>x;a[h].span[x]=true;}in>>n;while(n--){int t,u,d;in>>t>>u>>d;a[h].col[t]=((u%P+P)%P)*pw(d,P-2)%P;}}
// Frozen original classes E and donor ranks.
int es[]={6,120,0,0,0,0,0,0,0,0,0},rk[11];ifstream meta(argv[2]);for(int i=0;i<11;i++)meta>>es[i]>>rk[i];double old[11]{};for(int c=0;c<11;c++){old[c]=rk[c]*ent(1);int n=0;for(auto&r:a)if(r.group==c){n++;old[c]+=ent(r.f-1)-ent(r.f);}old[c]+=(n-rk[c])*2.4;}
struct Win{double gain;int c,d;vector<Comp>cs;};vector<Win>wins;
for(int c=-1;c<11;c++)for(int d=c;d<11;d++){if(c==-1&&d!=-1)continue;vector<Comp>cs;for(int e=1;e<512;e++){vector<int>ids;for(int h=0;h<560;h++)if((a[h].group==-1||a[h].group==c||a[h].group==d)&&a[h].span[e])ids.push_back(h);if(ids.size()<2)continue;auto v=components(a,ids,e);for(auto&z:v)if(z.score<0)cs.push_back(z);}sort(cs.begin(),cs.end(),[](auto&x,auto&y){return x.score<y.score;});array<bool,560>used{};double score=0;vector<Comp>chosen;for(auto&z:cs){bool ok=true;for(int h:z.d)ok&=!used[h];for(int h:z.p)ok&=!used[h];if(ok){chosen.push_back(z);score+=z.score;for(int h:z.d)used[h]=true;for(int h:z.p)used[h]=true;}}double gain=(c<0?0:old[c]+(c==d?0:old[d]))-score;if(gain>1e-7)wins.push_back({gain,c,d,chosen});}
sort(wins.begin(),wins.end(),[](auto&x,auto&y){return x.gain>y.gain;});cout<<"[";for(int i=0;i<min(30,(int)wins.size());i++){auto&w=wins[i];if(i)cout<<",";cout<<"{\"gain\":"<<w.gain<<",\"remove\":["<<w.c;if(w.d!=w.c)cout<<","<<w.d;cout<<"],\"classes\":[";for(int j=0;j<w.cs.size();j++){auto&z=w.cs[j];if(j)cout<<",";cout<<"{\"E\":["<<z.e<<"],\"donors\":[";for(int k=0;k<z.d.size();k++){if(k)cout<<",";cout<<z.d[k];}cout<<"],\"pivots\":[";for(int k=0;k<z.p.size();k++){if(k)cout<<",";cout<<z.p[k];}cout<<"]}";}cout<<"]}";}cout<<"]\n";
}
