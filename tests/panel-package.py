from pathlib import Path
import sys,zipfile
sys.path.insert(0,'scripts')
from artwork_swf import read_swf
expected={'mainmenu_settingspanel.swf','settingspanel.swf','settingspanel_lrg.swf'}
version=Path('VERSION').read_text().strip()
with zipfile.ZipFile(Path('dist')/f'Transit Report {version}.zip') as archive:
    actual={Path(n).name for n in archive.namelist() if n.startswith('Options/Gameplay/Interface/') and n.endswith('.swf')}
    assert actual==expected,actual
    assert not any(Path(n).name.lower() in {'mainmenu.swf','pausemenu.swf','pausemenu_lrg.swf'} for n in archive.namelist())
    assert not any('OSFSettingsMenu' in n for n in archive.namelist())
    assert archive.testzip() is None
for name in expected:
    _,_,records=read_swf(Path('build/ui/gameplay')/name)
    bytecode=b''.join(data for code,data in records if code==82)
    assert b'TRConfig' in bytecode and b'TRRefreshSettings' in bytecode,name
print('Passed: test archive ships only three Gameplay settings panels; all own the bridge and refresh method. No MainMenu, PauseMenu or OSF framework replacement ships.')
