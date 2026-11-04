#!/usr/bin/env python3
"""Independent plausibility checks on the sheet G player-car address mapping.

These checks use only the PROM dumps and properties of the artwork itself, not
the RTL: a drawn object occupies one contiguous band of lines (no empty band through
its middle), and hand-drawn artwork has fewer colour changes along a line when
pixels are read in the order the artist intended. A mirror-symmetry score is
reported for information only (the cockpit detail is not symmetric).

Mapping under test (docs/trace/SHEET_G_PLAYER.md):
  displayed row r = 0..31   -> line counter VC = 0x30 + r -> A4..A0 = VC[4:0]
  displayed col c = 0..31   -> pixel counter HC = 0x80 + c -> A7..A5 = HC[4:2]
  '153 select = HC[1:0]: pixel code = D[sel] | D[4+sel] << 1
Alternatives are evaluated with the same metrics so the result is a comparison,
not an assertion of the transcription against itself.
"""
import json
import sys
from pathlib import Path

ROMS = {'pra127': 'PR-127 (IC77)', 'pra128': 'PR-128 (IC84)',
        'pra129': 'PR-129 (IC91)', 'pra130': 'PR-130 (IC98)'}


def load(proms_bin):
    data = Path(proms_bin).read_bytes()
    ver = json.loads((Path(proms_bin).parent / 'verification.json').read_text())
    out = {}
    for r in ver['roms']:
        name = r['name'].split('.')[0]
        if name in ROMS:
            out[name] = data[r['offset']:r['offset'] + r['size']]
    return out


def image(rom, a8, row_addr, bit_order):
    img = []
    for r in range(32):
        line = []
        for c in range(32):
            a = (a8 << 8) | ((c >> 2) << 5) | row_addr(r)
            k = bit_order(c & 3)
            d = rom[a]
            line.append((d >> k & 1) | ((d >> (k + 4) & 1) << 1))
        img.append(line)
    return img


def mirror_score(img):
    """Best fraction of non-empty pixel pairs that match when mirroring rows
    about some axis (half-integer or integer), over all candidate axes."""
    best = (0.0, None)
    for twice_axis in range(8, 56):
        match = total = 0
        for r in range(32):
            m = twice_axis - r
            if 0 <= m < 32 and m != r:
                for c in range(32):
                    a, b = img[r][c], img[m][c]
                    if a or b:
                        total += 1
                        match += a == b
        if total > 200:
            s = match / total
            if s > best[0]:
                best = (s, twice_axis / 2)
    return best


def transitions(img):
    return sum(img[r][c] != img[r][c + 1] for r in range(32) for c in range(31))


def blank_band(img):
    """Longest run of completely empty rows strictly inside the occupied span."""
    occ = [any(v for v in row) for row in img]
    idx = [i for i, o in enumerate(occ) if o]
    if not idx:
        return 32
    run = best = 0
    for o in occ[idx[0]:idx[-1] + 1]:
        run = 0 if o else run + 1
        best = max(best, run)
    return best


def render(img):
    ch = '.123'
    return [''.join(ch[v] for v in row) for row in img]


def main():
    roms = load(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else None
    traced_rows = lambda r: (0x30 + r) & 31
    plain_rows = lambda r: r
    d0_first = lambda k: k
    d3_first = lambda k: 3 - k
    report = []
    ok = True
    for name, label in ROMS.items():
        for a8 in (0, 1):
            t = image(roms[name], a8, traced_rows, d0_first)
            p = image(roms[name], a8, plain_rows, d0_first)
            rev = image(roms[name], a8, traced_rows, d3_first)
            ms_t, ax_t = mirror_score(t)
            ms_p, ax_p = mirror_score(p)
            tr_t, tr_r = transitions(t), transitions(rev)
            band_t, band_p = blank_band(t), blank_band(p)
            report.append(f'{label} A8={a8}: mirror(traced rows)={ms_t:.3f} axis={ax_t} '
                          f'mirror(unswapped rows)={ms_p:.3f} axis={ax_p}; '
                          f'empty band traced={band_t} unswapped={band_p}; '
                          f'transitions D0-first={tr_t} D3-first={tr_r}')
            report.extend('    ' + s for s in render(t))
            # Every image must be one contiguous object under the traced row
            # order, and the straight-ahead car (PR-127) must visibly split
            # under the unswapped order (evidence for the VC 0x30..0x4F window).
            ok &= band_t == 0 and band_t <= band_p
            if name == 'pra127':
                ok &= band_p >= 8
            # Artwork is smoother along the line when read D0 first.
            ok &= tr_t < tr_r
    result = f'RESULT: {"PASS" if ok else "FAIL"}\n'
    # The renders go to the report file only.
    print('\n'.join(r for r in report if not r.startswith('    ')) + '\n' + result, end='')
    if out:
        out.write_text('\n'.join(report) + '\n' + result)
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
