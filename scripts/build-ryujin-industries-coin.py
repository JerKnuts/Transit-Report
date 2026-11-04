from pathlib import Path
import math,struct,sys,json
from PIL import Image
root=Path(__file__).resolve().parents[1];r=root;sys.path.insert(0,str(r/'scripts'))
from artwork_swf import Bits,signed_width,rect,matrix,bitmap,bitmap_shape,solid_shape,place,sprite,write_swf,read_swf
out=root/'assets/themes/ryujin-industries';im=Image.open(out/'coin.png').convert('RGBA')
# Match the in-game-verified Crimson Fleet prefilter and gentler animation.
im=im.convert('RGBa').resize((192,192),Image.Resampling.LANCZOS).convert('RGBA');F=90

def poly(cid,paths):
 b=Bits();n=max(1,len(paths).bit_length());b.put(n,4);b.put(0,4)
 for j,(pts,color) in enumerate(paths):
  x,y=[round(v*20) for v in pts[0]];b.put(0,1);b.put(5,5);q=signed_width(x,y);b.put(q,5);b.put(x,q);b.put(y,q);b.put(j+1,n)
  for xx,yy in pts[1:]+[pts[0]]:
   xx,yy=round(xx*20),round(yy*20);dx,dy=xx-x,yy-y;q=signed_width(dx,dy);b.put(1,1);b.put(1,1);b.put(q-2,4);b.put(1,1);b.put(dx,q);b.put(dy,q);x,y=xx,yy
 b.put(0,6)
 coords=[point for pts,color in paths for point in pts]
 return struct.pack('<H',cid)+rect(round(min(x for x,y in coords)*20),round(max(x for x,y in coords)*20),round(min(y for x,y in coords)*20),round(max(y for x,y in coords)*20))+bytes([len(paths)])+b''.join(b'\x00'+bytes(c) for pts,c in paths)+b'\x00'+b.bytes()
def transform(sx=1,sy=1,angle=0,x=0,y=0):
 b=Bits();a=round(math.cos(angle)*sx*65536);d=round(math.cos(angle)*sy*65536);c=round(-math.sin(angle)*sy*65536);bb=round(math.sin(angle)*sx*65536)
 b.put(1,1);q=signed_width(a,d);b.put(q,5);b.put(a,q);b.put(d,q);b.put(1,1);q=signed_width(c,bb);b.put(q,5);b.put(bb,q);b.put(c,q);x=round(x*20);y=round(y*20);q=signed_width(x,y);b.put(q,5);b.put(x,q);b.put(y,q);return b.bytes()
def placed(cid,depth,m,move=False,clip=None):return bytes([6|int(move)|(64 if clip else 0)])+struct.pack('<HH',depth,cid)+m+(struct.pack('<H',clip) if clip else b'')
# Single shared original render; the logo itself is never redrawn.
defs=[(69,struct.pack('<I',8)),(36,bitmap(1,im)),(32,bitmap_shape(2,1,im.width))]
# Clip the glint to the actual approved render silhouette, slightly inset.
alpha=im.getchannel('A');left=[];right=[]
for yy in range(0,im.height,3):
 xs=[xx for xx in range(im.width) if alpha.getpixel((xx,yy))>220]
 if len(xs)>5:
  left.append((32+(min(xs)+2)*448/im.width,32+yy*448/im.height))
  right.append((32+(max(xs)-2)*448/im.width,32+yy*448/im.height))
maskpts=left+list(reversed(right))
defs.append((32,poly(3,[(maskpts,(255,255,255,255))])))
# A broad, softly stepped specular strip. Low alpha preserves the enamel colors.
paths=[]
for j in range(21):
 xx=(j-10)*7;alpha=round(105*math.exp(-((j-10)/4.8)**2));paths.append(([(xx-155,-180),(xx-148,-180),(xx+152,700),(xx+145,700)],(255,247,222,alpha)))
defs.append((32,poly(4,paths)))
inner=[(26,placed(2,1,matrix(448/im.width,32,32))),(26,placed(3,2,matrix(),clip=3))]
for f in range(F):
 phase=2*math.pi*f/F;x=256+440*math.sin(phase)
 inner.extend([(26,placed(4,3,transform(x=x),f>0)),(1,b'')])
inner.append((0,b''));defs.append((39,sprite(5,inner,F)))
for name,strength in [('ryujin-industries-coin',.10)]:
 records=list(defs)
 for f in range(F):
  p=2*math.pi*f/F;angle=math.sin(p)*(.055 if strength<.2 else .075);sx=1-strength+strength*math.cos(p);sy=.985+.015*math.cos(p)
  x=256-math.cos(angle)*sx*256+math.sin(angle)*sy*256;y=256-math.sin(angle)*sx*256-math.cos(angle)*sy*256
  records.extend([(26,placed(5,1,transform(sx,sy,angle,x,y),f>0)),(1,b'')])
 records.append((0,b''));write_swf(out/(name+'.swf'),10,rect(0,10240,0,10240)+struct.pack('<HH',30*256,F),records)
 _,_,tags=read_swf(out/(name+'.swf'));assert sum(c==1 for c,d in tags)==90;assert not any(c in (12,59,82) for c,d in tags)
(out/'Animation Notes.txt').write_text('Approved three-second 30fps loop: faster and stronger tilt with prominent glint. Same animation for badge and indicator. Filtered 192px runtime texture; detailed PNG preserved. In-game verification pending.\n',encoding='utf-8')
print(out)
