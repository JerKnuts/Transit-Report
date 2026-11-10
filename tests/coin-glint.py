from pathlib import Path
import sys,struct
sys.path.insert(0,'scripts')
from artwork_swf import read_swf,tags
for path in Path('assets/themes').glob('*/*-coin.swf'):
    _,_,records=read_swf(path)
    placements=[data for code,data in records if code==26]
    assert len(placements)==180
    assert placements[0][0]&2
    assert all(data[0]&1 and not data[0]&2 for data in placements[1:]),path
    nested=next(data for code,data in records if code==39 and struct.unpack_from('<H',data)[0]==5)
    glints=[data for code,data in tags(nested[4:]) if code==26 and struct.unpack_from('<H',data,1)[0]==3]
    assert len(glints)==180
    assert len(set(glints[1:]))>30,'Glint must move across the face'
    assert all(data[0]&1 and not data[0]&2 for data in glints[1:])
print('Passed: all seven coins preserve nested animation during tilt; glint transforms vary across the 180-frame loop.')
