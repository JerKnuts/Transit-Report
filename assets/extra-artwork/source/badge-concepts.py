from pathlib import Path
import sys,math,struct,subprocess,json,zipfile
from PIL import Image,ImageDraw,ImageFont
root=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(root/'scripts'))
from artwork_swf import Bits,signed_width,rect,bitmap,bitmap_shape,write_swf,read_swf
out=root/'build/badge-concepts';out.mkdir(parents=True,exist_ok=True)
N=256;S=3;frames=180;fps=30
ivory=(225,236,238,255);cyan=(96,209,229,255);gold=(230,176,83,255);muted=(64,104,120,220);navy=(8,24,34,245)
def layer(fn):
 im=Image.new('RGBA',(N*S,N*S));d=ImageDraw.Draw(im)
 class D:
  def line(self,pts,fill=ivory,width=1):d.line([(round(x*S),round(y*S)) for x,y in pts],fill=fill,width=round(width*S))
  def ellipse(self,box,outline=ivory,width=1,fill=None):d.ellipse(tuple(round(v*S) for v in box),outline=outline,width=round(width*S),fill=fill)
  def arc(self,box,start,end,fill=ivory,width=1):d.arc(tuple(round(v*S) for v in box),start,end,fill=fill,width=round(width*S))
  def polygon(self,pts,fill=ivory):d.polygon([(round(x*S),round(y*S)) for x,y in pts],fill=fill)
 fn(D());return im.resize((N,N),Image.Resampling.LANCZOS)
def polar(r,a):return (128+r*math.cos(a),128+r*math.sin(a))
def ticks(d,n=48,r=110):
 for i in range(n):
  a=i*2*math.pi/n;d.line([polar(r- (7 if i%4==0 else 3),a),polar(r,a)],fill=gold if i%12==0 else muted,width=1)
def star(d,cx,cy,r=38,color=ivory):
 pts=[]
 for i in range(8):
  a=-math.pi/2+i*math.pi/4;rr=r if i%2==0 else r*.24;pts.append((cx+math.cos(a)*rr,cy+math.sin(a)*rr))
 d.polygon(pts,fill=color)
def base(d):d.ellipse((19,19,237,237),outline=muted,fill=navy);ticks(d)
concepts=[]
def add(name,desc,layers):concepts.append((name,desc,layers))
def compass(d):
 base(d);d.ellipse((43,43,213,213),outline=cyan);d.ellipse((65,65,191,191),outline=muted);star(d,128,128,60);d.polygon([(128,71),(138,120),(128,110)],fill=gold)
def compass_orbit(d):
 d.arc((31,31,225,225),8,75,fill=gold,width=3);d.ellipse((220,123,230,133),fill=cyan,outline=None)
add('Wayfinder','A fixed compass with a revolving navigation marker.',[(layer(compass),0,1),(layer(compass_orbit),1,1)])
def gate(d):
 base(d);d.ellipse((43,43,213,213),outline=gold,width=2);d.ellipse((91,91,165,165),outline=cyan,width=2);star(d,128,128,24)
 for a in [0,math.pi/2,math.pi,math.pi*1.5]:d.line([polar(48,a),polar(75,a)],fill=muted,width=2)
def gate_ring(d):
 for i in range(6):d.arc((63,63,193,193),i*60+5,i*60+36,fill=cyan,width=5)
def gate_inner(d):
 for i in range(3):d.arc((77,77,179,179),i*120,i*120+45,fill=gold,width=2)
add('Jump Gate','Counter-rotating gate segments around a steady star.',[(layer(gate),0,1),(layer(gate_ring),1,1),(layer(gate_inner),-1,1)])
def eclipse(d):
 base(d);d.ellipse((54,54,202,202),outline=gold,width=2,fill=(22,46,59,255));d.ellipse((87,41,209,187),outline=None,fill=navy);d.arc((54,54,202,202),70,235,fill=ivory,width=3);star(d,165,155,18,color=gold)
def eclipse_orbit(d):
 d.arc((35,35,221,221),205,288,fill=muted,width=2);d.ellipse((122,29,134,41),fill=cyan,outline=None)
add('Eclipse','An illuminated crescent with a slow orbital beacon.',[(layer(eclipse),0,1),(layer(eclipse_orbit),1,1)])
def hexagon(d):
 base(d)
 for r in [80,94]:
  pts=[polar(r,i*math.pi/3-math.pi/2) for i in range(6)];d.line(pts+[pts[0]],fill=cyan if r==80 else muted,width=2)
 d.polygon([(128,65),(153,150),(128,137),(103,150)],fill=ivory);d.line([(128,137),(128,177)],fill=gold,width=3)
def hex_nodes(d):
 for i in range(3):
  x,y=polar(94,i*2*math.pi/3-math.pi/2);d.ellipse((x-4,y-4,x+4,y+4),fill=gold,outline=None)
add('Pathfinder','A survey arrow with three rotating telemetry points.',[(layer(hexagon),0,1),(layer(hex_nodes),1,1)])
def pulsar(d):
 base(d);d.ellipse((70,70,186,186),outline=muted);star(d,128,128,39)
 for a in [0,math.pi/2,math.pi,math.pi*1.5]:d.line([polar(65,a),polar(87,a)],fill=gold,width=2)
