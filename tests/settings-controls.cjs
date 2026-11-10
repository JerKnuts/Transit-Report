const fs=require('fs'),assert=require('assert');
const source=fs.readFileSync('src/gameplay/Shared/Components/SystemPanels/SettingsPanel.as','utf8');
const definitions=JSON.parse(fs.readFileSync('src/settings-catalog.json','utf8'));
function get(name){let start=source.indexOf('private function '+name+'('),a=source.indexOf('{',start),i=a+1,depth=1;while(depth){if(source[i]==='{')depth++;if(source[i]==='}')depth--;i++;}let body=source.slice(a+1,i-1).replace(/var (\w+):\w+/g,'let $1').replace(/ as Function/g,'').replace(/ is Function/g,' instanceof Function').replace(/\bint\(/g,'Math.trunc(').replace(/\buint\(/g,'uint(');return new Function('vanilla','event','uint',body);}
const values=Object.fromEntries(definitions.map(d=>[d.key,d.default]));
const api=(command,key,value)=>{if(command==='set'){const d=definitions.find(d=>d.key===key);if(!d||!d.values.includes(value))return {ok:false};values[key]=value;}return {ok:true,...values};};
const host={parent:null,TRConfig:api};
const panel={TRConfig:api,parent:host,TRDefinitions:definitions,TRVanillaRows:[],SetPromptText(message){this.error=message;}};
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
delete panel.TRConfig;assert.deepEqual(panel.TRBuildRows(original),original,'Missing native bridge must leave vanilla UI alone');
console.log('Passed: Gameplay controls, native option preservation, default mapping, all choice encodings, unique row IDs and graceful missing-bridge behavior.');

assert(source.includes('public var TRConfig:Function;'),'Panel owns its settings connection');
assert(!bridge.toString().includes('host.parent'),'No menu-root connection required');
const marker=source.indexOf('public function TRRefreshSettings('),begin=source.indexOf('{',marker);let finish=begin+1,nesting=1;
while(nesting){if(source[finish]==='{')nesting++;if(source[finish]==='}')nesting--;finish++;}
const refresh=new Function(source.slice(begin+1,finish-1).replace(/var (\w+):\w+/g,'let $1'));
panel.TRConfig=api;panel.TRVanillaRows=original;panel.PEOList_mc.selectedIndex=3;refresh.call(panel);assert.equal(panel.PEOList_mc.selectedIndex,3);assert.equal(panel.PEOList_mc.rows.length,definitions.length+2);
panel.TRVanillaRows=[];panel.PEOList_mc.InitializeEntries=()=>{throw Error('Do not refresh before engine data exists');};refresh.call(panel);
console.log('Passed: panel-owned connection and late-binding refresh preserve selection; missing data is left alone.');

const poll=get('TRBridgeFrame');let refreshCalls=0,removed=false;
const polling={visible:true,TRConfig:null,TRVanillaRows:[{}],TRRefreshSettings(){refreshCalls++;},removeEventListener(){removed=true;}};
// The adapter's event parameter is unused; expose the Event constant used for cleanup.
global.Event={ENTER_FRAME:'enterFrame'};
poll.call(polling);assert.equal(refreshCalls,0);
polling.TRConfig=api;polling.visible=false;poll.call(polling);assert.equal(refreshCalls,0);
polling.visible=true;poll.call(polling);assert.equal(refreshCalls,1);assert(removed);
const native=fs.readFileSync('native/src/GameplaySettings.inl','utf8').split('void BindGameplayBridge')[1];
assert(native.includes('SetVarType::kPermanent'));assert(!native.includes('.Invoke('));assert(!native.includes('.GetMember('));assert(!native.includes('GetVariable('));
console.log('Passed: readiness refresh waits for visible panel and native connection; constructor binding performs no panel lookup or AS invocation.');
