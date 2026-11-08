# Other cars' engine sound: the core against the Saturn remake

Issue #105. Aldo reports that the other cars' engine sound in the core does
not sound right. The reference is two recordings from the Sega Saturn remake,
`tests/sound/reference/saturn/6CAR1.WAV` and `6CAR2.WAV` (see the README
there). The remake is **not confirmed** against a board, so the recordings
only point to where to look; every candidate below was checked against the
schematic (sheets D-6/7 and D-7/7, `schematics/pages/page20-sound-D6.png`,
`page21-sound-D7.png`).

Date: 6 November 2026 (Claude). Model runs: the floating-point model
`tests/sound/d67_model.py`, which the Verilog matches bit for bit through its
fixed-point twin (`d67_fixed.py`, `d67_verilog_check.py`).

## Short answer

- **Timbre is the clear difference, and its likely cause is R109.** Both
  Saturn clips (and, by the numbers recorded in `docs/SOUND_LOGIC.md`, the
  board clips) have a dense line spectrum with a strong low line: the sound of
  cell 1 modulating the MC3340's CONTROL deeply. In the model car 1 has almost
  no such modulation because R109, its CONTROL bias resistor, is 330 Ω
  (drawn ".33 K"). Car 2's identical stage has R81 3.3K and does have it. With
  R109 at 3.3K, car 1's lines match the board clips' within about 2 % (one
  line within 6 %).
- **The scan supports 330 Ω**, not 3.3K. The point before "33" is a pen dot,
  not a speck (measured below). So **nothing was changed**. R109 is now an
  option: the OSD's **Passing car R109** (0 = .33K as drawn, the default;
  1 = 3.3K; 2 = 33K, as Monza's redraw writes it), the `r109` input of
  the Verilog. **The choice is Aldo's.**
- The remaining differences are pitch sweep, envelope and the frequency of the
  low line. No value on the schematic explains them, or they fall inside a
  tolerance the schematic itself prints. They are listed with what each would
  change. None was changed.

## The recordings

Both are stereo (the two channels are the same to 0.999 correlation), 44.1 kHz.
They are shorter than a pass in the model, and both start already loud.

| | 6CAR1.WAV | 6CAR2.WAV |
|---|---|---|
| Length | 0.96 s | 1.13 s |
| Level (100 ms RMS, dB re full scale) | −19 at 0 s, −14 at 0.3 s, −12.3 at 0.6 s (peak), −15 at 0.8 s, then cut | −17 at 0 s, −16.5 at 0.3 s, −12.5 at 0.7 s (peak), −15 at 0.9 s, −19 at 1.0 s |
| Swell to the peak | about 7 dB over 0.6 s | about 5 dB over 0.7 s |
| Pitch (one line followed) | 272 → 323 Hz over 0 → 0.7 s (+19 %), then 310 Hz at 0.8 s | 275 → 301 Hz over 0 → 0.8 s (+9 %), then 272 Hz at 1.0 s |
| Strongest line | 54 Hz | 54 Hz |
| Lines within 20 dB of the strongest, 30–1500 Hz | 21 | 24 |
| Main lines (dB re strongest) | 54 (0), 148 (−3), 194 (−3), 318 (−5), 479 (−7), 552 (−4), 783 (−10), 1184 (−10) | 54 (0), 145 (−6), 180 (−4), 293 (−5), 460 (−8), 495 (−6), 751 (−11), 1104 (−11) |

All the lines rise and fall together, as a sweep of the whole bank would make
them do (all three cells follow CAR CON). The remake shifting a sample's pitch
would look the same.

## The core in the same situation

Model of the board with `S-ACCE` code 5 (code 4 gives the same: the feed
is the same for codes 0–5), and pad C (/F-SOUND) low once a frame from 0.5 s,
as with cars on the screen. Car 1's 74123 fires at 0.5 s and car 2's
0.63 s later (IC58). The R409 current into the D-4 mixer is taken as the
output.

