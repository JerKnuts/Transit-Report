"""Author six-second looping defaults and a matching motion preview (Pillow)."""
from pathlib import Path
import math,struct,random,json,subprocess,argparse
from PIL import Image,ImageDraw,ImageFont
from artwork_swf import Bits,signed_width,rect,edges,matrix,bitmap,bitmap_shape,solid_shape,write_swf

root=Path(__file__).resolve().parents[1]
assets=root/'assets/custom-defaults';out=assets/'runtime';out.mkdir(exist_ok=True)
frames=180;fps=30
def transform(scale=1,angle=0,x=0,y=0):
    b=Bits();a=round(math.cos(angle)*scale*65536);s=round(math.sin(angle)*scale*65536)
    b.put(1,1);n=signed_width(a);b.put(n,5);b.put(a,n);b.put(a,n)
    b.put(1,1);n=signed_width(s);b.put(n,5);b.put(s,n);b.put(-s,n)
    x=round(x*20);y=round(y*20);n=signed_width(x,y);b.put(n,5);b.put(x,n);b.put(y,n);return b.bytes()
def placement(cid,depth,m,move=False,alpha=1):
    b=Bits();b.put(0,1);b.put(1,1);b.put(10,4)
    for value in [256,256,256,round(alpha*256)]:b.put(value,10)
    return bytes([2|4|8|int(move)])+struct.pack('<HH',depth,cid)+m+b.bytes()
def rectangle_bitmap(cid,bid,w,h):
    return struct.pack('<H',cid)+rect(0,w*20,0,h*20)+b'\x01\x41'+struct.pack('<H',bid)+matrix(20)+b'\x00'+edges(w*20,h*20)
def dot(size,color):
    im=Image.new('RGBA',(size,size));ImageDraw.Draw(im).ellipse((0,0,size-1,size-1),fill=color);return im
badge=Image.open(assets/'badge.png').convert('RGBA').resize((240,240),Image.Resampling.LANCZOS)
wall=Image.open(assets/'wallpaper.png').convert('RGBA').resize((1920,1080),Image.Resampling.LANCZOS)
gold=dot(10,(240,190,85,255));cyan=dot(8,(112,219,244,255))
def badge_records(indicator=False):
    records=[(69,struct.pack('<I',8)),(36,bitmap(1,badge)),(32,rectangle_bitmap(2,1,240,240)),(36,bitmap(3,gold)),(32,bitmap_shape(4,3,10)),(36,bitmap(5,cyan)),(32,bitmap_shape(6,5,8)),(32,solid_shape(7,256,256,(0,0,0,0)))]
    for i in range(frames):
        phase=2*math.pi*i/frames;angle=phase if indicator else 0
        scale=1 if indicator else .975+.025*math.cos(phase)
        a=math.cos(angle)*scale;b=math.sin(angle)*scale
        records.append((26,placement(2,1,transform(scale,angle,128-a*120+b*120,128-b*120-a*120),i>0)))
        for cid,depth,radius,speed,offset,size in [(4,2,112,1,0,10),(6,3,108,-1,math.pi,8)]:
            theta=phase*speed+offset
            records.append((26,placement(cid,depth,transform(x=128+radius*math.cos(theta)-size/2,y=128+radius*math.sin(theta)-size/2),i>0)))
        if i==0:records.append((26,placement(7,99,transform())))
        records.append((1,b''))
    records.append((0,b''));return records
for name,indicator in [('badge',False),('indicator',True)]:
    write_swf(out/(name+'.swf'),10,rect(0,5120,0,5120)+struct.pack('<HH',fps*256,frames),badge_records(indicator))
