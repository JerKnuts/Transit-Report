"""SWF bitmap/vector authoring helpers for included Transit Report artwork."""

import struct,zlib

from pathlib import Path

class Bits:
    def __init__(self):
        self.data = []

    def put(self, value, n):
        self.data.extend((value >> i) & 1 for i in range(n - 1, -1, -1))

    def bytes(self):
        self.data.extend([0] * (-len(self.data) % 8))
        return bytes(sum(self.data[i + j] << (7 - j) for j in range(8))
                     for i in range(0, len(self.data), 8))

def signed_width(*values):
    return max(2, max(abs(int(v)).bit_length() + 1 for v in values))

def rect(x0, x1, y0, y1):
    b = Bits()
    n = signed_width(x0, x1, y0, y1)
    b.put(n, 5)
    for v in (x0, x1, y0, y1):
        b.put(v, n)
    return b.bytes()

def matrix(scale=1, x=0, y=0):
    b = Bits()
    b.put(scale != 1, 1)
    if scale != 1:
        s = round(scale * 65536)
        n = signed_width(s)
        b.put(n, 5)
        b.put(s, n)
        b.put(s, n)
    b.put(0, 1)
    x, y = round(x * 20), round(y * 20)
    n = signed_width(x, y)
    b.put(n, 5)
    b.put(x, n)
    b.put(y, n)
    return b.bytes()

def tag(code, data=b''):
    n = len(data)
    return (struct.pack('<H', (code << 6) | min(n, 63))
            + (struct.pack('<I', n) if n >= 63 else b'') + data)

def tags(data):
    pos = 0
    while pos < len(data):
        if pos + 2 > len(data):
            raise ValueError('Truncated SWF tag header')
        h = struct.unpack_from('<H', data, pos)[0]
        pos += 2
        code, n = h >> 6, h & 63
        if n == 63:
            n = struct.unpack_from('<I', data, pos)[0]
            pos += 4
        if pos + n > len(data):
            raise ValueError('Truncated SWF tag body')
        yield code, data[pos:pos + n]
        pos += n
        if code == 0:
            if pos != len(data):
                raise ValueError('Unexpected bytes after End tag')
            break

def read_swf(path):
    data = Path(path).read_bytes()
    if data[:3] == b'CWS':
        raw = zlib.decompress(data[8:])
    elif data[:3] == b'FWS':
        raw = data[8:]
    else:
        raise ValueError('Expected FWS or CWS SWF')
    if len(raw) + 8 != struct.unpack_from('<I', data, 4)[0]:
        raise ValueError('SWF length mismatch')
    rlen = (5 + 4 * (raw[0] >> 3) + 7) // 8
    return data[3], raw[:rlen + 4], list(tags(raw[rlen + 4:]))

def write_swf(path, version, header, records):
    raw = header + b''.join(tag(c, d) for c, d in records)
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_bytes(b'CWS' + bytes([version]) + struct.pack('<I', len(raw) + 8)
                           + zlib.compress(raw, 9))

def place(cid, depth=1, scale=1, x=0, y=0, name=None, move=False):
    flags = 2 | 4 | (32 if name else 0) | int(move)
    return (bytes([flags]) + struct.pack('<HH', depth, cid) + matrix(scale, x, y)
            + (name.encode('utf-8') + b'\0' if name else b''))

def sprite(cid, records, frames=1):
    return struct.pack('<HH', cid, frames) + b''.join(tag(c, d) for c, d in records)

def edges(width, height):
    b = Bits()
    # One fill, no lines. Move to origin and select FillStyle1.
    b.put(1, 4)
    b.put(0, 4)
    b.put(0, 1)
    b.put(5, 5)
    b.put(1, 5)
    b.put(0, 1)
    b.put(0, 1)
    b.put(1, 1)
    for dx, dy in ((width, 0), (0, height), (-width, 0), (0, -height)):
        n = signed_width(dx, dy)
        if n > 17:
            raise ValueError('Shape edge exceeds supported size')
        b.put(1, 1)
        b.put(1, 1)
        b.put(n - 2, 4)
        b.put(0, 1)
        b.put(dy != 0, 1)
        b.put(dy if dy else dx, n)
    b.put(0, 6)
    return b.bytes()

def solid_shape(cid, width, height, rgba):
    w, h = round(width * 20), round(height * 20)
    return (struct.pack('<H', cid) + rect(0, w, 0, h) + b'\x01\x00'
            + bytes(rgba) + b'\x00' + edges(w, h))

def bitmap_shape(cid, bid, pixels):
    w = pixels * 20
    return (struct.pack('<H', cid) + rect(0, w, 0, w) + b'\x01\x41'
            + struct.pack('<H', bid) + matrix(20) + b'\x00' + edges(w, w))

def bitmap(cid, frame):
    # DefineBitsLossless2 format 5 stores premultiplied A,R,G,B bytes.
    rgba = frame.convert('RGBA').tobytes()
    argb = bytearray(len(rgba))
    for i in range(0, len(rgba), 4):
        r, g, b, a = rgba[i:i + 4]
        argb[i:i + 4] = bytes((a, (r*a + 127)//255, (g*a + 127)//255, (b*a + 127)//255))
    return (struct.pack('<HBHH', cid, 5, frame.width, frame.height)
            + zlib.compress(argb, 6))