def pulsar_wave(d):
 d.ellipse((43,43,213,213),outline=cyan,width=2);d.arc((31,31,225,225),230,300,fill=ivory,width=2)
add('Signal Star','A steady signal star with a breathing wave ring.',[(layer(pulsar),0,1),(layer(pulsar_wave),-1,.7)])
def transform(scale,angle):
 b=Bits();a=round(math.cos(angle)*scale*65536);s=round(math.sin(angle)*scale*65536)
 b.put(1,1);n=signed_width(a);b.put(n,5);b.put(a,n);b.put(a,n)
 b.put(1,1);n=signed_width(s);b.put(n,5);b.put(s,n);b.put(-s,n)
 x=round((128-math.cos(angle)*scale*128+math.sin(angle)*scale*128)*20);y=round((128-math.sin(angle)*scale*128-math.cos(angle)*scale*128)*20)
 n=signed_width(x,y);b.put(n,5);b.put(x,n);b.put(y,n);return b.bytes()
def place(cid,depth,angle,scale,move):return bytes([6|int(move)])+struct.pack('<HH',depth,cid)+transform(scale,angle)
def scale_for(k,j,phase):return .85+.15*math.cos(phase) if k==4 and j==1 else 1
preview_frames=[[] for c in concepts]
for k,(name,desc,layers) in enumerate(concepts):
 rec=[(69,struct.pack('<I',8))]
 for j,(im,speed,_) in enumerate(layers):rec.extend([(36,bitmap(2*j+1,im)),(32,bitmap_shape(2*j+2,2*j+1,N))])
 for i in range(frames):
  phase=2*math.pi*i/frames;im=Image.new('RGBA',(N,N))
  for j,(asset,speed,_) in enumerate(layers):
   scale=scale_for(k,j,phase);rec.append((26,place(2*j+2,j+1,phase*speed,scale,i>0)))
   rotated=asset.rotate(-360*i/frames*speed,resample=Image.Resampling.BICUBIC)
   if scale!=1:
    size=round(N*scale);small=rotated.resize((size,size),Image.Resampling.LANCZOS);rotated=Image.new('RGBA',(N,N));rotated.alpha_composite(small,((N-size)//2,(N-size)//2))
   im.alpha_composite(rotated)
  preview_frames[k].append(im);rec.append((1,b''))
 rec.append((0,b''));write_swf(out/(name+'.swf'),10,rect(0,5120,0,5120)+struct.pack('<HH',fps*256,frames),rec)
 _,_,records=read_swf(out/(name+'.swf'));assert sum(c==1 for c,d in records)==180;assert not any(c in (12,59,82) for c,d in records)
 preview_frames[k][0].save(out/(name+'.png'))
 gifs=[]
 for im in preview_frames[k][::2]:
  bg=Image.new('RGBA',im.size,(8,19,27,255));bg.alpha_composite(im);gifs.append(bg.convert('RGB'))
 gifs[0].save(out/(name+'.gif'),save_all=True,append_images=gifs[1:],duration=67,loop=0,optimize=False)
ff=next((root.parent.parent/'video-tools').rglob('ffmpeg*.exe'))
font=ImageFont.truetype('C:/Windows/Fonts/CascadiaMono.ttf',21);title=ImageFont.truetype('C:/Windows/Fonts/CascadiaMono.ttf',30)
positions=[(155,135),(510,135),(865,135),(330,420),(690,420)]
p=subprocess.Popen([str(ff),'-y','-loglevel','error','-f','rawvideo','-pix_fmt','rgb24','-s','1280x780','-r','30','-i','-','-an','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(out/'Five Animated Player Badges.mp4')],stdin=subprocess.PIPE)
for i in range(frames):
 board=Image.new('RGBA',(1280,780),(7,17,25,255));d=ImageDraw.Draw(board);d.text((55,30),'TRANSIT REPORT | PLAYER BADGE CONCEPTS',font=title,fill=ivory)
 for k,((name,desc,layers),(x,y)) in enumerate(zip(concepts,positions)):
  board.alpha_composite(preview_frames[k][i],(x,y-30));d.text((x+128,y+235),f'{k+1:02}  {name.upper()}',font=font,fill=ivory,anchor='mt')
 if i==0:board.convert('RGB').save(out/'Five Badge Options.jpg',quality=95)
 p.stdin.write(board.convert('RGB').tobytes())
p.stdin.close();assert p.wait()==0
(out/'README.txt').write_text('FIVE ANIMATED PLAYER BADGE CONCEPTS\n\n'+''.join(f'{i+1}. {n}: {d}\n' for i,(n,d,l) in enumerate(concepts))+'\nEach SWF has a transparent background and a six-second 30fps script-free loop. GIF/MP4 files are previews. These are design options, not yet added to the release settings. Custom PNG import uses a still image; use the SWF when integrating animation.\n',encoding='utf-8')
with zipfile.ZipFile(out/'Five Animated Player Badges.zip','w',zipfile.ZIP_DEFLATED) as z:
 for f in out.iterdir():
  if f.suffix in ('.swf','.png','.gif','.txt','.mp4','.jpg'):z.write(f,f.name)
print(out)
