from pathlib import Path
import shutil,zipfile
r=Path(__file__).resolve().parents[1];v=(r/'VERSION').read_text().strip();out=r/'dist';out.mkdir(exist_ok=True)
# Temporary staging lives only inside this repository's ignored build folder.
p=r/'build/package';p.mkdir(parents=True,exist_ok=True)
def copy(a,b):
 b=p/b;b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/a,b)
shutil.copytree(r/'installer/fomod',p/'fomod',dirs_exist_ok=True)
for f in (r/'build/ui/loading').glob('*.swf'):copy(f.relative_to(r),Path('Core/Interface')/f.name)
assert (p/'Core/Interface/loadingmenu.swf').is_file(),'Run build-ui.ps1 first'
copy('native/staged/SFSE/Plugins/LSCNativeBridge.dll','Core/SFSE/Plugins/LSCNativeBridge.dll')
for f in (r/'build/ui/gameplay').glob('*.swf'):copy(f.relative_to(r),Path('Options/Gameplay/Interface')/f.name)
assert len(list((p/'Options/Gameplay/Interface').glob('*.swf')))==6
copy('src/osf/loading-screen-configurator.json','Options/OSF/SFSE/Plugins/OSF/Settings/schemas/loading-screen-configurator.json')
for name,value in [('OSF','osf'),('Gameplay','gameplay')]:
 f=p/'Options'/name/'SFSE/Plugins/TransitReportBackend.ini';f.parent.mkdir(parents=True,exist_ok=True);f.write_text('[Settings]\nBackend='+value+'\n')
for f in ['README.md','LICENSE','EXCEPTIONS','THIRD_PARTY_NOTICES.md']:copy(f,Path('Core/Docs/Transit Report')/f)
shutil.copytree(r/'docs/licenses',p/'Core/Docs/Transit Report/Licenses',dirs_exist_ok=True)
from configure_installer import configure
configure(p,r/'src/settings-catalog.json')
with zipfile.ZipFile(out/f'Transit Report {v}.zip','w',zipfile.ZIP_DEFLATED) as z:
 for f in p.rglob('*'):
  if f.is_file():z.write(f,f.relative_to(p))
print(out/f'Transit Report {v}.zip')