| | Car 1, R109 330 Ω (as drawn) | Car 1, R109 3.3K (option) | Car 2 (alone, after car 1 has faded) |
|---|---|---|---|
| Wait at the ramp's upper limit after the reset (code 5) | 0.95 s at −18 dB | 0.95 s at −23 dB | as car 1 |
| Rise to the peak | +16 dB over 0.95 s (code 7: 0.45 s) | +17 dB over 0.95 s | |
| Pitch over the rise (CAR CON 8.70 → 9.08 V) | +4.4 % | +4.4 % | CAR CON 9.30 → 9.68 V, +4 % |
| Peak level (R409 current, dB re the drawn car 1's) | 0 | −4.7 | about −6 |
| After the peak | falls steeply (the selector's steep side) | the same | the same |
| Strongest line | 141 Hz (cell 3) | 141 Hz | 656 Hz |
| Low line (cell 1 minus cell 2) | 79 Hz at −20 dB | 76 Hz at −3 dB | 79 Hz at −5 dB |
| Lines within 20 dB of the strongest | 11 | 39 | 31 |
| Spectral flatness, 30–1500 Hz (Saturn: 0.40, 0.29) | 0.026 | 0.24 | 0.080 |
| Main lines | 141, 396, 539, 680 Hz | 76, 141, 472, 539, 615, 756, 1154 Hz | 79, 152, 504, 574, 656, 806, 1230 Hz |

![Spectrograms: Saturn clips, model car 1 as drawn, model car 1 with R109
3.3K, model car 2; and the average spectra](other_car_spectrograms.png)

*Spectrograms 0–1400 Hz, 60 dB range each, ~90 ms windows. Top: the two
Saturn clips. Middle: model car 1 as drawn (R109 330 Ω) and with the 3.3K
option, over its rise and peak (1.3–2.6 s of the code-5 run). Bottom left:
model car 2 alone (2.65–3.6 s). Bottom right: the average spectra.*

### Comparison, item by item

| Item | Saturn | Board clips (SOUND_LOGIC.md) | Model as drawn | Agreement |
|---|---|---|---|---|
| Pitch at the peak | lines at 148, 479, 552, 1184 Hz | 141, 475, 533, 615, 756, 1230 Hz | car 1: 141, 396, 539, 680 Hz | absolute pitch within a few % (cell 3 at 141–148 Hz everywhere) |
| Pitch sweep | +9 to +19 % in 0.6–0.8 s, then down | about +4 % over 0.65 s, then down | +4.4 % over 0.95 s (code 5) or 0.45 s (code 7), then down | the board agrees with the model; the remake sweeps 2–4 times more |
| Envelope | swells 5–7 dB, then falls faster; no quiet wait before it | swells 12–15 dB over 0.65 s, then falls faster | waits about 0.95 s 16–18 dB down, then swells 16 dB, then falls faster | shape agrees (rise, then a faster fall); the remake's range is smaller and its clips have no wait |
| Timbre | dense lines (21–24 within 20 dB), strongest at 54 Hz | lines as listed: a ~615 Hz cell modulated by ~141 Hz, a ~533 Hz cell "on CONTROL" | car 1: few lines (11), low line 20 dB down | **differs**. Car 1 with R109 3.3K (39 lines, low line at −3 dB) and car 2 (31 lines) are like the remake |
| Loudness against the rest of the mix | not measurable: the clips hold the cars alone | not measured | car 1's peak about 6 dB above car 2's | not checked |

## Candidate causes, ranked

### 1. R109, car 1's CONTROL bias (D-6): the timbre

Cell 1 of each bank drives its MC3340's CONTROL through 22 µF (C26 for NO1,
C24 for NO2) into a bias divider from 12 V. At the cell's frequency the
capacitor passes the cell's whole swing (about 3.5 V peak to peak). The
divider sets where the swing sits on the MC3340's curve:

| Bank | Divider | CONTROL at rest | Swing | Effect |
|---|---|---|---|---|
| NO1 as drawn | R108 10K / R109 330 Ω | 0.72 V | −1.0 … 2.5 V | entirely below the curve's knee (about 3 V): full gain, **almost no modulation** |
| NO2 as drawn | R80 10K / R81 3.3K | 3.9 V | 2.2 … 5.7 V | across the steep part of the curve: **deep modulation**, which makes the dense line spectrum and the strong low line at cell 1 minus cell 2 |
| NO1 with 3.3K | as NO2 | 3.9 V | as NO2 | as NO2 |
| NO1 with 33K | R108 10K / 33K | 7.0 V | 5.3 … 8.8 V | mostly cut off: car 1 sounds only in short bursts at the bottom of each cycle; its peak about 14 dB under the drawn car 1's and at least 8 dB under car 2's |

(Rest levels include the CONTROL pin's own source, 5.66 V behind 4.7 kΩ,
in `sound_parts.py`.)

Evidence for deep modulation on car 1's voice:

- Both Saturn clips: the strongest line is the low one (54 Hz), with 21–24
  lines within 20 dB. The model's drawn car 1 has its low line 20 dB down and
  11 lines.
- The board clips (seven passes, `docs/SOUND_LOGIC.md`, "Open issues", line
  list 141, 475, 533, 615, 756, 1,230 Hz): the model's car 1 with R109 3.3K
  gives 141, 472, 539, 615, 756, 1,154 Hz (within 2 %, the last within 6 %).
  As drawn it gives 141, 396, 539, 680 Hz, which do not match. That earlier
  note read the board's lines as "the roles of the two upper cells swapped";
  deep modulation explains them without a swap.
- Car 2, whose stage is drawn with 3.3K, has the same character.

The schematic: the label reads **".33 K"** beside R109
(crop (3470,1230,3640,1360) ×4 of the stored PNG). The point is at mid-height
before the first 3 and is a solid round dot of 15 × 10 px (122 px). The stray
specks on the same area of the sheet are 3–9 px across (12–46 px)
(connected-component count over (3100,900,4300,1700)). It is drawn, not
dirt. The value written is 330 Ω, as the trace's user check D6-V01 also
recorded. Monza's redraw writes **"33 K"** with no point
(`monza/docs/trace/SOUND_COMPARE_2.md`, D6-3, "probable"). 3.3K, as for R81,
is written nowhere. The parts-side board photo (stonedDiscord/MonacoGP,
`Pictures/Sound Board (Parts Side).JPG`, around (2330,500,2460,620)) shows
the resistor row beside IC12. At that resolution the colour bands cannot be
read and the resistor cannot be identified, so the photo settles nothing.

So a reading of the schematic does not settle the timbre difference, and the
default stays at **330 Ω, as drawn**. The option is in the core and the
models:

| Where | How |
|---|---|
| Verilog | input `r109` of `jtmonacogp_sound` → `jtmonacogp_snd_d67` → `jtmonacogp_snd_d6bank #(.NO(1))`, taken at each step's start; constants `KCON1` (n = 0), `KCON1R1` (n = 1, 3.3K), `KCON1R2` (n = 2, 33K) in `jtmonacogp_snd_d67.vh` |
| OSD | "Passing car R109" (`OJK` in `CORE_OSD`, `cores/monacogp/cfg/macros.def`): status bits 20:19, `.33K (drawn)` / `3.3K` / `33K`; it can be changed while playing (8 November 2026; until then a build macro, `MONACOGP_R109`) |
| Models | `d67_model.D67(r109=n)`, `d67_fixed.D67Fixed(r109=n)`, `d67_model.R109_OPTIONS` |
| Tests | `scripts/run_tests.py` runs the D-6/D-7 scenario a second time with option 1 under Verilator and compares it with the twin bit for bit (`d67_verilog_check.py check DIR 1`). The SPICE comparison and the step-flip budget (8) stay on the drawn value. The option's flips are reported. On 6 November there were 14 on IC32 b against the drawn run's 7, each 0.2–0.5 V near car 1's peak: the same kind, not the 4–5 V "quack". |

What each option changes, in the model: **1 (3.3K)** gives car 1 the dense,
"buzzy" spectrum of car 2, the board clips and the remake, and lowers its peak
by about 4.7 dB. **2 (33K)** practically silences car 1 (in bursts, its peak
about 14 dB under the drawn car 1's and at least 8 dB under car 2's). That fits "most surviving boards produce only one passing
sound" no better than a fault does, and does not fit the board clips' line
list, which matches car 1 at 3.3K better than car 2.

### 2. Cell 1 against cell 2 (C21 / C20 with the ADJ capacitors): the low line's frequency

With deep modulation the strongest low line is cell 1 minus cell 2. The
remake has it at 54 Hz and the model at 76–79 Hz. Cell 2 at about 545 Hz is
common to both, so in the remake cell 1 would be about 600 Hz rather than
615–620 Hz: about 3.5 % lower. That needs about 3.7 % more timing capacitance
on cell 1 (7,270 pF → about 7,540 pF).

The schematic leaves exactly this open. Cell 1's capacitor in both banks is
**6800P marked 誤差5% (5 % tolerance)** with a parallel **※ADJ. 470P**, a
capacitor chosen at adjustment (crops (2300,450,3100,1200) and
(4700,450,5500,1200)). C20 reads 6800P like C21 (the 6 and 8 are faint);
Monza's 200P (D6-1) is not on the Monaco sheet. C21 at either end of its 5 %
moves the low line from about 76 Hz to about 47 or 105 Hz, and a different
ADJ part moves it further. The board
clips' lines (533 and 615 Hz, 82 Hz apart) agree with the nominal values. **No
change**: the nominal value is the schematic's, and the board agrees with it.
It is listed so that Aldo knows this line is a per-board adjustment.

### 3. Pitch sweep against level: the coupling through CAR CON

The remake rises 9–19 % in pitch while swelling 5–7 dB. The model rises
4.4 % while swelling 16 dB. The board clips rise about 4 % over 12–15 dB.
In the circuit both come from the same voltage. CAR CON = 2 × reference −
front CONTROL (IC18 c, R197 / R198 100K each; IC18 d, R188 / R187 100K). The
cells' rate follows CAR CON (about 0.4 V for 4 %). The MC3340 swings about
16 dB over 0.5 V of CONTROL near 3.0–3.5 V (Motorola's typical curve, as
fitted on 3 November). A 17 % rise at only 7 dB would need CAR CON to move
about four times as much per volt of CONTROL, or CONTROL to stay below the
curve's knee for most of the pass.

Checked on the scan: R197 / R198 100K (the D-7 trace's review of
1 November); R129 **47K**, clear (crop (2350,2050,3600,3100); Monza writes
4.7K, D7-11, not on the Monaco sheet); R130 5.1K / R131 6.8K. With R129
4.7K car 2's ramp would hardly move u2, which is no closer to the remake.
**No supported value gives the remake's sweep, and the board clips agree
with the model.** The remake may shift its sample's pitch. No change.

### 4. Envelope: the wait at the ramp's upper limit (TL_HI, a setting)

After a reset the model holds the ramp at its upper limit (12 V, a setting
fitted to the board clips on 3 November) for about 0.95 s at code 5. Car 1
waits 16–18 dB under its peak, then rises. The remake's clips start loud and
rise only 5–7 dB. Each clip may begin after its wait, since the clips are
about 1 s long. The order (rise, then a faster fall) agrees with the board
and supports the 12 V setting over 10.5 V: at 10.5 V each pass starts at its
loudest and highest and only falls. **No change.**

### 5. Car 2's pitch (R190)

The model's car 2 sits about 7 % above car 1 (CAR CON reference 6.58 V
against 6.28 V, with R190 at 6.8K from the board photo; the sheet's 68K would
pin it at the rail). The two remake clips peak at the same pitch within
about 2 %. Which car each clip is, if either is car 2, is not known. This is
weak evidence and no change is made.

