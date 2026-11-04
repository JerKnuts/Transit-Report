const fs=require('fs'),assert=require('assert');
const source=fs.readFileSync('src/loading/CustomArtwork.as.inc','utf8');
function method(name,parameters){
 const start=source.indexOf('private function '+name+'(');assert(start>=0);const a=source.indexOf('{',start);let i=a+1,depth=1;
 while(depth){if(source[i]==='{')depth++;if(source[i]==='}')depth--;i++;}
 const body=source.slice(a+1,i-1).replace(/var (\w+):\w+/g,'let $1').replace(/function\(event:Event\):void/g,'function(event)').replace(/ as \w+/g,'').replace(/catch\((\w+):\w+\)/g,'catch($1)').replace(/\bint\(/g,'Math.trunc(');
 return new Function(...parameters,'with(this){'+body+'}');
}
const created=[];
class Loader{constructor(){this.events={};this.contentLoaderInfo={addEventListener:(key,callback)=>this.events[key]=callback};created.push(this);}load(request){this.url=request.url;}close(){this.closed=true;}}
class URLRequest{constructor(url){this.url=url;}}
const load=method('TRArtLoad',['index','useDefault','Loader','URLRequest','Event','IOErrorEvent','SecurityErrorEvent']);
const randomFilename=method('TRArtRandomFilename',['index']);
function model(){const m={TRArtDisposed:false,TRArtManifestReady:true,TRArtSelected:[null,null,null],TRArtFiles:[['badge-a.swf','badge-b.swf'],['indicator-a.swf','indicator-b.swf'],['wallpaper-a.swf','wallpaper-b.swf']],TRArtStates:[0,0,0],TRArtUsingDefaults:[false,false,false],TRArtLoaders:[null,null,null],TRArtContents:[null,null,null],TRArtWidths:[0,0,0],TRArtHeights:[0,0,0],TRArtRequested:[-1,-1,5],TRArtNames:['badge','indicator','wallpaper'],Math:{random:()=>.75,trunc:Math.trunc}};m.TRArtRandomFilename=function(i){return randomFilename.call(this,i)};return m;}
function invoke(m,index,builtin){load.call(m,index,builtin,Loader,URLRequest,{COMPLETE:'complete'},{IO_ERROR:'error'},{SECURITY_ERROR:'security'});return created.at(-1);}
for(const builtin of [false,true])for(let index=0;index<3;index++){
 const m=model(),loader=invoke(m,index,builtin);assert.equal(loader.url,`TransitReport/${builtin?'Defaults':'Cache'}/${m.TRArtNames[index]}${builtin?'':'-b'}.swf`);
 loader.content={width:256,height:256,getBounds(){return {width:256,height:256}}};loader.events.complete({});assert.equal(m.TRArtStates[index],2);assert.equal(m.TRArtUsingDefaults[index],builtin);
}
const m=model(),custom=invoke(m,0,false);const count=created.length;custom.events.error({});assert.equal(m.TRArtStates[0],-1);assert.equal(created.length,count,'Custom must not silently select a named preset');
const n=model(),stale=invoke(n,1,false);n.TRArtStates[1]=0;const current=invoke(n,1,true);stale.events.error({});assert.equal(n.TRArtStates[1],1,'Ignore late events from an old selection');
current.content={width:256,height:256,getBounds(){return {width:256,height:256}}};current.events.complete({});assert.equal(n.TRArtStates[1],2);
const stable=model();let rolls=0;stable.Math.random=()=>{rolls++;return .75};assert.equal(stable.TRArtRandomFilename(2),'wallpaper-b.swf');stable.Math.random=()=>{rolls++;return 0};assert.equal(stable.TRArtRandomFilename(2),'wallpaper-b.swf');assert.equal(rolls,1,'Keep selection stable within a load');
const empty=model();empty.TRArtFiles[2]=[];invoke(empty,2,false);assert.equal(empty.TRArtStates[2],-1);
console.log('Passed: separate Custom/preset paths, random choice/stability, empty pool, all slots, stale-event protection.');
const badgeSlugs=['wayfinder','jump-gate','eclipse','pathfinder','signal-star'];
const backgroundSlugs=['star-chart','deep-orbit','survey-sweep','constellation','solar-horizon'];
for(let i=0;i<5;i++){
 if(i==1 || i==4)for(const slot of [0,1]){const m=model();m.TRArtRequested[slot]=5+i;assert.equal(invoke(m,slot,true).url,`TransitReport/Defaults/badge-${badgeSlugs[i]}.swf`);}
 if(i==2){const m=model();m.TRArtRequested[2]=8;assert.equal(invoke(m,2,true).url,`TransitReport/Defaults/background-survey-sweep.swf`);}
}
console.log('Passed: retained badge/indicator designs and all five background asset paths.');

for(const index of [0,1,2]){
 const m=model();m.TRArtRequested[index]=100;const loader=invoke(m,index,true);
 assert.equal(loader.url,'TransitReport/Defaults/'+(index<2?'constellation-coin.swf':'constellation-wallpaper.swf'));
 loader.contentLoaderInfo.width=512;loader.contentLoaderInfo.height=512;
 loader.content={width:1100,height:1100,getBounds(){return {width:1100,height:1100}}};loader.events.complete({});
 assert.equal(m.TRArtWidths[index],512);assert.equal(m.TRArtHeights[index],512);
}
console.log('Passed: Constellation paired coin paths and stable authored frame dimensions.');

for(const index of [0,1,2]){
 const m=model();m.TRArtRequested[index]=101;const loader=invoke(m,index,true);
 assert.equal(loader.url,'TransitReport/Defaults/'+(index<2?'crimson-fleet-coin.swf':'crimson-fleet-wallpaper.swf'));
}
console.log('Passed: Crimson Fleet theme asset paths for all three slots.');

for(const index of [0,1,2]){
 const m=model();m.TRArtRequested[index]=102;const loader=invoke(m,index,true);
 assert.equal(loader.url,'TransitReport/Defaults/'+(index<2?'freestar-collective-coin.swf':'freestar-collective-wallpaper.swf'));
}
console.log('Passed: Freestar Collective theme asset paths.');

for(const index of [0,1,2]){const m=model();m.TRArtRequested[index]=103;const loader=invoke(m,index,true);assert.equal(loader.url,"TransitReport/Defaults/"+(index<2?"house-varuun-coin.swf":"house-varuun-wallpaper.swf"));}

for(const index of [0,1,2]){const m=model();m.TRArtRequested[index]=104;const loader=invoke(m,index,true);assert.equal(loader.url,"TransitReport/Defaults/"+(index<2?"ryujin-industries-coin.swf":"ryujin-industries-wallpaper.swf"));}

for(const index of [0,1,2]){const m=model();m.TRArtRequested[index]=105;const loader=invoke(m,index,true);assert.equal(loader.url,"TransitReport/Defaults/"+(index<2?"trackers-alliance-coin.swf":"trackers-alliance-wallpaper.swf"));}

for(const index of [0,1,2]){const m=model();m.TRArtRequested[index]=106;const loader=invoke(m,index,true);assert.equal(loader.url,"TransitReport/Defaults/"+(index<2?"united-colonies-coin.swf":"united-colonies-wallpaper.swf"));}
