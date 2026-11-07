# Timing transcription — 96578-P, sheet E

Reference: supplied Sega service manual **Monaco GP (420-0358)**, physical PDF
page **32**, drawing E, global sheet 5/13, board B sheet D4/5. Page numbers here
count the cover as page 1. The compact RTL models settled digital states. It is
not a gate-delay or analog simulation of the original board.

The pin-level trace of this sheet, with every pad and output, is
[trace/SHEET_E_TRACE.md](trace/SHEET_E_TRACE.md).

## Horizontal path

| Component / pins | Transcribed connection |
|---|---|
| IC108, 74161 | Q A..D = H0..H3; P=T=1; clock from the divided crystal |
| IC108, A..D | 0, 0, 0, horizontal blanking latch |
| IC107, 74161 | Q A..D = H4..H7; P=IC108 carry, T=1 |
| IC107, A..D | blanking latch, its inverse, 0, 1 |
| IC115, pins 11/9/10 → 8 | NAND of IC108 carry, IC107 carry, H8; drives both /LOAD inputs |
| IC116 first 74107 half | CP12=IC107 carry; J1=/blank; K4=blank; /CLR13=1; Q3=H8 |
| IC116 second half | CP9=IC107 carry; J8, K11 and /CLR10 all on the H8 node; Q5=blank (labelled H_B) |
| IC115, pins 3/4/5 → 6 | NAND of /H5, H6, blank; generates /HS |
| IC95 | AND section with pin 1 at Vcc: buffers /HS to pad FJ and the (B)(D)(M) arrow (corrected 26 Oct 2026; it does not invert) |

The 74107 responds to the falling carry edge. Both halves see that edge; the
second half is also asynchronously cleared when the first half's H8 goes low.
This is why a conventional modulo-456 counter would lose useful original H-net
values even if it produced the right frame rate.

Correction (review of `horizontal-reload.png`, 15 Oct 2026): the milestone table
listed K11 as /H8. The scan draws pins 8, 10 and 11 on one vertical node fed by
the first half's Q3 (H8). The settled sequence is unchanged: with old H8=1 the
second half toggles (J=K=1), which sets blank from 0 or clears it from 1; when
H8 falls at the same edge, /CLR forces 0 either way. The TTL reference now uses
the scan reading and still matches the RTL on every settled state.

The same review re-traced the HS inputs on `horizontal-sync.png`: IC114 pin 11
is driven by IC107 QB (H5) and its pin 10 output (/H5) runs to IC115 pin 3; IC107
QC (H6) runs to IC115 pin 4. HS = HB·/H5·H6 is therefore as transcribed.

The repeating sequence is:

1. H=$098 through $1FF, blank latch=0: **360 clocks**.
2. H reloads to $1A0; blank latch becomes 1.
3. H=$1A0 through $1FF, blank latch=1: **96 clocks**.
4. H reloads to $098; H8 falls and clears the blank latch.

During blanking, `H6 AND NOT H5` is true for H=$1C0..$1DF: **32 clocks of HS**.
Normalized display positions are active 0..359, front porch 360..391,
sync 392..423, back porch 424..455.

Reference crops: [reload](source-excerpts/horizontal-reload.png),
[sync decode](source-excerpts/horizontal-sync.png).

## Vertical path

| Component / pins | Transcribed connection |
|---|---|
| IC102, 74161 | Q A..D = V0..V3; P=T=1; CP sees /HS |
| IC102, A..D | 0, 0, 0, V8 |
| IC100, 74161 | Q A..D = V4..V7; P=1, T=IC102 carry |
| IC100, A..D | /V8 on all four inputs |
| IC93 inverter | IC100 carry inverted to both /LOAD inputs |
| IC109 remaining 74107 half | CP12=IC100 carry; J=K=1; Q3=V8 |
| IC115, pins 13/1/2 → 12 | NAND of /V3, V2, V8; generates /VS |
| IC101 blanking logic | Blanks V8=1 and the all-zero V7..V4 interval, plus horizontal blanking |

The vertical counter advances at the **end of HS**, the rising edge of /HS.
At a low-byte terminal count, the old V8 determines the parallel load:

