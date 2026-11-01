"""Generate the third FOMOD backend and conditional configuration steps."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

def configure(installer: Path, catalog: Path):
    definitions=json.loads(catalog.read_text())
    config=installer/'fomod/ModuleConfig.xml'
    tree=ET.parse(config);root=tree.getroot();steps=root.find('installSteps')
    # Idempotent: generated steps are rebuilt from the shared settings catalog.
    for step in list(steps)[1:]:steps.remove(step)
    plugins=steps[0].find('./optionalFileGroups/group/plugins')
    for plugin in list(plugins):
        if plugin.get('name','').startswith('Neither'):plugins.remove(plugin)
    for plugin in plugins:
        flags=plugin.find('conditionFlags')
        if flags is None:flags=ET.SubElement(plugin,'conditionFlags')
        flags.clear();ET.SubElement(flags,'flag',name='tr_backend').text='menu'
        plugin.remove(flags);plugin.insert(list(plugin).index(plugin.find('typeDescriptor')),flags)
    plugin=ET.SubElement(plugins,'plugin',name='Neither — configure in installer')
    ET.SubElement(plugin,'description').text='Choose all Transit Report settings on the following installer pages. Adds no OSF Settings entry and no Gameplay Options controls. Reinstall with Replace to change choices or switch settings backends. Previous menu preferences are ignored in this mode.'
    files=ET.SubElement(plugin,'files');ET.SubElement(files,'folder',source='Options/Installer',destination='',priority='10')
    flags=ET.SubElement(plugin,'conditionFlags');ET.SubElement(flags,'flag',name='tr_backend').text='installer'
    ET.SubElement(ET.SubElement(plugin,'typeDescriptor'),'type',name='Optional')
    marker=installer/'Options/Installer/SFSE/Plugins/TransitReportBackend.ini'
    marker.parent.mkdir(parents=True,exist_ok=True);marker.write_text('[Settings]\nBackend=installer\n')
    groups=[('Appearance',['badge','spinner','background']),
            ('Display and pages',['character','progress','tips','clock','page_count','diagnostics','lifetime_mode']),
            ('Lifetime categories — general and combat',['lifetime_general','lifetime_combat']),
            ('Lifetime categories — exploration and crafting',['lifetime_exploration','lifetime_crafting']),
            ('Lifetime categories — quests, ships and crime',['lifetime_quests','lifetime_ship','lifetime_crime'])]
    by_key={d['key']:d for d in definitions}
    for title,keys in groups:
        step=ET.SubElement(steps,'installStep',name=title)
        visible=ET.SubElement(step,'visible');ET.SubElement(visible,'flagDependency',flag='tr_backend',value='installer')
        gs=ET.SubElement(step,'optionalFileGroups',order='Explicit')
        for key in keys:
            d=by_key[key];group=ET.SubElement(gs,'group',name=d['label'],type='SelectExactlyOne');ps=ET.SubElement(group,'plugins',order='Explicit')
            for value,label in zip(d['values'],d['labels']):
                option=ET.SubElement(ps,'plugin',name=label)
                ET.SubElement(option,'description').text=d['hint']
                relative=f'Choices/{key}/{value}.ini'
                file=installer/relative;file.parent.mkdir(parents=True,exist_ok=True);file.write_text(f'[Settings]\n{key}={value}\n')
                fs=ET.SubElement(option,'files');ET.SubElement(fs,'file',source=relative,destination=f'SFSE/Plugins/TransitReport/Installer/{key}.ini',priority='20')
                ET.SubElement(ET.SubElement(option,'typeDescriptor'),'type',name='Recommended' if value==d['default'] else 'Optional')
    ET.indent(root);tree.write(config,encoding='utf-8',xml_declaration=True)

if __name__=='__main__':
    import sys
    configure(Path(sys.argv[1]),Path(sys.argv[2]))
