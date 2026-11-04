#!/usr/bin/env python3
"""Check the simulated sheet G player-car raster against expectations built
from the PROM dumps, independently of the RTL and of the reference netlist.

Input: player-frames.txt written by tests/tb_player.v. For each frame it holds
the region x=160..199, y=100..139 as pairs of characters: the output code
(1 = /PLAYER BODY, 2 = /PLAYER TIRE, 3 = /PLAYER (BL), 0 = none) and the
enabled PROMs as a hex digit (bit 0 = PR127 ... bit 3 = PR130).

1. Data path, every frame and pixel: the code must equal the traced
   address/bit mapping applied to the PROM bytes of the enabled PROMs, inside
   the 32x32 window x=164..195, y=104..135 only, and nothing while EXPLO.ST is
   high. Several enabled PROMs combine as a wired AND (stated assumption).
2. Selection, frames without test overrides: normal -> PR127 (A8 = Vs/4);
   accident -> PR129 or PR130 by Vs/16 (A8 = Vs/8); explosion -> no car;
   slide -> PR128 from the first pixel where the car body meets the oil-slick
   patch by the 74123 function table, until 0.1336 s (data-sheet formula)
   after the last such pixel.
3. Artwork semantics (no simulation involved):
   - PR127's A8 (Vs/4) must change only tyre pixels (codes 2/3), never body.
   - The accident sequence in frame-counter order (Vs/16, Vs/8) = 00, 01, 10,
     11 must turn the car monotonically in roughly 45 degree steps. Swapping
     the roles of Vs/8 and Vs/16 would give 0, 90, 45, 135 degrees instead.
   - PR128's two images must be yawed to opposite sides by less than 35 degrees.
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import player_image_checks as pic  # noqa: E402

LINE, FRAME_PIXELS = 456, 456 * 264
TW_PIXELS = 0.28 * 47.0 * 1.0e7 * (1 + 0.7 / 47.0) * 1e-9 * 7152500  # IC119
X0, Y0, WX, WY = 160, 100, 164, 104      # dump origin, window origin
SLICK = (166, 171, 116, 121)              # x0, x1, y0, y1 (jtmonacogp_ptest.v)
NAMES = ('pra127', 'pra128', 'pra129', 'pra130')


def car(roms, name, a8):
    return pic.image(roms[name], a8, lambda r: (0x30 + r) & 31, lambda k: k)


def when(frame, x, y):
    """Pixel count from the start of the run. A frame starts at the end of VS
    (V=$1F8, H=$1E0); active line y is line y+16 of the frame and x is pixel
    32+x of its line (docs/TIMING.md)."""
    return frame * FRAME_PIXELS + (y + 16) * LINE + 32 + x


def parse(path):
    frames, cur = [], None
    for line in Path(path).read_text().splitlines():
        if line.startswith('FRAME'):
            f = line.split()
            cur = {'frame': int(f[1]), 'state': int(f[3]), 'vs': f[5],
                   'ovr': f[7] == '1', 'explo': f[9] == '1', 'code': [], 'en': []}
            frames.append(cur)
        else:
            cur['code'].append([int(line[i]) for i in range(0, len(line), 2)])
            cur['en'].append([int(line[i], 16) for i in range(1, len(line), 2)])
    return frames


def angle(img):
    pts = [(r, c) for r in range(32) for c in range(32) if img[r][c]]
    n = len(pts)
    mr = sum(r for r, _ in pts) / n
    mc = sum(c for _, c in pts) / n
    srr = sum((r - mr) ** 2 for r, _ in pts) / n
    scc = sum((c - mc) ** 2 for _, c in pts) / n
    src = sum((r - mr) * (c - mc) for r, c in pts) / n
    return math.degrees(0.5 * math.atan2(2 * src, scc - srr))


def semantic_checks(roms, report):
    ok = True
    a, b = car(roms, 'pra127', 0), car(roms, 'pra127', 1)
    changed = [(a[r][c], b[r][c]) for r in range(32) for c in range(32) if a[r][c] != b[r][c]]
    body = sum(1 for x, y in changed if 1 in (x, y))
    report.append(f'PR127 Vs/4 animation: {len(changed)} pixels change, {body} of them body pixels')
    ok &= body == 0 and len(changed) > 0
    seq = [('pra129', 0), ('pra129', 1), ('pra130', 0), ('pra130', 1)]
    ang = [angle(car(roms, n, a8)) for n, a8 in seq]
    steps = [((ang[(i + 1) % 4] - ang[i] + 90) % 180) - 90 for i in range(4)]
    report.append('Accident sequence axis angles: ' + ', '.join(f'{x:.1f}' for x in ang) +
                  '; steps ' + ', '.join(f'{x:+.1f}' for x in steps))
    ok &= all(25 <= s <= 65 for s in steps) or all(-65 <= s <= -25 for s in steps)
    swapped = [ang[0], ang[2], ang[1], ang[3]]
    sw = [((swapped[(i + 1) % 4] - swapped[i] + 90) % 180) - 90 for i in range(4)]
    report.append('  with Vs/8 and Vs/16 swapped the steps would be ' +
                  ', '.join(f'{x:+.1f}' for x in sw))
    straight = angle(a)
    y0, y1 = (angle(car(roms, 'pra128', k)) - straight for k in (0, 1))
    report.append(f'PR128 yaw relative to PR127: {y0:+.1f}, {y1:+.1f} degrees')
    ok &= y0 * y1 < 0 and max(abs(y0), abs(y1)) < 35
    return ok


def expected_code(roms, f, x, y, en):
    r, c = y - WY, x - WX
    if f['explo'] or not (0 <= r < 32 and 0 <= c < 32):
        return 0
    vs4, vs8 = int(f['vs'][0]), int(f['vs'][1])
    bus = 0xff
    for i, name in enumerate(NAMES):
        if en >> i & 1:
            a8 = vs4 if i == 0 else vs8
            bus &= roms[name][(a8 << 8) | ((c >> 2) << 5) | ((0x30 + r) & 31)]
    k = c & 3
    return (bus >> k & 1) | (bus >> (k + 4) & 1) << 1


def slide_triggers(f):
    """74123 A/B triggers inside the slick, A settling before B: A falls with
    the previous pixel's B high, or B rises while A is low (B = body pixel)."""
    x0, x1, y0, y1 = SLICK
    hits = []
    for y in range(y0, y1 + 1):
        row = f['code'][y - Y0]
        body = lambda x: row[x - X0] == 1
        for x in range(x0, x1 + 1):
            if (x == x0 and body(x - 1)) or (body(x) and not body(x - 1)):
                hits.append(when(f['frame'], x, y))
    return hits


