# Sheet K — score display rank latches (96597-P, D-3/3)

Source: Sega **Monaco GP (420-0358)**, PDF page **24**, circled **K**,
manual 420-0358, PDF page 24, **10160 × 6624**, upright.
SHA-256: `5409e260ee934d8cdeb1a30a57d15c28859109c00e547fb38bcc0821b6f380b0`.
Title: **96597-P SCORE DISPLAY IC BOARD ASS'Y (D-3/3)**.

**Status, 1 November 2026:** all five columns, data labels, clock/clear
routes and unused-pin stubs reviewed on full-resolution source crops.
This consolidates the earlier trace; remaining source ambiguities are listed
below. The user confirmed 9A's fourth and fifth output pin numerals as
**10 and 12**, respectively (K-V01, 1 November 2026). No HDL or circuit modification is implied.

## Reading conventions and evidence

Coordinates are source pixels, `(x0,y0,x1,y1)`. Rounded/filleted corners
identify bus taps; a plain crossing is not a connection. Short unused pin
stubs are distinguished from nearby vertical rails. A clear connection is
a visual source reading, not a result inferred from expected operation.

The previous pass (kept as the working notes (not published)) used the schematic tools net extraction, which
merged several adjacent bus lines through lettering/smears. Those historical
results are not independent confirmation of the affected nodes. The current
pass used overlapping source crops and did not rerun that extractor.

| Crop box | Evidence |
|---|---|
| (1100,1350,2700,2300) | 16 data labels, circled I, staggered bus drops |
| (2100,2350,3100,3700) | 9A/8A/7A, all input/output labels and unused stubs |
| (3500,2400,4350,3700) | 9B/8B/7B |
| (5000,2400,5750,3750) | column 3, literal top label 9E, 8C/7C |
| (6450,2400,7250,3750) | 9D/8D/7D |
| (7950,2400,8800,3750) | 9E/8E/7E |
| (1080,3750,2700,4520) | LATCH CL, 11D sections, rank clock inputs |
| (2150,3410,2390,4160) | 1ST clock riser and faint interruptions |
| (2390,2500,2690,2680) | 9A output pin numerals; K-V01 review |

## Wiring-derived structure

Sixteen shared input nets arrive from **sheet I**: `D-1A…D-1D`,
`D-2A…D-2D`, `D-3A…D-3D`, `D-4A…D-4D`. Five columns of three **174**
packages store those same 16 bits independently. Their output labels are
`1ST-1A…1ST-4D` through `5TH-1A…5TH-4D`, all destined for **sheet J**.
Each column uses 16 of its 18 flip-flops.

The printed type and pin set identify the **74174**: active-low clear at
pin 1, clock at pin 9. Standard package supply pins 16/8 are **not drawn**;
those numbers are device context, not traced supply wires.

## Per-chip and per-bit connectivity

The following pin tables apply to each of the five explicitly listed
columns. `r` means the column's rank prefix (1ST, 2ND, 3RD, 4TH or 5TH).
Top/middle/bottom identify physical position, avoiding the duplicate `9E`
label. All input and output signal labels below are clear.

| Position | Data pin | Input from I | Q pin | Output to J |
|---|---:|---|---:|---|
| top | 3 | D-1A | 2 | r-1A |
| top | 4 | D-1B | 5 | r-1B |
| top | 6 | D-1C | 7 | r-1C |
| top | 11 | D-1D | 10 | r-1D |
| top | 13 | D-2A | 12 | r-2A |
| top | 14 | D-2B | 15 | r-2B |
| middle | 3 | D-2C | 2 | r-2C |
| middle | 4 | D-2D | 5 | r-2D |
| middle | 6 | D-3A | 7 | r-3A |
| middle | 11 | D-3B | 10 | r-3B |
| middle | 13 | D-3C | 12 | r-3C |
| middle | 14 | D-3D | 15 | r-3D |
| bottom | 3 | D-4A | 2 | r-4A |
| bottom | 4 | D-4B | 5 | r-4B |
| bottom | 6 | D-4C | 7 | r-4C |
| bottom | 11 | D-4D | 10 | r-4D |
| bottom | 13 | open stub | 12 | open stub |
| bottom | 14 | open stub | 15 | open stub |

**9A output numerals — K-V01 closed:** on 1 November 2026 the user
confirmed **4Q = pin 10** and **5Q = pin 12**. The routes are therefore
9A.10 → `1ST-1D` and 9A.12 → `1ST-2A`. These are human-confirmed source
readings, replacing the earlier uncertain glyph readings.

The bottom chips' pins **13 and 14 end before the nearby vertical rail** in
all five columns. They are not traced to /MR, CP or D-4D. Outputs 12 and 15
also end in open stubs. This corrects the earlier tentative /MR connection;
no added pull-up/pull-down is justified by this sheet.

| Column / rank | Top chip | Middle chip | Bottom chip | Common clock, all pin 9 | Common /MR, all pin 1 |
|---|---|---|---|---|---|
| 1 / 1ST | 9A | 8A | 7A | 1ST (I), faint riser: U3 | 11D.2 |
| 2 / 2ND | 9B | 8B | 7B | 2ND (I) | 11D.2 |
| 3 / 3RD | **9E as printed** | 8C | 7C | 3RD (I) | 11D.2 |
| 4 / 4TH | 9D | 8D | 7D | 4TH (I) | 11D.4 |
| 5 / 5TH | 9E | 8E | 7E | 5TH (I) | 11D.4 |

