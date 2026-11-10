const fs=require('fs'),assert=require('assert');
const source=fs.readFileSync('src/loading/LoadingMenu.as','utf8');
const start=source.indexOf('var lifetimeCatalog:Array',source.indexOf('private function LSCDrawExtras'));
const end=source.indexOf('groups = groups.concat(lifetimeGroups);',start);
const body=source.slice(start,end).replace(/var (\w+):\w+/g,'let $1').replace(/\bint\(/g,'Math.trunc(');
Array.NUMERIC=16;Array.prototype.sortOn=function(key){return this.sort((a,b)=>a[key]-b[key]);};
const run=new Function('snapshot','with(this){'+body+'return {catalog:lifetimeCatalog,pages:lifetimeGroups};}');
const snapshot=Object.fromEntries(Array.from({length:67},(_,i)=>['stat_counter_'+i,String(i)]));
const ctx={LSCLifetimeSeed:123,LSCOptions:{page_count:5,hide_zero:0,lifetime_mode:0,lifetime_general:0,lifetime_combat:112},LSCIsZeroStat:v=>Number(v)===0};
let result=run.call(ctx,snapshot);assert.equal(result.catalog.length,67);assert.equal(result.pages.length,5);assert(result.pages.every(p=>p.items.length===4));
const first=result.pages.flatMap(p=>p.items.map(i=>i.label));assert.equal(new Set(first).size,20);
ctx.LSCOptions.hide_zero=1;const onlyTwo=Object.fromEntries(Object.entries(snapshot).map(([k])=>[k,'0']));onlyTwo.stat_counter_12='3';onlyTwo.stat_counter_66='4';
result=run.call(ctx,onlyTwo);assert.equal(result.pages.length,1);assert.equal(result.pages[0].items.length,2);assert(result.pages[0].items.every(i=>i.value!=='0'));
onlyTwo.stat_counter_12=onlyTwo.stat_counter_66='0';assert.equal(run.call(ctx,onlyTwo).pages.length,0);
ctx.LSCLifetimeSeed=987;ctx.LSCOptions.hide_zero=0;assert.notDeepEqual(run.call(ctx,snapshot).pages.flatMap(p=>p.items.map(i=>i.label)),first);
for(const file of ['src/settings-catalog.json','src/osf/loading-screen-configurator.json']){
 const text=fs.readFileSync(file,'utf8');assert(!/"lifetime_(mode|general|combat|exploration|crafting|quests|ship|crime)"/.test(text));assert(text.includes('hide_zero'));
}
console.log('Passed: all 67 counters remain eligible despite legacy restrictions; random pages stay unique, honor page limits, filter zeros and omit empty pages. Removed selectors absent.');

const gateLine=source.slice(source.indexOf('private function LSCDrawExtras')).split('\n').find(l=>l.trim().startsWith('if('));
const gate=new Function('snapshot','return '+gateLine.trim().slice(3,-1).replace(/\bint\(/g,'Math.trunc(')+';');
const current={ready:true,character:'Test'};ctx.LSCLastName='Test';
ctx.LSCOptions.lifetime_enabled=0;assert.equal(gate.call(ctx,current),false);
ctx.LSCOptions.lifetime_enabled=1;assert.equal(gate.call(ctx,current),true);
delete ctx.LSCOptions.lifetime_enabled;assert.equal(gate.call(ctx,current),true);
