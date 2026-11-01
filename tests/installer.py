from pathlib import Path
import configparser,json,sys
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root/'scripts'))
from configure_installer import configure
import re,tempfile,shutil
(root/'build').mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(dir=root/'build') as temp:
    installer=Path(temp)
    shutil.copytree(root/'installer/fomod',installer/'fomod')
    configure(installer,root/'src/settings-catalog.json')
    # Vortex removes encoding="..." (double quotes only) and re-parses the script as UTF-16.
    script=(installer/'fomod/ModuleConfig.xml').read_text(encoding='utf-8')
    assert re.match(r'<\?xml[^>]*encoding="[^"]+"',script),'ModuleConfig declaration must use double quotes for Vortex'
    ET.fromstring(re.sub(r'^([^>]*)encoding="[^"]+"',r'\1',script))
    (installer/'fomod/info.xml').read_bytes().decode('utf-8')
    ET.parse(installer/'fomod/info.xml')
    xml=ET.parse(installer/'fomod/ModuleConfig.xml').getroot()
    steps=xml.find('installSteps');backends=steps[0].findall('.//plugin')
    assert len(backends)==3
    definitions={d['key']:d for d in json.loads((root/'src/settings-catalog.json').read_text())}
    for backend in backends:
        flag=backend.find('./conditionFlags/flag').text
        visible=[s for s in list(steps)[1:] if s.find('./visible/flagDependency').get('value')==flag]
        assert bool(visible)==backend.get('name').startswith('Neither')
        if not visible:continue
        for use_default in [True,False]:
            selected={}
            for step in visible:
                for group in step.findall('./optionalFileGroups/group'):
                    assert group.get('type')=='SelectExactlyOne'
                    choices=group.findall('./plugins/plugin')
                    defaults=[c for c in choices if c.find('./typeDescriptor/type').get('name')=='Recommended']
                    assert len(defaults)==1
                    choice=defaults[0] if use_default else next(c for c in choices if c!=defaults[0])
                    f=choice.find('./files/file');ini=configparser.ConfigParser();ini.read(installer/f.get('source'))
                    key,value=next(iter(ini['Settings'].items()));value=int(value)
                    assert f.get('destination')==f'SFSE/Plugins/TransitReport/Installer/{key}.ini'
                    assert value in definitions[key]['values']
                    assert (value==definitions[key]['default'])==use_default
                    assert key not in selected;selected[key]=value
            assert selected.keys()==definitions.keys()
    assert not list((installer/'Options/Installer').rglob('*.swf'))
    assert not list((installer/'Options/Installer').rglob('*.json'))
    ini=configparser.ConfigParser();ini.read(installer/'Options/Installer/SFSE/Plugins/TransitReportBackend.ini')
    assert ini['Settings']['Backend']=='installer'
print('Passed: three backends; conditional steps; all 17 default and non-default INIs; installer-only has no schema/menu files.')
