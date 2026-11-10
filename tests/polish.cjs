const fs=require('fs'),assert=require('assert');
function body(source,name){const a=source.indexOf('private function '+name+'(');assert(a>=0);const start=source.indexOf('{',a);let end=start+1,depth=1;while(depth){if(source[end]==='{')depth++;if(source[end]==='}')depth--;end++;}return source.slice(start+1,end-1).replace(/var (\w+):\w+/g,'let $1').replace(/ as \w+/g,'').replace(/\bint\(/g,'Math.trunc(');}
const loading=fs.readFileSync('src/loading/LoadingMenu.as','utf8');
const zero=new Function('value',body(loading,'LSCIsZeroStat'));
for(const value of ['0','0.0',' 0 ','0,000'])assert(zero(value));
for(const value of ['1','0.1','','Unavailable','12,345'])assert(!zero(value));
class Matrix{constructor(a,b,c,d,tx,ty){Object.assign(this,{a,b,c,d,tx,ty});}clone(){return new Matrix(this.a,this.b,this.c,this.d,this.tx,this.ty);}}
for(const name of ['LoadingMenu','FaderMenu']){
 const source=fs.readFileSync('src/loading/'+name+'.as','utf8');
 const resize=new Function('index','parent','Matrix',body(source,'TRArtResize'));
 const original=new Matrix(.8,.1,-.1,.8,250,400), bounds={x:-40,y:-50,width:80,height:100};
 const parent={transform:{matrix:original.clone()},getBounds(){return bounds;}};
 const ctx={TRArtSizeBases:[null,null],TRArtFind(){return null;},LSCOptions:{badge_size:150,indicator_size:75}};
 const center=m=>[m.tx,m.ty]; // Local center is (0,0); scaling must preserve its position.
 for(let i=0;i<100;i++)resize.call(ctx,0,parent,Matrix);
 assert(Math.abs(parent.transform.matrix.a-1.8)<1e-10);assert.deepEqual(center(parent.transform.matrix),center(original));
 ctx.LSCOptions.badge_size=50;resize.call(ctx,0,parent,Matrix);assert(Math.abs(parent.transform.matrix.a-.6)<1e-10);
 ctx.LSCOptions.badge_size=100;resize.call(ctx,0,parent,Matrix);assert(Math.abs(parent.transform.matrix.a-original.a*1.5)<1e-10);assert.deepEqual(center(parent.transform.matrix),center(original));
 const other={transform:{matrix:new Matrix(1,0,0,1,100,200)},getBounds(){return {x:0,y:0,width:100,height:100};}};
 resize.call(ctx,1,other,Matrix);assert.equal(other.transform.matrix.a,1.125);assert.equal(other.transform.matrix.tx+50*1.125,150);assert.equal(other.transform.matrix.ty+50*1.125,250);
 const resolve=new Function('index',body(source,'TRArtMode'));let calls=0;
 const theme={TRArtWasFullActive:true,TRArtRandomTheme:-1,LSCOptions:{badge:107,spinner:107,background:107},LSCNativePickArtwork(key,pool){calls++;assert.equal(key,'theme');assert.equal(pool.split('|').length,7);return '103';}};
 theme.TRArtWasFullActive=false;assert.equal(resolve.call(theme,0),-1);assert.equal(calls,0);theme.TRArtWasFullActive=true;
 for(let i=0;i<3;i++)assert.equal(resolve.call(theme,i),103);assert.equal(calls,1);
 const filename=new Function('index',body(source,'TRArtRandomFilename'));
 const art={TRArtSelected:[null],TRArtFiles:[['a.swf','b.swf']],LSCNativePickArtwork(key,pool){assert.equal(key,'artwork0');assert.equal(pool,'a.swf|b.swf');return 'b.swf';}};
 assert.equal(filename.call(art,0),'b.swf');art.LSCNativePickArtwork=()=>{throw Error('must stay cached during load');};assert.equal(filename.call(art,0),'b.swf');
}
console.log('Passed: zero-stat parsing, centered independent scaling without accumulation, Normal uses the enlarged baseline, and native random choice stays stable within a load.');
