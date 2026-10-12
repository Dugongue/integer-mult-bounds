#include <array>
#include <vector>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <set>
using namespace std;
const int P=1000003;using Vec=array<int,120>;
long long pw(long long a,int n){long long b=1;for(;n;n>>=1,a=a*a%P)if(n&1)b=b*a%P;return b;}
struct Row{int group;array<bool,512> span{};Vec col{};};
struct Basis{array<Vec,120>b{};vector<int>donors,pivots;bool add(Vec v){for(int t=0;t<120;t++)if(v[t]){if(b[t][t]){int a=v[t];for(int j=t;j<120;j++)v[j]=(v[j]-(long long)a*b[t][j]%P+P)%P;}else{auto q=pw(v[t],P-2);for(int j=t;j<120;j++)b[t][j]=v[j]*q%P;return true;}}return false;}};
int main(int argc,char**argv){ifstream in(argv[1]);vector<Row>a(560);for(int z=0;z<560;z++){int h,g,n;in>>h>>g>>n;a[h].group=g;while(n--){int x;in>>x;a[h].span[x]=true;}in>>n;while(n--){int t,u,d;in>>t>>u>>d;a[h].col[t]=((u%P+P)%P)*pw(d,P-2)%P;}}
int best=0;for(int e=1;e<512;e++){vector<int>ids;for(int h=0;h<560;h++)if(a[h].group==-1&&a[h].span[e])ids.push_back(h);Basis b;for(int h:ids){if(b.add(a[h].col))b.donors.push_back(h);else b.pivots.push_back(h);}if(!b.pivots.empty()){cout<<"unused "<<e<<" "<<b.donors.size()<<" "<<b.pivots.size()<<" D";for(int h:b.donors)cout<<" "<<h;cout<<" P";for(int h:b.pivots)cout<<" "<<h;cout<<"\n";best=max(best,(int)b.pivots.size());}}
// Merging two classes can reduce donor rank only if every participant shares a legal entrance.
for(int c=0;c<11;c++)for(int d=c+1;d<11;d++){vector<int>ids;for(int h=0;h<560;h++)if(a[h].group==c||a[h].group==d)ids.push_back(h);for(int e=1;e<512;e++){if(!all_of(ids.begin(),ids.end(),[&](int h){return a[h].span[e];}))continue;Basis b;for(int h:ids)if(b.add(a[h].col))b.donors.push_back(h);else b.pivots.push_back(h);cout<<"merge "<<c<<" "<<d<<" "<<e<<" "<<b.donors.size()<<" "<<b.pivots.size()<<"\n";}}
cerr<<"best unused nullity "<<best<<"\n";
}
