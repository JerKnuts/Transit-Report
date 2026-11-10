from pathlib import Path
import json,re,sys
sys.path.insert(0,'scripts');from artwork_swf import read_swf
catalog=json.loads(Path('src/settings-catalog.json').read_text(encoding='utf-8'));d=next(d for d in catalog if d['key']=='theme');assert d['values']==[0,1,2,3,4,5,6,7,8];assert d['labels']==['Individual selections','Constellation','Crimson Fleet','Freestar Collective',"House Va'ruun",'Ryujin Industries','Trackers Alliance','United Colonies','Random Each Load'];assert d['default']==0
schema=json.loads(Path('src/osf/loading-screen-configurator.json').read_text(encoding='utf-8'));s=next(d for d in [item for group in schema['groups'].values() for item in group] if d['key']=='theme');assert list(s['options'])==['individual','constellation','crimson-fleet','freestar-collective','house-varuun','ryujin-industries','trackers-alliance','united-colonies','random'];assert list(s['options'].values())==d['labels']
native=Path('native/src/LSCSettings.inl').read_text(encoding='utf-8');assert 'if(value=="crimson-fleet")next["theme"]=2;' in native
for theme in ['constellation','crimson-fleet','freestar-collective','house-varuun','ryujin-industries','trackers-alliance','united-colonies']:
 for suffix,frames in [('coin',180),('wallpaper',1)]:
  _,_,tags=read_swf(Path('assets/themes')/theme/(theme+'-'+suffix+'.swf'));assert sum(c==1 for c,d in tags)==frames;assert not any(c in (12,59,82) for c,d in tags)
print('Passed: theme labels/values/defaults across menus, native mapping, approved animated coins and static wallpapers.')
