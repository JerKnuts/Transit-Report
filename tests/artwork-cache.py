"""Run against the standalone C++ checker; needs Pillow for image fixtures."""
from pathlib import Path
import argparse,subprocess,tempfile,struct,zlib,os
from PIL import Image

parser=argparse.ArgumentParser();parser.add_argument('checker',type=Path);args=parser.parse_args();checker=args.checker.resolve()
root=Path(__file__).resolve().parents[1];(root/'build').mkdir(exist_ok=True)
def pixels(file):
    b=file.read_bytes();assert b[:3]==b'FWS'
    pos=8+(5+4*(b[8]>>3)+7)//8+4
    while pos<len(b):
        tag=struct.unpack_from('<H',b,pos)[0];pos+=2;code=tag>>6;n=tag&63
        if n==63:n=struct.unpack_from('<I',b,pos)[0];pos+=4
        d=b[pos:pos+n];pos+=n
        if code==36:
            _,fmt,w,h=struct.unpack_from('<HBHH',d);assert fmt==5
            raw=zlib.decompress(d[7:]);assert len(raw)==w*h*4;return w,h,raw
    raise AssertionError('Bitmap tag missing')
with tempfile.TemporaryDirectory(dir=root/'build') as temp:
    base=Path(temp);data=base/'Data';art=base/'Documents/My Games/Starfield/Transit Report/Artwork'
    def run():
        p=subprocess.run([str(checker),str(data),str(art)],capture_output=True,text=True,check=True);return p.stdout
    def selected(text,index):
        value=next(line.split(': ',1)[1] for line in text.splitlines() if line.startswith('files'+str(index)+': '))
        return value.split('|') if value else []
    run();assert all((art/n).is_dir() for n in ['Badges','Indicators','Backgrounds'])
    badge=art/'Badges/My favourite badge.PNG';im=Image.new('RGBA',(2,2));im.putdata([(255,0,0,255),(0,255,0,128),(0,0,255,0),(40,80,120,64)]);im.save(badge)
    (art/'Badges/README.txt').write_text('Not an image')
    wall=art/'Backgrounds/Any wallpaper name.JpEg';Image.new('RGB',(19,7),(10,50,90)).save(wall)
    text=run();assert 'badge: prepared 2x2' in text and 'wallpaper: prepared 19x7' in text,text
    cache=data/'Interface/TransitReport/Cache'
    assert pixels(cache/selected(text,0)[0])==(2,2,bytes([255,255,0,0,128,0,128,0,0,0,0,0,64,10,20,30]))
    assert 'cached artwork reused' in run()
    Image.new('RGBA',(2,2),(90,20,10,255)).save(badge);os.utime(badge,(1000000000,1000000000))
    text=run();assert 'badge: prepared 2x2' in text;assert pixels(cache/selected(text,0)[0])[2]==bytes([255,90,20,10])*4
    extra=art/'Badges/second.png';Image.new('RGBA',(1,1)).save(extra)
    text=run();assert len(selected(text,0))==2;assert len(list(cache.glob('badge-v2-*.swf')))==2
    badge.write_bytes(b'not a PNG');text=run();assert 'decoder error' in text;assert len(selected(text,0))==1
    badge.unlink();extra.unlink();text=run();assert not selected(text,0);assert not list(cache.glob('badge-v2-*.swf'))
    Image.new('RGB',(3000,1000),(20,30,40)).save(wall)
    text=run();assert 'prepared 2560x853' in text;assert pixels(cache/selected(text,2)[0])[:2]==(2560,853)
    wall.unlink()
    for i in range(10):Image.new('RGB',(16,9),(i*20,30,80)).save(art/'Backgrounds'/f'Wallpaper {i}.png')
    text=run();assert len(selected(text,2))==10;assert len(list(cache.glob('wallpaper-v2-*.swf')))==10
    text=run();assert text.count('wallpaper: cached artwork reused')==10
print('Passed: Documents folders, arbitrary names/case, PNG alpha/JPG, cache refresh, multiple-image pools, invalid/empty cleanup, 10-wallpaper reuse, size limits.')
