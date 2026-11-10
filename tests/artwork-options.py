from pathlib import Path
import json,re,sys
sys.path.insert(0,str(Path('scripts').resolve()))
from artwork_swf import read_swf
catalog=json.loads(Path('src/settings-catalog.json').read_text(encoding='utf-8'));schema=json.loads(Path('src/osf/loading-screen-configurator.json').read_text(encoding='utf-8'))
native=Path('native/src/LSCSettings.inl').read_text(encoding='utf-8');defs=Path('native/src/TRSettingsCatalog.inl').read_text(encoding='utf-8')
for key in ['badge','spinner','background']:
 d=next(d for d in catalog if d['key']==key);control=next(d for d in [item for group in schema['groups'].values() for item in group] if d['key']==key)
 assert d['labels'][-1]=='Custom';assert list(control['options'].values())==d['labels']
 allowed=list(map(int,re.search(r'\{"'+key+r'",\d+,\{([^}]*)',defs).group(1).split(',')));assert allowed==d['values']
 for option,value in zip(control['options'],d['values']):assert f'if(value=="{option}")next["{key}"]={value};' in native
for file in Path('assets/extra-artwork/runtime').glob('*.swf'):
 _,_,tags=read_swf(file);assert sum(code==1 for code,data in tags)==180;assert not any(code in (12,59,82) for code,data in tags)
assert len(list(Path('assets/extra-artwork/runtime').glob('*.swf')))==10
print('Passed: all backend enum values, Custom last, ten 180-frame script-free animated assets.')

for file in Path('assets/extra-artwork/runtime').glob('background-*.swf'):
 _,_,tags=read_swf(file)
 assert not any(code in (6,20,21,35,36,90) for code,data in tags),file.name
 assert any(code in (2,22,32,83) for code,data in tags)
print('Passed: all five new backgrounds contain vector shapes and no bitmap textures.')
