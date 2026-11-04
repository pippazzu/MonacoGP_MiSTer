#!/usr/bin/env python3
"""Render the car region of every frame in player-frames.txt (written by
tests/tb_player.v) as one contact sheet, for inspection. Reporting aid only;
it checks nothing. Needs Pillow.

Usage: player_frames_png.py player-frames.txt out.png

Each tile is the dumped region x=160..199, y=100..139 at 3x, in the false
colours of the core's player-car view (sheet C is not traced): body orange,
tyre cyan, BL magenta, the 32x32 window grey, and the test oil slick green
while the slide state is selected. The caption gives the frame number, the
test state and the PROMs enabled at the car's first pixel row.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

X0, Y0, WX, WY = 160, 100, 164, 104
SLICK = (166, 171, 116, 121)
STATES = ('NORMAL', 'SLIDE', 'ACCIDENT', 'EXPLOSION')
CODES = {1: (0xff, 0xaa, 0x00), 2: (0x00, 0xbb, 0xff), 3: (0xff, 0x00, 0xbb)}
BACKGROUND, WINDOW, SLICKC = (0x11, 0x11, 0x22), (0x44, 0x44, 0x55), (0x11, 0x44, 0x11)
SCALE, CAPTION, COLS = 3, 26, 10


def parse(path):
    frames, cur = [], None
    for line in Path(path).read_text().splitlines():
        if line.startswith('FRAME'):
            f = line.split()
            cur = {'frame': int(f[1]), 'state': int(f[3]), 'ovr': f[7] == '1',
                   'explo': f[9] == '1', 'code': [], 'en': []}
            frames.append(cur)
        else:
            cur['code'].append([int(line[i]) for i in range(0, len(line), 2)])
            cur['en'].append([int(line[i], 16) for i in range(1, len(line), 2)])
    return [f for f in frames if len(f['code']) == 40]


def tile(f):
    img = Image.new('RGB', (40, 40), BACKGROUND)
    px = img.load()
    for yy in range(40):
        for xx in range(40):
            x, y = X0 + xx, Y0 + yy
            c = BACKGROUND
            if not f['explo'] and WX <= x < WX + 32 and WY <= y < WY + 32:
                c = WINDOW
            if f['state'] == 1 and not f['ovr'] and SLICK[0] <= x <= SLICK[1] and SLICK[2] <= y <= SLICK[3]:
                c = SLICKC
            c = CODES.get(f['code'][yy][xx], c)
            px[xx, yy] = c
    return img.resize((40 * SCALE, 40 * SCALE), Image.NEAREST)


def main():
    frames = parse(sys.argv[1])
    w, h = 40 * SCALE + 6, 40 * SCALE + CAPTION
    rows = (len(frames) + COLS - 1) // COLS
    sheet = Image.new('RGB', (COLS * w, rows * h), (0, 0, 0))
    draw = ImageDraw.Draw(sheet)
    for i, f in enumerate(frames):
        x, y = (i % COLS) * w, (i // COLS) * h
        sheet.paste(tile(f), (x + 3, y))
        en = f['en'][WY - Y0][WX - X0]
        proms = ' '.join(f'PR{127 + k}' for k in range(4) if en >> k & 1) or 'none'
        label = 'OVERRIDE' if f['ovr'] else STATES[f['state']]
        draw.text((x + 3, y + 40 * SCALE + 1), f"{f['frame']} {label}", fill=(0xcc, 0xdd, 0xff))
        draw.text((x + 3, y + 40 * SCALE + 13), proms, fill=(0xff, 0xff, 0x44))
    sheet.save(sys.argv[2])
    print(f'{len(frames)} frames -> {sys.argv[2]}')


if __name__ == '__main__':
    main()