def main():
    roms = pic.load(sys.argv[1])
    frames = parse(sys.argv[2])
    out = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    report, ok = [], True
    counts, pixels = {}, 0
    # 1. Data path
    for f in frames:
        if len(f['code']) != 40 or any(len(r) != 40 for r in f['code']):
            report.append(f"frame {f['frame']}: incomplete dump")
            ok = False
            continue
        bad = 0
        for yy in range(40):
            for xx in range(40):
                pixels += 1
                bad += f['code'][yy][xx] != expected_code(roms, f, X0 + xx, Y0 + yy, f['en'][yy][xx])
        if bad:
            ok = False
            report.append(f"frame {f['frame']}: {bad} pixels differ from the PROM data")
    report.append(f'Data path: {pixels} pixels in {len(frames)} frames checked against the PROM bytes')
    # 2. Selection
    last_trigger = None
    for f in frames:
        if f['ovr'] or len(f['code']) != 40:
            counts['override segment (data path only)'] = counts.get('override segment (data path only)', 0) + 1
            continue
        vs4, vs8, vs16 = (int(f['vs'][i]) for i in range(3))
        triggers = slide_triggers(f) if f['state'] == 1 else []
        bad = 0
        for yy in range(40):
            for xx in range(40):
                x, y, en = X0 + xx, Y0 + yy, f['en'][yy][xx]
                t = when(f['frame'], x, y)
                if f['state'] == 2:
                    want = {8 if vs16 else 4}
                elif f['state'] == 3:
                    want = {1}
                else:
                    past = [p for p in triggers if p <= t]
                    held = past or (last_trigger is not None and t - last_trigger < TW_PIXELS)
                    near = last_trigger is not None and abs(t - last_trigger - TW_PIXELS) <= 3
                    want = {2} if held and not near else {1, 2} if near else {1}
                bad += en not in want
        if triggers:
            last_trigger = triggers[-1]
        if f['state'] == 1 and not triggers:
            report.append(f"frame {f['frame']}: the car body never met the slick")
            ok = False
        label = ['normal', 'slide', 'accident', 'explosion'][f['state']]
        sel = sorted({e for row in f['en'] for e in row})
        key = f"{label}: enables {'/'.join(format(e, '04b') for e in sel)}"
        if f['state'] == 1 and triggers:
            yt, xt = divmod(triggers[0] - f['frame'] * FRAME_PIXELS - 32 - 16 * LINE, LINE)
            key += f' (first slick trigger x={xt} y={yt})'
        counts[key] = counts.get(key, 0) + 1
        if bad:
            ok = False
            report.append(f"frame {f['frame']} ({label}): {bad} pixels with an unexpected PROM enable")
    for k in sorted(counts):
        report.append(f'{counts[k]:3d} frames  {k}')
    accident = {(int(f['vs'][1]), int(f['vs'][2])) for f in frames if f['state'] == 2 and not f['ovr']}
    if accident != {(0, 0), (0, 1), (1, 0), (1, 1)}:
        report.append(f'accident sequence not fully exercised: {sorted(accident)}')
        ok = False
    # 3. Artwork
    ok &= semantic_checks(roms, report)
    text = '\n'.join(report) + f'\nRESULT: {"PASS" if ok else "FAIL"}\n'
    print(text, end='')
    if out:
        out.write_text(text)
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
