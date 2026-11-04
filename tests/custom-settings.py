from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
catalog={d['key']:d for d in json.loads((root/'src/settings-catalog.json').read_text(encoding='utf-8'))}
schema=json.loads((root/'src/osf/loading-screen-configurator.json').read_text(encoding='utf-8'))
controls={c['key']:c for group in schema['groups'].values() for c in group}
native=(root/'native/src/LSCSettings.inl').read_text(encoding='utf-8')
definitions=(root/'native/src/TRSettingsCatalog.inl').read_text(encoding='utf-8')
for key,value,option in [('badge',3,'folder'),('spinner',3,'folder'),('background',4,'custom')]:
    assert controls[key]['options'][option]=='Custom'
    d=catalog[key];assert d['labels'][d['values'].index(value)]=='Custom'
    assert f'if(value=="{option}")next["{key}"]={value};' in native
    allowed=re.search(r'\{"'+key+r'",\d+,\{([^}]*)\}',definitions).group(1)
    assert value in [int(v) for v in allowed.split(',')]
    expected=bool(d['default']) if d['kind']=='bool' else list(controls[key]['options'])[d['values'].index(d['default'])]
    assert controls[key]['default']==expected
for name in ['LoadingMenu.as','FaderMenu.as']:
    s=(root/'src/loading'/name).read_text(encoding='utf-8')
    assert 'TRArtInit()' in s and 'private function TRArtLoad(' in s
    assert 'TEST 3' not in s and 'PNG TEST' not in s and 'TRFolder' not in s
    assert 'this.LSCOptions.spinner = 1;' not in s
for key,value,option,label in [('badge',6,'jump-gate','Jump Gate'),('spinner',9,'signal-star','Signal Star'),('background',8,'survey-sweep','Survey Sweep')]:
    assert controls[key]['options'][option]==label
    d=catalog[key];assert d['labels'][d['values'].index(value)]==label
    assert f'if(value=="{option}")next["{key}"]={value};' in native
    allowed=re.search(r'\{"'+key+r'",\d+,\{([^}]*)\}',definitions).group(1)
    assert value in [int(v) for v in allowed.split(',')]
assert (root/'VERSION').read_text().strip()=='0.9.7'
print('Passed: Custom values/defaults match OSF, Gameplay/native and FOMOD catalog; clean production menu paths.')