- Old V8=0: load $F0 into the low byte; V8 toggles to 1 → V=$1F0.
- Old V8=1: load $08 into the low byte; V8 toggles to 0 → V=$008.

The sequence V=$008..$0FF (248 lines), then $1F0..$1FF (16 lines), totals
**264 lines**. V=$010..$0FF is active: **240 lines**. VS is active at
V=$1F4..$1F7: **four lines**. In display order this gives 240 active lines,
four front-porch lines, four sync lines and sixteen back-porch lines.

Reference crop: [vertical logic](source-excerpts/vertical-logic.png).

## Crystal and implementation qualifications

The X1 annotation appears to read **14.305** in the scan; the two outgoing
frequency labels are only “14 MHz” and “7 MHz”. The exact crystal frequency is
**not independently confirmed**. The provisional parameter is 14,305,000 Hz,
divided by two, yielding 7,152,500 pixel clocks/s and approximately 59.414 Hz.
The scan excerpt is included [here](source-excerpts/crystal.png) for review.

Update, 22 October 2026: photos of a real later-revision video board
(97092-P, dated 800602) in github.com/stonedDiscord/MonacoGP show the crystal
can marked **14.305**, matching the scan reading. This is a photo of one board
of the later revision, not a frequency measurement.

## Comparison with an independent redraw, 22 October 2026

stonedDiscord's KiCad netlist of the video board agrees with every connection
in the tables above: the H and V counters, their load values and enables, both
IC116 halves, IC109, IC93, and the IC115 load, HS and VS gates. Two
differences, both errors in the redraw:

- It joins V8 and H8 into one net.
- It uses a 74LS20 (NAND) for IC101 pins 9, 10, 12, 13 -> 8. The scan
  ([vertical logic](source-excerpts/vertical-logic.png)) draws an AND body with
  inverted inputs, a NOR that is high when V7..V4 are all zero, as implemented.
  The redraw makes the same NAND-for-NOR substitution for sheet G IC57.

The current implementation uses an accumulator at the framework's 48 MHz clock.
There are exactly 1,430,500 master enables and 715,250 pixel enables per
4,800,000 host cycles. Pixel intervals alternate between six and seven host
cycles. This preserves the average rate, **not** the original crystal's uniform
period. Dedicated PLL work and a MiSTer output test remain before claiming
hardware timing fidelity.

The enable generator has no reset and runs from configuration, like the X1
oscillator it stands for. This is required by JTFRAME: without
`JTFRAME_PXLCLK`, the core's own `pxl_cen` drives `jtframe_reset`, which
releases the game reset only after counting pixel enables. Until 18 October
2026 the generator was held in reset by the game reset, so the reset never
released and the MiSTer received no video. `tests/tb_board.v` (run by
`scripts/check_jtframe.py`) checks the release through the pinned JTFRAME
modules.

The H/V counters in `jtmonacogp_timing` still start from a fixed state under
the game reset, so the video stops while JTFRAME holds the game in reset (at
power-up and during an MRA load). JTFRAME's `jtframe_resync` then needs a few
frames to settle, and a CRT may roll briefly. The original counters have no
global reset; letting them run through the reset is listed in
[CIRCUIT_STATUS.md](CIRCUIT_STATUS.md).

The TTL reference test checks every settled H/V counter value, blank signal and
sync signal against a separately connected chip model over 361,152 pixels.
Its short simulation delays establish event ordering; they are not datasheet
minimum/maximum propagation delays. Both models share the same schematic
transcription, so their agreement can expose implementation errors but cannot
prove a misread wire or crystal annotation correct.

The RTL reset deliberately enters the stable sequence at H=$098, V=$010.
Original power-on transients, capacitor pulse shaping (C14/C19/C8/C13 etc.),
composite-sync gate propagation and analog output behavior are not reproduced.
HS/VS use the positive pulse convention expected by JTFRAME; blank enables are
high during the active display.

MAME's Monaco GP source is useful for PROM identity, but its video timing is
explicitly a placeholder copied from Pong. Its 454/262 timing constants were
not used to construct this implementation.
