const fs=require('fs'),assert=require('assert');
for(const name of ['LoadingMenu','FaderMenu']){
 const source=fs.readFileSync('src/loading/'+name+'.as','utf8');
 const start=source.indexOf('private function LSCWalkArt('),a=source.indexOf('{',start);let i=a+1,depth=1;
 while(depth){if(source[i]==='{')depth++;if(source[i]==='}')depth--;i++;}
 const body=source.slice(a+1,i-1).replace(/var (\w+):\w+/g,'let $1').replace(/ as DisplayObjectContainer/g,'').replace(/ is DisplayObjectContainer/g,' instanceof DisplayObjectContainer');
 class Container{constructor(children=[]){this.children=children;}get numChildren(){return this.children.length;}getChildAt(i){return this.children[i];}}
 const walk=new Function('parent','mode','DisplayObjectContainer',body);
 const fallback={name:'LSCCustom_mc',visible:true},host={name:'loaded',visible:true};const parent=new Container([fallback,host]);
 const ctx={TRArtParents:[null,parent],TRArtHosts:[null,host],TRArtStates:[0,2]};ctx.LSCWalkArt=(p,m)=>walk.call(ctx,p,m,Container);
 ctx.LSCWalkArt(parent,1);assert.equal(fallback.visible,false);assert.equal(host.visible,true);
 const later={name:'LSCOriginal_mc',visible:true};parent.children.push(later);ctx.LSCWalkArt(parent,1);assert.equal(later.visible,false);
 host.visible=false;ctx.LSCWalkArt(parent,1);assert.equal(fallback.visible,true,'Restore fallback when replacement is inactive');
 assert(source.includes('if(key == "diagnostics")return false;'));
}
const catalog=JSON.parse(fs.readFileSync('src/settings-catalog.json','utf8'));
assert(!catalog.some(d=>d.key==='diagnostics'));
for(const key of ['badge','spinner','background'])assert.equal(catalog.find(d=>d.key===key).labels.at(-1),'Custom');
assert.equal(catalog.find(d=>d.key==='clock').group,'Full loading screen');
console.log('Passed: replacement remains exclusive across refreshes/new timeline children; fallback restores; clean settings order.');
