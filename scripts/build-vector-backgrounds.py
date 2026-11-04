"""Resolution-independent SWF linework: no raster textures in these backgrounds."""
from pathlib import Path
import math,random,struct
from artwork_swf import Bits,signed_width,rect,matrix,solid_shape,place,write_swf,read_swf
root=Path(__file__).resolve().parents[1];out=root/'assets/extra-artwork/runtime'
W,H=1280,720;F=180
cyan=(64,112,133,255);faint=(28,54,68,255);gold=(126,106,70,255)
def vector(cid,paths):
 # Each path has its own round-cap line style. Coordinates are SWF twips.
 b=Bits();n=max(1,len(paths).bit_length());b.put(0,4);b.put(n,4)
 for j,(points,color,width,closed) in enumerate(paths):
  x,y=[round(v*20) for v in points[0]];b.put(0,1);b.put(9,5);q=signed_width(x,y);b.put(q,5);b.put(x,q);b.put(y,q);b.put(j+1,n)
  for point in points[1:]+([points[0]] if closed else []):
   xx,yy=[round(v*20) for v in point];dx,dy=xx-x,yy-y;q=signed_width(dx,dy);assert q<=17
   b.put(1,1);b.put(1,1);b.put(q-2,4);b.put(1,1);b.put(dx,q);b.put(dy,q);x,y=xx,yy
 b.put(0,6)
 styles=b'\x00'+bytes([len(paths)])+b''.join(struct.pack('<H',round(width*20))+bytes(color) for points,color,width,closed in paths)
 coords=[p for points,c,w,cl in paths for p in points];pad=60
 return struct.pack('<H',cid)+rect(round(min(x for x,y in coords)*20)-pad,round(max(x for x,y in coords)*20)+pad,round(min(y for x,y in coords)*20)-pad,round(max(y for x,y in coords)*20)+pad)+styles+b.bytes()
def ellipse(x,y,rx,ry=None,start=0,end=360,color=faint,width=1):
 ry=rx if ry is None else ry
 # Vector segments at 1 degree, preserved as vector edges by Scaleform at every resolution.
 pts=[(x+rx*math.cos(math.radians(a)),y+ry*math.sin(math.radians(a))) for a in range(start,end+1,2)]
 return (pts,color,width,end-start==360)
def line(points,color=faint,width=1):return (points,color,width,False)
def rotation(angle,x=960,y=255):
 b=Bits();a=round(math.cos(angle)*65536);s=round(math.sin(angle)*65536);b.put(1,1);n=signed_width(a);b.put(n,5);b.put(a,n);b.put(a,n);b.put(1,1);n=signed_width(s);b.put(n,5);b.put(s,n);b.put(-s,n);xx=round(x*20);yy=round(y*20);n=signed_width(xx,yy);b.put(n,5);b.put(xx,n);b.put(yy,n);return b.bytes()
def position(cid,depth,m,move=False):return bytes([6|int(move)])+struct.pack('<HH',depth,cid)+m
names=['star-chart','deep-orbit','survey-sweep','constellation','solar-horizon']
for k,name in enumerate(names):
 paths=[];rng=random.Random(97+k)
 for _ in range(55):
  x=rng.randint(30,1250);y=rng.randint(20,465);paths.append(line([(x,y),(x+.6,y)],(54,79,93,255),.8))
 if k==0:
  for x in range(40,W,80):paths.append(line([(x,20),(x,460)],(18,38,49,255)))
  for y in range(20,470,80):paths.append(line([(40,y),(1240,y)],(18,38,49,255)))
  for r in [65,120,180,220]:paths.append(ellipse(960,255,r))
  paths.extend([line([(700,255),(1220,255)],cyan),line([(960,25),(960,475)],cyan)])
 elif k==1:
  paths.extend([ellipse(960,270,215,color=cyan),ellipse(950,270,280,100,color=gold),ellipse(950,270,180,255),ellipse(950,270,200,start=195,end=265,color=(115,160,177,255),width=1.4)])
  for y in [180,270,360]:paths.append(line([(760,y),(1140,y)]))
 elif k==2:
  for r in [55,110,165,220]:paths.append(ellipse(960,255,r))
  paths.extend([line([(710,255),(1210,255)],cyan),line([(960,20),(960,490)],cyan)])
  for a in range(0,360,15):
   t=math.radians(a);paths.append(line([(960+212*math.cos(t),255+212*math.sin(t)),(960+220*math.cos(t),255+220*math.sin(t))],gold))
 elif k==3:
  pts=[(715,145),(820,210),(915,110),(1015,195),(1160,130),(1080,345),(930,390),(815,330)]
  for a,b in [(0,1),(1,2),(2,3),(3,4),(3,5),(5,6),(6,7),(7,1)]:paths.append(line([pts[a],pts[b]],cyan))
  for j,(x,y) in enumerate(pts):paths.append(ellipse(x,y,4,color=gold if j%2 else (120,168,180,255)))
 else:
  paths.extend([ellipse(1000,655,510,start=190,end=350,color=(83,137,153,255),width=1.5),ellipse(1000,655,530,start=195,end=345),ellipse(1065,130,55,color=gold),line([(650,260),(1250,260)])])
 motion=[ellipse(0,0,220,start=220,end=290,color=cyan,width=1.5)]
 if k==2:motion=[line([(0,0),(219,0)],(80,146,162,255),1.5),ellipse(0,0,220,start=330,end=358,color=cyan,width=2)]
 if k==4:motion=[ellipse(0,0,220,start=215,end=265,color=gold,width=1.5)]
 records=[(69,struct.pack('<I',8)),(32,solid_shape(1,W,H,(5,16,24,255))),(32,vector(2,paths)),(32,vector(3,motion)),(32,vector(4,[ellipse(0,0,2,color=(150,210,225,255),width=2)]))]
 for i in range(F):
  phase=2*math.pi*i/F
  if i==0:records.extend([(26,place(1,1)),(26,place(2,2))])
  records.append((26,position(3,3,rotation(phase*(-1 if k==1 else 1)),i>0)))
  records.append((26,position(4,4,rotation(0,960+200*math.cos(phase),255+(90 if k==1 else 200)*math.sin(phase)),i>0)))
  records.append((1,b''))
 records.append((0,b''));write_swf(out/('background-'+name+'.swf'),10,rect(0,W*20,0,H*20)+struct.pack('<HH',30*256,F),records)
 _,_,tags=read_swf(out/('background-'+name+'.swf'));assert not any(c in [6,20,21,35,36,90] for c,d in tags)
 print(name, (out/('background-'+name+'.swf')).stat().st_size,'bytes; vector only')