### 6. The MC3340 control offset (0.13 V, Aldo's choice of 3 November)

It moves where on the curve each car sits, so it changes loudness and the
depth of modulation a little. It does not change which lines appear, so it
cannot make the drawn car 1 sound like the remake. No change.

### Monza differences rechecked on the Monaco scan

| Monza reading | Monaco scan | Crop |
|---|---|---|
| R109 33K | ".33 K", deliberate point (above) | (3470,1230,3640,1360) |
| C20 200P | 6800P (as C21) | (4700,450,5500,1200) |
| R71 100K | 10K | (5150,2650,5950,3200) |
| Dot joining TR7's base to the 6 V column | no dot; the base line crosses the column | (2250,3350,3050,4350) |
| R129 4.7K | 47K | (2350,2050,3600,3100) |

All agree with `SOUND_D6_TRACE.md` and `SOUND_D7_TRACE.md`.

## What changed

- Nothing in the default sound. R109 is still 330 Ω and every stored
  reference stays as it was. The generated `jtmonacogp_snd_d67.vh` only gains
  the two option constants.
- New option R109 on `jtmonacogp_snd_d67` and `jtmonacogp_snd_d6bank`
  (first a parameter and the build macro `MONACOGP_R109`; since 8 November
  2026 the input `r109`, from the OSD's "Passing car R109"). The options are in
  `d67_model.py` and `d67_fixed.py`. One more Verilator run and check are in
  `scripts/run_tests.py`.

## Still uncertain, and not checked

- Whether the remake is right at all. These clips are its only evidence.
- Which car each Saturn clip is.
- R109's real value on a board. A clearer photo of the parts beside IC12
  (bands of R108 / R109), or a measurement, would settle it.
- Loudness of the other cars against the rest of the mix: the clips have
  nothing else in them.
- The game-level sound run (`tb_play_sound`) was not run for this issue.
