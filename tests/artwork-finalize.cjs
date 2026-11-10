const fs=require('fs'),assert=require('assert');
for(const name of ['LoadingMenu','FaderMenu']){
 const source=fs.readFileSync('src/loading/'+name+'.as','utf8');
 const start=source.indexOf('private function TRArtFinalize('),a=source.indexOf('{',start);let i=a+1,depth=1;
 while(depth){if(source[i]==='{')depth++;if(source[i]==='}')depth--;i++;}
 const body=source.slice(a+1,i-1).replace(/var (\w+):\w+/g,'let $1').replace(/ as (Sprite|DisplayObjectContainer)/g,'').replace(/\bint\(/g,'Math.trunc(');
 const finalize=new Function('event',body);
 const original={visible:true},host={visible:true};const parent={children:[original,host],get numChildren(){return this.children.length;},getChildAt(i){return this.children[i];}};host.parent=parent;
 const ctx={TRArtDisposed:false,TRArtHosts:[null,host],TRArtParents:[null,parent],TRArtStates:[0,2],TRArtMode(index){return index===0?this.LSCOptions.badge:index===1?this.LSCOptions.spinner:this.LSCOptions.background;},LSCOptions:{badge:1,spinner:3}};
 finalize.call(ctx,null);assert.equal(original.visible,false);assert.equal(host.visible,true);
 original.visible=true;const recreated={visible:true};parent.children.push(recreated);finalize.call(ctx,null);assert.equal(original.visible,false);assert.equal(recreated.visible,false);
 ctx.LSCOptions.spinner=0;original.visible=true;finalize.call(ctx,null);assert.equal(original.visible,true,'Original mode remains untouched');
 for(const event of ['EXIT_FRAME','RENDER']){
 assert(source.includes('addEventListener(Event.'+event+',this.TRArtFinalize)'));
 assert(source.includes('removeEventListener(Event.'+event+',this.TRArtFinalize)'));
 }
}
console.log('Passed: post-timeline replacement exclusivity, recreated children, original mode, event cleanup in both menus.');
