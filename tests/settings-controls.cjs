const fs=require('fs'),assert=require('assert');
const source=fs.readFileSync('src/gameplay/Shared/Components/SystemPanels/SettingsPanel.as','utf8');
const definitions=JSON.parse(fs.readFileSync('src/settings-catalog.json','utf8'));
function get(name){let start=source.indexOf('private function '+name+'('),a=source.indexOf('{',start),i=a+1,depth=1;while(depth){if(source[i]==='{')depth++;if(source[i]==='}')depth--;i++;}let body=source.slice(a+1,i-1).replace(/var (\w+):\w+/g,'let $1').replace(/ as Function/g,'').replace(/ is Function/g,' instanceof Function').replace(/\bint\(/g,'Math.trunc(').replace(/\buint\(/g,'uint(');return new Function('vanilla','event','uint',body);}
const values=Object.fromEntries(definitions.map(d=>[d.key,d.default]));
const api=(command,key,value)=>{if(command==='set'){const d=definitions.find(d=>d.key===key);if(!d||!d.values.includes(value))return {ok:false};values[key]=value;}return {ok:true,...values};};
const host={parent:null,TRConfig:api};
const panel={parent:host,TRDefinitions:definitions,TRVanillaRows:[],SetPromptText(message){this.error=message;}};
const bridge=get('TRBridge'),build=get('TRBuildRows'),change=get('TRSettingChange');
const uint=x=>Number(x)>>>0;
panel.TRBridge=()=>bridge.call(panel,null,null,uint);
panel.TRBuildRows=rows=>build.call(panel,rows,null,uint);
const original=[{uID:7,sText:'Existing Gameplay option'}];
let rows=panel.TRBuildRows(original);
assert.equal(original.length,1,'Do not mutate engine data');assert.equal(rows.length,definitions.length+2,'Header plus all settings');
assert.equal(rows[1].sText,'TRANSIT REPORT');
for(let i=0;i<definitions.length;i++){const d=definitions[i],entry=rows[i+2];assert.equal(entry.uCategory,0);assert.equal(entry.bIsPEO,false);assert.equal(entry.stepperData.uIndex,d.values.indexOf(d.default));}
panel.PEOList_mc={selectedIndex:0,selectedEntry:rows[0],InitializeEntries(newRows){this.rows=newRows;}};
assert.equal(change.call(panel,null,{params:{id:7,value:1}},uint),false,'Leave native changes to engine handler');
for(let i=0;i<definitions.length;i++){
 const d=definitions[i],entry=rows[i+2];panel.PEOList_mc.selectedEntry=entry;panel.PEOList_mc.selectedIndex=i+2;
 const choice=d.values.length-1;assert.equal(change.call(panel,null,{params:{id:entry.uID,value:choice}},uint),true);
 assert.equal(values[d.key],d.values[choice],'Persist encoded value, not dropdown index: '+d.key);
}
assert(!panel.error);assert.equal(new Set(rows.map(r=>r.uID)).size,rows.length);
delete host.TRConfig;assert.deepEqual(panel.TRBuildRows(original),original,'Missing native bridge must leave vanilla UI alone');
console.log('Passed: Gameplay controls, native option preservation, default mapping, all choice encodings, unique row IDs and graceful missing-bridge behavior.');
