from pathlib import Path
import subprocess,sys,tempfile,struct,zlib
from PIL import Image,ImageDraw
sys.path.insert(0,'scripts');from artwork_swf import read_swf
checker=Path(sys.argv[1]).resolve()
with tempfile.TemporaryDirectory(dir='build') as temp:
 base=Path(temp);art=base/'Artwork';(art/'Badges').mkdir(parents=True);data=base/'Data'
 for disposal in [1,2,3]:
  frames=[]
  for i in range(4):
   im=Image.new('RGBA',(20,16));ImageDraw.Draw(im).rectangle((i*3,2,i*3+5,8),fill=(255,30*i,80,255));frames.append(im)
  frames[0].save(art/'Badges'/f'case{disposal}.gif',save_all=True,append_images=frames[1:],duration=[100,200,100,300],disposal=disposal,loop=0,optimize=True)
 def run():return subprocess.run([str(checker),str(data),str(art)],capture_output=True,text=True,check=True).stdout
 text=run();assert '3 custom images available' in text,text
 for path in (art/'Badges').glob('*.gif'):
  hash=14695981039346656037
  for b in path.read_bytes():hash=((hash^b)*1099511628211)&((1<<64)-1)
  _,header,tags=read_swf(data/'Interface/TransitReport/Cache'/f'badge-v2-{hash}.swf');actual=[]
  for code,d in tags:
   assert code not in (12,59,82)
   if code==36:actual.append(zlib.decompress(d[7:]))
  gif=Image.open(path);assert len(actual)==gif.n_frames
  for i,raw in enumerate(actual):
   gif.seek(i);rgba=gif.convert('RGBA').tobytes();expected=bytearray()
   for j in range(0,len(rgba),4):
    r,g,b,a=rgba[j:j+4];expected.extend([a,(r*a+127)//255,(g*a+127)//255,(b*a+127)//255])
   assert raw==expected,(path,i)
  gif.close();assert sum(c==1 for c,d in tags)==21
 assert run().count('cached artwork reused')==3
 (art/'Badges/broken.gif').write_bytes(b'bad gif');assert 'decoder error' in run()
print('Passed: GIF disposal 1/2/3, optimized rectangles, transparency, timing, script-free SWF, cache reuse and invalid GIF handling.')