rng=random.Random(96)
stars=[(rng.uniform(40,1880),rng.uniform(40,1040),rng.uniform(3,14),rng.uniform(0,2*math.pi)) for _ in range(30)]
records=[(69,struct.pack('<I',8)),(36,bitmap(1,wall)),(32,rectangle_bitmap(2,1,1920,1080)),(36,bitmap(3,cyan)),(32,bitmap_shape(4,3,8)),(36,bitmap(5,gold)),(32,bitmap_shape(6,5,10))]
for i in range(frames):
    phase=2*math.pi*i/frames
    if i==0:records.append((26,placement(2,1,transform())))
    for n,(x,y,r,offset) in enumerate(stars):
        alpha=.15+.3*(.5+.5*math.sin(phase+offset))
        records.append((26,placement(4,n+2,transform(.16,x=x+r*math.cos(phase+offset),y=y+r*.4*math.sin(phase+offset)),i>0,alpha)))
    records.append((26,placement(6,40,transform(.45,x=1310+310*math.cos(phase),y=485+165*math.sin(phase)),i>0,.85)))
    records.append((26,placement(4,41,transform(.45,x=1290+430*math.cos(-phase+.8),y=510+210*math.sin(-phase+.8)),i>0,.7)))
    records.append((1,b''))
records.append((0,b''));write_swf(out/'wallpaper.swf',10,rect(0,38400,0,21600)+struct.pack('<HH',fps*256,frames),records)
(out/'manifest.json').write_text(json.dumps({'frames':frames,'fps':fps,'seconds':6,'assets':['badge.swf','indicator.swf','wallpaper.swf'],'contains_scripts':False},indent=2),encoding='utf-8')
print('Three original six-second animated default SWFs built.')
parser=argparse.ArgumentParser();parser.add_argument('--ffmpeg',type=Path);args=parser.parse_args()
if args.ffmpeg:
    preview=root/'build/default-artwork-preview.mp4';preview.parent.mkdir(exist_ok=True)
    p=subprocess.Popen([str(args.ffmpeg),'-y','-loglevel','error','-f','rawvideo','-pix_fmt','rgb24','-s','1280x720','-r','30','-i','-','-an','-c:v','libx264','-crf','19','-pix_fmt','yuv420p','-movflags','+faststart',str(preview)],stdin=subprocess.PIPE)
    font=ImageFont.truetype('C:/Windows/Fonts/CascadiaMono.ttf',23)
    for i in range(frames):
        phase=2*math.pi*i/frames;im=wall.resize((1280,720)).convert('RGBA');d=ImageDraw.Draw(im)
        for x,y,r,offset in stars:
            xx=(x+r*math.cos(phase+offset))*2/3;yy=(y+r*.4*math.sin(phase+offset))*2/3
            d.ellipse((xx,yy,xx+1.5,yy+1.5),fill=(110,200,220,130))
        for xx,yy,c in [(1310+310*math.cos(phase),485+165*math.sin(phase),(240,190,85)),(1290+430*math.cos(-phase+.8),510+210*math.sin(-phase+.8),(112,219,244))]:
            xx*=2/3;yy*=2/3;d.ellipse((xx-1.5,yy-1.5,xx+1.5,yy+1.5),fill=c)
        for x,y,size,rot in [(70,480,160,False),(1135,590,88,True)]:
            logo=badge.resize((size,size),Image.Resampling.LANCZOS)
            if rot:logo=logo.rotate(-360*i/frames,resample=Image.Resampling.BICUBIC)
            else:
                small=round(size*(.975+.025*math.cos(phase)));logo=logo.resize((small,small));x+=(size-small)//2;y+=(size-small)//2
            im.alpha_composite(logo,(x,y));d=ImageDraw.Draw(im)
            for radius,color,offset in [(size*.47,(240,190,85,255),0),(size*.45,(112,219,244,255),math.pi)]:
                t=phase+offset;xx=x+size/2+radius*math.cos(t);yy=y+size/2+radius*math.sin(t);d.ellipse((xx-2,yy-2,xx+2,yy+2),fill=color)
        d.text((34,26),'TRANSIT REPORT 0.9.6 | INCLUDED CUSTOM ARTWORK',font=font,fill=(230,239,245))
        p.stdin.write(im.convert('RGB').tobytes())
    p.stdin.close();assert p.wait()==0;print(preview)