The data bus continues through all five columns. Each input tap changes
from a horizontal bus to its own vertical drop and then the appropriate
chip input. Crossing a different data row en route does not join it.

## Clear and clock logic

**11D**, printed `04`, has two drawn inverter sections with output bubbles:

| Section | Input | Output destination | Confidence |
|---|---|---|---|
| 1 → 2 | LATCH CL (I) | pin 1 of all nine packages in columns 1–3 | clear |
| 3 → 4 | same LATCH CL branch | pin 1 of all six packages in columns 4–5 | clear |

The branch to both inputs is visible near `(1735,3905)`. The two inverter
outputs are separate clear nets; they are not tied together. The rank
clock risers cross these horizontal clear lines without junction dots.
Unused 11D sections and its supply pins are not drawn.

Each rank clock rises from its named input to the pin-9 stubs of the three
packages in that column. **1ST** has faint/broken ink on the riser near 7A;
its aligned corner, riser and pin stubs support the route, but uninterrupted
ink cannot be claimed throughout (U3). The other four routes are clear.

Function from the drawn gates and device pinout: high **LATCH CL** produces
low /MR on both groups and clears all ranks. With clear inactive, each
rank captures the shared data on its own positive clock edge.

## Off-sheet interface and omitted items

| Signal group | Direction | Source/destination |
|---|---|---|
| D-1A…D-4D (16 wires) | input | circled I → all five columns |
| LATCH CL | input | circled I → 11D.1 and .3 |
| 1ST, 2ND, 3RD, 4TH, 5TH | input | circled I → corresponding clock riser |
| 1ST-1A…1ST-4D (16 wires) | output | column 1 → circled J |
| 2ND-1A…2ND-4D (16 wires) | output | column 2 → circled J |
| 3RD-1A…3RD-4D (16 wires) | output | column 3 → circled J |
| 4TH-1A…4TH-4D (16 wires) | output | column 4 → circled J |
| 5TH-1A…5TH-4D (16 wires) | output | column 5 → circled J |

The source circles are serifed **I**, not an unresolved numeric source.
The rank outputs match J's first five 74151 input rows. No physical
connector pin numbers, resistors, capacitors or explicit supply rails are
drawn on K. Their absence must not be filled from the standard pinout.

## Unresolved and review history

- **U1 — duplicate top designator.** Column 3 clearly says **9E**;
  column 5 also says **9E**. Column 3's neighbours suggest an editorial
  `9C`, but that correction is not adopted. Identify it as “column-3 top,
  printed 9E” until board evidence settles the intended designation.
- **U3 — 1ST riser ink gaps.** Route recorded with the qualification above;
  a better scan or board continuity evidence would remove the remaining
  source limitation. Do not bridge any unrelated net from proximity.
- **K-V01 — closed, user review, 1 November 2026.** 9A fourth/fifth Q
  output pin numerals confirmed as **10 and 12**, respectively.
- Earlier **U2** (unused-input tie) is closed as **open stubs** after
  inspecting all five bottom packages. Earlier **U4** (source letter) is
  closed as **I**. Historical extractor merges are not adopted as joins.

## KiCad comparison — refreshed 1 November 2026

Read-only reference: `stonedDiscord/MonacoGP`, commit
`12e879b3f63b57536b461df947efa8aa86e69157` (7 February 2026).
The repository contains Main, Video, Sound and LED projects; **no 96597-P
score logic project or 74174 rank-latch sheet is present**. The LED schematic
contains display packages and connectors, not K's storage logic. Therefore
KiCad supplies no corroborating or conflicting connection for this sheet.
This is an unavailable comparison, not a successful netlist validation.
The earlier 23 October comparison reached the same coverage limitation.

## Review against the scan — 1 November 2026

This consolidated trace (prepared with ChatGPT, user readings K-V01) was
checked on fresh crops of `page24-sheet-K-score.png` by a second reader.
The first pass is kept unchanged as the working notes (not published); the review crops
and their coordinates are in the working notes (not published).

Confirmed on the scan:

- Column 1 in full: the sixteen staggered drops D-1A…D-4D into 9A/8A/7A
  pins 3,4,6,11,13,14 / 3,4,6,11,13,14 / 3,4,6,11, and the output routes.
  9A.12 and 9A.15 jog right to 1ST-2A and 1ST-2B; 8A.2 and 8A.5 jog up to
  1ST-2C and 1ST-2D. The jogs cross without joining.
- 7A pins 13 and 14: the stubs stop about 20 px short of the nearest
  vertical, which is the 1ST clock riser, not /MR. They are open, as this
  trace says; the first pass's "tied to /MR" (U2) was wrong. Outputs 12
  and 15 are open stubs. This has no effect on the logic.
- 11D.2 joins the /MR rails of columns 1–3 (upper horizontal, dots at
  columns 2 and 3); 11D.4 joins columns 4–5 (lower horizontal).
- Column 3's top package is printed **9E**, clearly an E (U1 stands).
- U3: the 1ST riser is faint between 8A pin 9 and 7A; 7A pin 9 turns
  down onto the same vertical, so the route stands as read.

Interface check with the other traces: sheet I sends 1ST…5TH (10A, 74259
Q0–Q4) and LATCH CL. to circled K, and its P-bus order (P-1 = units,
`jtmonacogp_score.v`) agrees with sheet J's column map, so D-1x here is the
units digit and D-4x the thousands digit.
