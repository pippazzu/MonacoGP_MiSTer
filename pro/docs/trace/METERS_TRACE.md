# Pro cabinet meters: Driving Meter and Tacho Meter

Date: 2026-11-06. Issue #87. Trace of the two front-panel meters of Sega
420-0525 (Pro Monaco GP): where each is wired on the cabinet drawing and what
drives it.

## Result in brief

- **Tacho Meter (S-96635): traced.** On PDF page 7 it is wired between pins
  **H** and **7** of the sound board **96598-P OSCILLATOR, MONACO GP**, and
  to nothing else. The Pro PDF has no sound board sheets; the parts list
  names the same board as the original, whose sheet D-3/7 (original manual
  420-0358, PDF page 17) shows pin H as the output of an LM324 follower of
  the engine sound's control voltage, labelled `回転計へ` ("to the
  tachometer"), and pin 7 as an open-collector inverter output driven by
  MY CAR SOUND ON. So the needle follows the engine note's control voltage
  (player speed code S-ACCE A–D, smoothed by the lag network, scaled down in
  high gear), and the meter circuit is open while the engine sound is off.
- **Driving Meter (S-96636): no drive is drawn on any sheet.** It appears
  only in the parts list (PDF page 4, front panel item 4). The cabinet
  wiring on page 7 has no Driving Meter, and none of the logic sheets
  (pages 8–20) has a pad or label for one. What it shows, and whether it is
  wired at all, the drawings do not say.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf` (SHA-256 `9473d6dd…32f2`).
  - PDF page 4 (parts list "FRONT PANEL & HANDLE ASSY", printed page 18) and
    page 3 ("CABINET ACCESSORY ASSY", printed page 17), read from the PDF
    text layer and checked on a render.
  - PDF page 7 (cabinet wiring, drawing SOB-2676, "SEGA PRO MONACO GP
    UPRIGHT MODEL (AC100V~240V) (50/60Hz)"). The page is stored portrait
    (5100 × 6651 at scale 1) with the drawing on its side, so it was
    rendered with PyMuPDF at `Matrix(1, 1).prerotate(90)`: **6651 × 5100**
    pixels, title block at bottom right. **Every page-7 box below is
    (left, top, right, bottom) on that rotated scale-1 render.**
  - Pages 8–20 (all logic sheets) rendered whole at scale 0.16 and searched
    by eye for any meter label or pad.
- Original: `schematics/pages/page17-sound-D3.png` (420-0358 page 17, sheet
  D-3/7 of board 96598-P, 10160 px wide, upright); boxes are on that PNG.
  Original traces cited: `docs/trace/SOUND_D3_TRACE.md`,
  `docs/trace/SOUND_D4_TRACE.md`, `docs/SOUND_LOGIC.md`,
  `docs/trace/SHEET_F_TRACE.md`.
- Reading rules from `pro/README.md`. Confidence: **clear**, **probable**,
  **uncertain**.
- No MAME, emulator, other core, fan remake, footage or gameplay
  description was used. Nothing about what either meter displays is taken
  from anywhere but the drawings and the parts lists.

### Crops

| Page | Box | Content |
|---|---|---|
| 7 (rotated) | (2400, 2560, 3600, 2860) | TACHO METER and its two wires to 96598-P pins 7 and H |
| 7 (rotated) | (2270, 1800, 4130, 2930) | 96598-P outline: SOUND VR, power amp, tacho, connector rows |
| 7 (rotated) | (3560, 2150, 4120, 2600) | 96598-P to 96822-P rows, S-ACCE check |
| 7 (rotated) | (200, 300, 1900, 1700); (1900, 300, 3600, 1700); (3600, 300, 5300, 1700); (5200, 300, 6651, 1700) | top band: mains, regulators, PANEL LAMP, COIN METER, switches, battery |
| 7 (rotated) | (200, 1600, 1900, 3000); (3500, 1600, 5300, 3000); (5200, 1600, 6651, 3000) | middle band: DIP and coin options, board A rows, score boards |
| 7 (rotated) | (200, 2900, 1900, 4300); (1900, 2900, 3600, 4300); (3500, 2900, 5300, 4300); (5200, 2900, 6651, 4300) | lower band: transformers, colour display, PC-1206, board B, TIME and score lamps |
| 7 (rotated) | (200, 4200, 1900, 5100); (1900, 4200, 3600, 5100) | bottom band: power transformer, PC-1207 |
| orig. p17 | (3900, 4000, 5600, 5400) | IC49 14 to pad H `回転計へ`; IC47 5 → 6 to pad 7 |
| orig. p17 | (300, 4300, 4300, 5500) | MY CAR SOUND ON (D-4/7), R417, IC47.5 |
| orig. p17 | (4400, 5250, 8700, 6300) | parts tally and the tachometer note |

## Parts lists

| PDF page | List | Item | Part No. | Description | Confidence |
|---|---|---|---|---|---|
| 4 | Front Panel & Handle Assy | 4 | S-96636 | Driving Meter | clear |
| 4 | Front Panel & Handle Assy | 9 | S-96635 | Tacho Meter | clear |
| 3 | Cabinet Accessory Assy | 10 | 96598-P | Oscillator, Monaco GP | clear |

The front-panel drawing on page 4 shows two round gauges, one either side of
the wheel. The item 4 and item 9 leaders point at the panel's side view, and
which gauge is which was not settled from the drawing (uncertain). No list
gives a meter range, scale or rating. The original D-3/7 note (below) is the
only rating on any drawing.

## Tacho Meter (S-96635)

### Page 7 wiring

| Item | Reading | Confidence |
|---|---|---|
| Label | `TACHO METER` over a circle containing `A` (the drawing's meter symbol) | clear |
| Meter terminals | two open-circle terminals, **B** (west) and **A** (east) | clear |
| Terminal A | east along one wire, through a wire-colour box, to **96598-P pin 7** | clear |
| Terminal B | west, down and back east under the meter, through a wire-colour box, to **96598-P pin H** | clear |
| Wire colour codes | two boxes; glyphs illegible on the scan (the first reads like `C?1`) | uncertain |
| Other connections | none: no junction dot on either wire, no series part, no lamp drawn with the meter | clear |
| Board | pins 7 and H sit on the right edge of the dashed 96598-P outline, the same side as its pin 13 (SOUND VR) and the S-ACCE rows; the label `96598-P OSCILLATOR, MONACO GP` runs vertically beside them | clear |

### Cross-check: S-ACCE reaches the sound board

The rows between 96598-P and 96822-P (board A) on page 7, box
(3560, 2150, 4120, 2600):

| 96598-P pin | 96822-P pin | Original D-3/7 pad meaning | Pro sheet F pad meaning | Confidence |
|---|---|---|---|---|
| E | P (AP) | S-ACCE A | S-ACCE A, pad AP | probable (small glyphs) |
| 5 | 13 (A13) | S-ACCE B | S-ACCE B, pad A13 | probable |
| F | N (AN) | S-ACCE C | S-ACCE C, pad AN | probable |
| 6 | 12 (A12) | S-ACCE D | S-ACCE D, pad A12 | probable |

So the Pro cabinet carries the player speed bits from board A (sheet F,
page 9: the `17×6` buffers to pads A12, AN, A13, AP, as on the original) to
the sound-board pads the original D-3/7 uses for its DAC. The other 96598-P
rows were not transcribed.

### What drives pins H and 7 (original sheet D-3/7)

The Pro manual has no sound-board sheets; `pro/README.md` and the page 3
parts list name the original board 96598-P, drawn in the original manual's
D-3/7. Whether Pro's 96598-P is the drawn revision is not shown by either
manual (M-U2).

| Node | Reading on original p17 | Confidence |
|---|---|---|
| Pad H | IC49 (LM324) 14, a follower (13 tied to 14) with input 12 on the CV bus; the pad is labelled `回転計へ`, "to the tachometer" | clear (re-read; agrees with `SOUND_D3_TRACE.md`) |
| Pad 7 | IC47 5 → 6, an inverter with output bubble and the open-collector slash (package noted "06 OR 16" in `SOUND_D3_TRACE.md`); output straight to pad 7, nothing else on the net | clear (re-read) |
| IC47.5 | MY CAR SOUND ON from D-4/7 (`Hで ON`, active high), R417 470 Ω pull-up to Vcc; the same line feeds IC57 13 → 12 | clear (re-read) |
| Note, bottom right | heading `回転計内部` ("inside the tachometer"), a sketch of a **15 kΩ** resistor in series with a meter symbol marked **750 µA**, and `メーター類のランプは12V AC又はDC` ("the meters' lamps are 12 V AC or DC") | clear text; that the 15 kΩ is inside the meter assembly is probable (the sketch sits under that heading) |

The CV bus, from `SOUND_D3_TRACE.md` ("Complete CV distribution") and
`SOUND_LOGIC.md` (D-3/7, steps 1–3): S-ACCE A–D → open-collector buffers →
weighted DAC (390K, 220K, 100K, 51K; R298 390K to 12 V) → IC49 follower →
lag (C62 47 µF; R300 150K, plus R302 68K through the 4016 while S-ACCE D is
low, and D21 + R299 33K back to the follower) → IC50 follower → R303 220K /
R301 470K divider to the SHIFT A inverter (about 0.68 while SHIFT A is high)
→ IC50 follower = CV → IC49 12 → 14 → pad H.

MY CAR SOUND ON is made on D-4/7 by IC60 b = NOR(60a, /COIN IN), with
60a = NOR(/S-ACC1, /GAME) (`SOUND_D4_TRACE.md`; `SOUND_LOGIC.md`, "D-4/7
control gates"). `SOUND_LOGIC.md` summarises it: during a game the engine
sound plays unless the car has crashed, and it is off before a coin.

### What the Tacho Meter shows (from the wiring)

- Current flows H → meter (B to A) → pin 7 → IC47.6 → ground only while
  IC47.6 sinks, that is while MY CAR SOUND ON is high. When it is low the
  open-collector output is off, the meter circuit is open and the needle
  rests at zero. The tacho and the engine sound are switched by the same
  signal. **Clear from the wiring.**
- While it is on, the meter current is CV over the series resistance, so
  the needle follows the engine note's control voltage: it rises with the
  player speed code S-ACCE (0–15, binary-weighted DAC), moves with the C62
  lag rather than in steps, and drops to about 0.68 of the value while
  SHIFT A is high (high gear). A higher reading goes with a higher engine
  pitch. **Clear from the wiring; the 0.68 factor is the resistor ratio
  computed in `SOUND_LOGIC.md`.**
- Scale, estimate only: with 15 kΩ in series, 750 µA corresponds to
  11.25 V. `SOUND_LOGIC.md` gives the CV ceiling as about 10.5 V (the
  LM324's high output under load, a model figure, not drawn). Ignoring the
  meter coil's resistance and IC47's low-level voltage, the needle would
  reach about 90 % of full scale at the top code in low gear and about 60 %
  in high gear. **Derived estimate, uncertain**: the coil resistance, the
  meter's printed scale and the inverter's low level are on no drawing.
- The D-3/7 note says the meters have 12 V lamps, but no meter lamp is
  drawn on page 7. Page 7 does draw a **PANEL LAMP** on DC 5V UNREG (box
  (1900, 300, 3600, 1700)); nothing on the drawing ties it to the meters.
  **Not connected by the drawing; not assumed.**

## Driving Meter (S-96636)

| Where looked | Finding | Confidence |
|---|---|---|
| PDF page 4, parts list | listed: item 4, S-96636, Driving Meter | clear |
| PDF page 7, cabinet wiring, whole page (tiles above) | no item labelled DRIVING METER; the only meters drawn are TACHO METER and COIN METER (board A pin 9, coil from DC 5V with a diode across it) | clear for the drawn labels |
| PDF pages 8–20, all logic sheets, whole pages at scale 0.16 | no pad or label naming a meter other than COIN METER on sheet A (pad A9, TR1) | probable: read at reduced resolution, so a small label could have been missed; but any board output would also have to be wired on page 7, and nothing there goes to a Driving Meter |
| Original D-3/7 note | `メーター類` ("the meters", plural) in the lamp note | clear text; says nothing about the Driving Meter's drive |

**The Driving Meter's drive is not on any sheet of 420-0525.** The drawings
do not say whether it is driven electrically, from which signal, or what it
shows. Nothing is inferred here from its name.

## For the core

- The tacho can be derived from the existing sound model's CV
  (`tests/sound/d3_model.py`, `SOUND_LOGIC.md` step 3) gated by MY CAR SOUND
  ON, with no new board logic. How a core presents it (an on-screen gauge,
  an output) is a presentation choice, not hardware.
- No Driving Meter behaviour can be implemented from the schematics.

## Still uncertain

| ID | Question | What would settle it |
|---|---|---|
| M-U1 | Wire colour codes on the two tacho wires | a cleaner scan of page 7, or the harness |
| M-U2 | Whether Pro's 96598-P is the drawn revision of D-3/7 (pads H/7 and the CV follower) | a Pro sound-board drawing or a board photo; the part number is the same |
| M-U3 | Whether the 15 kΩ is inside the meter (as the note's heading suggests) or a separate resistor; the meter's coil resistance and printed scale | the meter itself, or its Sega drawing |
| M-U4 | What the Driving Meter is, whether it is wired, and what it shows | the cabinet, a later revision of the wiring drawing, or the meter's own drawing |
| M-U5 | Which of the two round panel gauges on page 4 is item 4 and which is item 9 | a larger scan of page 4, or the cabinet |
| M-U6 | Where the meters' 12 V lamps are wired; whether PANEL LAMP on page 7 is one of them | the cabinet or harness |

## Not checked

- The logic sheets were searched for meter labels at reduced resolution
  only, not read pin by pin.
- The original manual's own cabinet wiring was not looked at, so whether the
  original Monaco GP cabinet also had a tacho on these pins is not
  established here.
- The other 96598-P to board A/B rows on page 7 (beyond S-ACCE A–D) were not
  transcribed.
- The SHIFT A, /S-ACC1, /GAME and /COIN IN routes into D-4/7 were not
  re-traced on page 7; they are cited from the original traces.
- No simulation of the meter current was run.
