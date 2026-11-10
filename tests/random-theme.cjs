const fs=require('fs'),assert=require('assert');
for(const name of ['LoadingMenu','FaderMenu']){
 const s=fs.readFileSync('src/loading/'+name+'.as','utf8');const a=s.indexOf('private function TRArtMode('),start=s.indexOf('{',a);let end=start+1,depth=1;
 while(depth){if(s[end]==='{')depth++;if(s[end]==='}')depth--;end++;}
 const body=s.slice(start+1,end-1).replace(/var (\w+):\w+/g,'let $1').replace(/\bint\(/g,'Math.trunc(');
 let calls=0;const math={...Math,random(){calls++;return .6;},trunc:Math.trunc};const resolve=new Function('index','Math',body);
 const ctx={TRArtWasFullActive:true,TRArtRandomTheme:-1,LSCOptions:{badge:107,spinner:107,background:107}};
 assert.equal(resolve.call(ctx,0,math),104);for(let i=0;i<30;i++)for(let k=0;k<3;k++)assert.equal(resolve.call(ctx,k,math),104);assert.equal(calls,1);
 ctx.LSCOptions.spinner=2;assert.equal(resolve.call(ctx,1,math),2);ctx.LSCOptions.badge=0;assert.equal(resolve.call(ctx,0,math),0);assert.equal(calls,1);
 ctx.TRArtRandomTheme=-1;assert.equal(resolve.call(ctx,2,math),104);assert.equal(calls,2);
 assert(s.includes('if(active && !this.TRArtWasFullActive)'));assert(s.includes('spinner.alpha > 0.01'));
}
console.log('Passed: one random faction shared across slots, stable polling, independent Hidden/Original, and new-load reroll.');
