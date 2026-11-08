# Sound board logic (jtmonacogp_sound)

The sound board 96598-P (sheets D-1/7 to D-7/7, traced in
[trace/SOUND_D1_TRACE.md](trace/SOUND_D1_TRACE.md) to
[trace/SOUND_D7_TRACE.md](trace/SOUND_D7_TRACE.md)) is mostly analog: LM324
integrators and comparators, transistor switches, an MC3340 attenuator, RC
envelopes and a summing amplifier. The core models it as a set of difference
equations stepped at 480 kHz in fixed point, checked against a pin-wired SPICE
simulation of the drawn circuit.

## What is built

Milestone 1:

- **D-4/7 control gates**: every gate that turns the sounds on and off from
  the game boards' signals.
- **D-3/7 MY CAR SOUND**, the engine: `jtmonacogp_snd_d3.v`.
- **D-4/7 mixer and SOUND OUT**: the summing amplifier IC66 b, C103, the
  output network and the output mute; `jtmonacogp_snd_mix.v`.
- The board top `jtmonacogp_sound.v`, connected in `jtmonacogp_game.v` to
  sheets A and F and to JTFRAME's audio output.

Milestone 2:

- **D-4/7 sound sources**: the S2688 noise and its amplifier, the
  explosion (two noise band-passes, two MC3340s under 74123 envelopes,
  IC66 a), the skid tone (triangle oscillator, noise and the 555) and the
  EXTEND beep (pad 14 EX.CP from sheet A); `jtmonacogp_snd_noise.v`,
  `jtmonacogp_snd_expl.v` with two `jtmonacogp_snd_band.v`.

Milestone 3:

- **D-6/7 and D-7/7 other cars**: two engine notes (D-6's banks) swept by
  D-7's ramps, restarted from pad C (/F-SOUND, sheet H); the front sum
  into the D-4 mixer through R409; `jtmonacogp_snd_d67.v` with
  `jtmonacogp_snd_d7ctl.v`, two `jtmonacogp_snd_d6bank.v`, two
  `jtmonacogp_snd_d7car.v` and six `jtmonacogp_snd_mc3340.v`.

Milestone 4:

- **D-2/7 rescue siren and back sound**: the rescue car's two-tone siren
  (rear and front envelopes on two MC3340s, a sawtooth VCO keyed by a
  555), pad P from sheet M; the back sound (the rear siren with the other
  cars' back output) to pad R and, through DIP SW. 2, into the D-4 mixer;
  the front siren into the mixer through R410; `jtmonacogp_snd_d2.v` with
  `jtmonacogp_snd_d2vco.v` and one shared `jtmonacogp_snd_mc3340.v`.
- The board's setting switches in the MRA's DIP menu (sheet A's changeover
  switch, DIP SW. 2's back-sound and louder-explosion contacts), and pad R
  as a second sound channel.

Milestone 5:

- **D-1/7 slip-zone sound**: the S2688's noise through a band-pass whose
  centre an oscillator sweeps (a transistor shunting its input), gated by
  pad J (/SLIPZONE from sheet F) into the D-4 mixer through R412;
  `jtmonacogp_snd_d1.v`.

Milestone 6:

- **D-5/7 hi-score tune**: the PROM sequencer started by HI SCORE (sheet
  A's /HISCORE), two banks of note trimmers, the vibrato, two sawtooth
  oscillators, the filters, the envelope and the MC3340 into the D-4
  mixer through R408; its alarm line un-mutes SOUND OUT while the tune
  plays, and sheet A's MUTE pad (tilt) stops that;
  `jtmonacogp_snd_d5.v`, with its PROM (prm40.ic21) from the ROM download.

Every sheet of the board is now in the core.

## The model step

`jtmonacogp_sound.v` counts 100 clocks of the 48 MHz `clk` per model step
(480 kHz, `DT` = 2.083 µs). At the start of a step it takes the game boards'
signals and the gates computed from them and holds them through the step, so
the result does not depend on where in a step an input changes. D-3 then runs
its step (one shared multiplier and one table ROM, a state machine). In
parallel the D-4 noise and skid block runs its step; as soon as it has the
noise amplifier's output it starts the explosion, whose two band chains run
side by side. The mixer runs its own step when D-3, the noise block and
the explosion are all done. A state that uses the multiplier takes two
clocks, with the product registered between them; the others take one.
D-3 takes about 85 clocks, the explosion finishes by clock 82, the mixer
then takes up to 9, so everything is idle before the next step starts
(`tests/tb_sound.v` checks this at every step). The first
Quartus build, with the multiplier, rounding, shift and the state's action in
one clock, missed 48 MHz by 9.1 ns. Ten steps
make one output sample: the mean of pad 13 over those steps, at 48 kHz, with a
one-clock `sample` pulse.

Fixed point: voltages are signed 36-bit integers with 2^28 per volt; capacitor
voltages are 52-bit with 2^44 per volt (the extra bits keep the small
per-step increments of the slow capacitors). Every product is
`(a·m + 2^(s-1)) >> s` with a 36-bit operand and a 27-bit coefficient. The
coefficients are `m / 2^s` with |m| < 2^26. Non-linear parts (diodes, the
MC3340) are tables on uniform grids with power-of-two steps, read at two
neighbouring entries and interpolated linearly; below the grid they hold the
first entry, above it the last. All tables of D-3 are one ROM of 2,906
36-bit words.

## D-4/7 control gates

From the D-4 trace (pads 8, K, 9, L, 10 from the game boards, through
R378–R382 470 Ω into IC68 inverters and IC60, a 7402):

| Gate | Equation | Goes to |
|---|---|---|
| IC60 a | 60a = NOR(/S-ACC1, /GAME) | explosion trigger T and the skid 555 |
| IC60 b | MY CAR SOUND ON = NOR(60a, /COIN IN) | D-3, IC54 4-3 |
| IC60 c | 60c = NOR(/COIN IN, GAME) | IC60 d |
| IC60 d | SHIFT A = NOR(60c, NOT SHIFT) | D-3, the SHIFT inverter |
| 7432 | 60a OR NOT /NON ROAD & POOL SLIP | the skid 555's RES |
| IC67, IC57 | mute while NOT (COIN IN OR alarm) | IC57 4 sinks the R413/R407 node through R406 100 Ω; IC57 6 is BACK SOUND STB (D-2) |

So during a game the engine plays unless the car has crashed (/S-ACC1 low),
SHIFT A follows the gear lever (high in high gear: the engine note drops), and
before a coin the engine is off and SOUND OUT is shunted. The alarm (D-5,
IC35 pin 4) un-mutes SOUND OUT while the hi-score tune plays; the gates
take the alarm as D-5's previous step left it (one step, 2.08 µs, late).

Sources in the core: /S-ACC1, SHIFT and /NON ROAD & POOL SLIP from sheet F
(`jtmonacogp_control.v`, pads AR, AW, A20), /COIN IN and /GAME from sheet A
(`jtmonacogp_coin.v`, through IC31 7407 buffers to pads A28 and AE), S-ACCE
A–D from sheet F.

## D-3/7 MY CAR SOUND

The circuit (D-3 trace) and how each block is stepped
(`tests/sound/d3_model.py`, whose block methods are the units the SPICE
comparison drives):

1. **DAC.** S-ACCE A–D drive open-collector buffers (open: 12 V through 1K;
   sinking: 20 Ω) into 390K, 220K, 100K and 51K, with R298 390K from 12 V.
   The node voltage for each of the 16 codes is computed exactly (Thevenin
   sum) and buffered by IC49 c, limited to the LM324's high output (10.5 V).
2. **Lag** C62 47 µF: R300 150K always; R302 68K through the CD4016
   (IC54 11-10, 300 Ω on) while S-ACCE D is low; D21 + R299 33K back to the
   follower while the capacitor is above it (a table of the diode current
   against the voltage across diode and resistor). Euler step.
3. **CV.** IC50 d follows the lag. R303 220K / R301 470K to the SHIFT
   inverter scale it by (470K + 20 Ω)/(690K + 20 Ω) = 0.681 while SHIFT A is
   high; IC50 c follows. CV is limited to the LM324's output range less the
   drop across its output resistance under the cells' load (10.48 V).
4. **Three oscillator cells** (IC51, IC50, IC49 a/b; C67 + C113, 4,700 pF,
   0.022 µF): an integrator with its + input at CV/2 (51K/51K) charged from
   CV through 150K, 270K or 220K, and discharged through 68K, 120K or 100K by
   a 2SC458 (TR18 and the others) driven by a Schmitt comparator (51K from
   6 V, 100K feedback). The integrator output is limited to the LM324 rails.
   The comparator's output is the LM324's limited by the load it drives
   (10.45 V high, 0.022 V low); the transistor saturates (5 mV) once the
   output is above 3.72 V. The comparator slews at 0.5 V/µs and its internal
   node runs 2.0 V past its output limits (`CMP_OVER`), which stands for the
   LM324's regeneration and saturation-recovery delay (about 3 µs). Without
   it the cells ran 1.4 % fast against SPICE at high CV.
5. **AM control** IC51 c: its + input is V10, CV through R305 10K clamped by
   D27/D28 to the R341 680 / R342 330 divider (a table of V10 against CV);
   its − input takes cell 1's triangle through C66 22 µF and R304, with R306
   feedback. CON = 2·V10 − (cell 1 − C66), limited to the rails; the
   capacitor current changes when the output is limited.
6. **Audio bus.** Cells 2 and 3 through D24 / D22 into R325 10K, and through
   C64 10 µF to the MC3340's input (IC52 pin 1). Two diodes from two sources
   into one node are one diode from the higher source plus a sharing excess
   (`softmax_excess`, a table); the diode drop is solved against the
   Thevenin equivalent of R325 and the MC3340 input (a table of the drop
   against the voltage across both). The MC3340 input is its linear part
   (1.599 V through 17.77 kΩ) plus the rest of its table current, taken from
   the previous step.
7. **MC3340** (IC52): a separable table model fitted to DC sweeps of a
   transistor-level SPICE model (next section).
8. **Output.** IC52's output (220 Ω: R16 and the follower) through the
   CD4016 IC54 4-3 (on while MY CAR SOUND ON is high), R356/R355 51K to 12 V
   and ground, C72 22 µF and R411 100K into the mixer's 6 V virtual ground.
   The R411 current is D-3's output (`i_mix`, current × 100K).

### MC3340 model

The SPICE reference uses a transistor-level MC3340
(`tests/sound/spice/mc3340.lib`). Its topology and resistor values are
Motorola's internal schematic as transcribed in MAME's netlist library
(`nlm_opamp_lib.cpp`, MC3340_DIP, licence CC0-1.0, by Colin Howell); it is a
component model only, not Monaco GP circuitry.
`tests/sound/characterize_mc3340.py` sweeps it at DC (input −2..7 V in
10 mV, control 0..8 V in 50 mV) and `mc3340_fit.py` fits:

    sep  = VO0(Vc) − G(Vc)·Heff
    Heff = H(Vin)·(1 − W) + H_LOW·W,  W indexed by Vin − VONW(Vc)
    out  = min(LO(Vc) + S(sep − LO), HI)
    iin  = IB(Vin) + IC(Vin − VON(Vc))   (IC linear above its grid)

with tables on the control voltage (VC), the input (VIN), the input past the
collapse edge (U) and the soft output limit (S). Against the sweeps: output
error at most 0.090 V (6.9 mV rms) over the input range the circuit uses, at
most 0.222 V (13.7 mV rms) overall; input current within 0.05 µA. The input
clamp above about 4.3–5.3 V is reached only at power-on. The control pin's
own current near 0 V is not modelled (the control voltage here stays well
above it).

**Control offset (3 November 2026, Aldo's choice).** Against Motorola's
typical 12 V curve (data sheet Figure 3, "Attenuation versus DC Control
Voltage", sent by Aldo; digitized: 2 dB at 3.04 V, 10 at 3.40, 18 at 3.55,
26 at 3.72, 34 at 3.91, 46 at 4.22, 62 at 4.66, 90 at 5.55) the
transistor model reached each attenuation 0.10–0.20 V of CONTROL early
from 2 to 34 dB (0.13 V on average), and is steeper above about 40 dB.
`mc3340.lib` now has a 0.13 V source in series with the control pin
(`VCOFS`), so the whole curve, the tables (`mc3340_fit.py`, which also
moves its cut-off from 4.8 to 4.93 V) and the pin's own source
(`sound_parts.MC_CTL_V0`) move together; after the refit the tables are
within 0.04 V of Motorola's curve from 2 to 34 dB, still steeper above.
It applies to every MC3340 (D-2, D-3, D-4, D-5, D-6/D-7), and every
SPICE reference was run again with it. Aldo's passing-car clips point to
about twice this offset, which is inside the data sheet's spread between
parts.

## D-4/7 sound sources

The circuit is in the D-4 trace, with its check of 1 November against the
scan. The floating-point model is `tests/sound/d4_model.py`; the SPICE
reference `tests/sound/spice/d4_effects.cir`.

1. **S2688 noise** (IC62): a 17-bit shift register with feedback from bits
   14 and 17 (as the MM5837 it replaces; the register starts at all ones,
   and a register of zeros feeds a 1 so it can never lock). It is shifted at
   100 kHz by a phase accumulator (5 shifts every 24 steps); its output, bit
   17, is 3.0 V or 10.5 V. The clock frequency and the levels are not on
   the drawing: the levels are a bench measurement of the MM5837 on 12 V
   quoted in MAME's `mm5837.h`, the clock its typical figure.
2. **Noise amplifier** IC63 c: C79 1 µF and R361 150K into the 6 V virtual
   ground, R362 51K feedback (gain −0.34). Its output slews at the LM324's
   rate after each noise edge; while it slews or is limited the − input
   leaves 6 V. Without the slew limit the model's RMS was 9 % above SPICE's.
3. **Two band-passes** (multiple feedback around IC63 b and IC63 a, C93/C92
   4.7 µF in): R395 4.7K, R396 27K, 0.01 µF twice and R391 220K, near 540 Hz;
   R388 4.7K, R389 8.2K, 0.047 µF twice and R387 220K, near 130 Hz. Three
   capacitor states each, limited to the LM324's range (the virtual ground
   let go while limited).
4. **74123 one-shots**: IC61 a and IC69 a fire as the trigger T (IC60 a)
   rises; IC61 b fires as IC69's Q falls. Each Q stays high for
   tw = 0.28·R·C·(1 + 0.7/R[kΩ]) with 47K and 4.7 µF (SN74123 data sheet),
   62.8 ms or 30,131 steps; they are retriggerable.
5. **Envelopes**: each Q through its 330 Ω pull-up and an MA150 (D30, D31)
   charges a 10 µF (C77, C78) discharged by R374 330K or R375 1M (a table
   of the diode-and-resistor current against the voltage across both).
   Followers IC66 d and IC64 d (their low limit raised by the inverter's
   current through the output resistance), inverters IC66 c and IC64 c
   about VB = 12 V·3.9K/12.1K: control = 2·VB − envelope, 7.74 V at rest
   (attenuated), falling as the envelope rises.
6. **MC3340s** IC65 (540 Hz, envelope of IC61 a) and IC71 (130 Hz, envelope
   of IC61 b, 63 ms later and longer): C82/C98 1 µF and R397/R398 33K into
   IN, with the same table model and input treatment as D-3's IC52.
7. **IC66 a** sums both outputs (C83 1 µF and R365 150K; C99 1 µF and
   100K) with R400 1M feedback, R423 2M in parallel when DIP SW. 2 contact
   2-15 is closed (the `explo_loud` input, held low: the switch is taken
   open). C100 10 µF and R401 220K into the mixer.
8. **Skid triangle** IC64 b: a relaxation oscillator (R392 51K from 6 V,
   R393 100K hysteresis, R394 6.8K and C94 10 µF), 97 ms (10.3 Hz);
   follower IC64 a. IC64 b's output pin drops under its load (50 Ω output
   resistance into R394 and R393 + R392), which narrows the hysteresis:
   seen from C94 it is a Thevenin source with constant thresholds. Left
   out, the period came out 0.4 % long against SPICE.
9. **IC63 d** sums the noise (C80 1 µF, R385 100K) and the triangle (R390
   68K) into R386 10K; its output through C81 33 µF into the 555's
   CONTROL, whose internal divider is a 3.33 V, 3.33 kΩ Thevenin source.
10. **555** on 5 V (R383 47K, R384 47K, C89 4,700 pF, about 2.2 kHz at rest):
    RES from the 7432 (crash or off-road); C89 charges through R383 + R384
    while OUTPUT is high and discharges through R384 into DISCHARGE (10 Ω)
    while low, by the exact exponential factor; threshold at CONTROL,
    trigger at half of it. It is stepped 8 times per model step (3.84 MHz),
    and its OUTPUT for the step is the mean of the eight: deciding once
    per step, each switch came up to a step late, and
    the tone ran 0.67 % flat at a fixed CONTROL (1.5 % in the test
    scenario, with the noise on CONTROL); with the sub-steps, 0.11 %.
    OUTPUT 3.3 V / 0.05 V through R405 10K to the R404 10K node, C101
    10 µF and R403 220K into the mixer.
11. **EXTEND**: pad 14 EX.CP (5.0 V / 0.2 V) through 2.2 µF and R402 220K into
    the mixer. EX.CP comes from sheet A (`jtmonacogp_coin.v`, IC85): V2
    gated by Vs/16 (3.9 kHz, 8 frames on, 8 off) for the 1.34 s of the
    one-shot IC49, which /EX. SIGNAL CP fires when extended play is won.

Each capacitor but C89 is stepped by Euler, like D-3. The band-passes' peak gain
comes out about 2 % above an 8 times finer step, accepted.

In the core, `jtmonacogp_snd_noise.v` computes the noise amplifier first and
pulses `namp_rdy`, then the triangle, IC63 d, CONTROL, the 555 (its eight
sub-steps in 24 clocks) and EXTEND, and returns the R402 + R403 current, by
clock 59 of the step; `jtmonacogp_snd_expl.v` counts the
one-shots, starts its two `jtmonacogp_snd_band.v` (band-pass, envelope,
MC3340: one per chain, each with its own multiplier and table ROM of 2,135
36-bit words) on `namp_rdy`, then computes IC66 a, C100 and the R401 current.
The generator is `tests/sound/d4s_fixed.py` (the fixed-point twin), which
writes `jtmonacogp_snd_noise.vh`, `_band.vh` and `_expl.vh`.

## D-6/7 and D-7/7 other cars

The circuit is in the D-6 and D-7 traces (with their checks of 1 and 2
November against the scan). The floating-point model is
`tests/sound/d67_model.py`; the SPICE reference
`tests/sound/spice/d67_cars.cir`.

D-6 makes two engine notes, one per other car, each from a bank of three
cells like D-3's. D-7 sweeps their pitch and loudness: a ramp per car,
restarted by pad C (/F-SOUND from sheet H) while the player is fast enough
(S-ACCE code 4 or more), shapes four control voltages and the two CAR CON
voltages that set the banks' pitch. Each bank's note goes through two
MC3340s, a front one into the D-4 mixer and a back one to D-2.

1. **Decoder and feed**: S-ACCE B, C, D (IC36 74145, IC38, IC47) choose R169
   1.2K (codes 0–5) or R124 1.5K (6, 7, both through the open-collector
   outputs) against R125 1K from 12 V. The feed node also carries the two
   ramps' 33K inputs (R126, R150), at their previous step's level.
2. **Ramps**: TL081 integrators IC14 and IC28 (33K, 11 µF: two 22 µF back to
   back), + at R151/R127 10K/10K with C30 (6 V once charged), limited to
   1.5..12 V with 50 Ω output resistance (the 12 V upper limit is a
   setting fitted to the board recordings, see "The ramps' upper limit"
   below). Each is reset by TR12/TR13
   (2SC458 on the integrator's − input through 100 Ω) while its 74123
   pulse is high; the transistor's current is a table against the − input
   (`characterize_d7_reset.py`, SPICE). A reset drives the output to its
   upper limit; it stays there until the capacitor has recharged through
   33K (about 0.6–0.9 s, depending on the code) and then ramps down at
   (feed − 6 V) / 33K / 11 µF. The three modes (upper limit, lower limit,
   linear) are solved exactly each step.
3. **IC15**: u = 6.857 V·1.47 − 0.47·ramp (R133 47K / R132 100K, R129 /
   R128 for car 2, about R130 5.1K / R131 6.8K at 6.857 V).
4. **Triggers**: IC29, two LM339 stages with 2.2K/100K hysteresis and 2.2K
   pull-ups, compare u1 and u2 with 6 V. IC55's 7427 NORs and IC46 combine
   them with pad C (low during the step: the module latches pad C over the
   100 clocks before each step) and IC56 (codes 0–3 block): car 1's pulse
   fires when pad C is low, the code is 4 or more and u1 is above 6 V; car
   2's when, in addition, u2 is above 6 V, u1 below, and IC58 is not
   running. The 74123s IC59 a/b (C75/C85 2.2 µF, R259/R371 10K: 6.59 ms,
   3,164 steps) and IC58 (47 µF, R320 47K: 0.628 s, 301,589 steps; started
   with car 1's) are retriggerable step counters, as on D-4.
5. **Shapers and selectors**: per car, IC17 b/c (10K/5.1K about reference A, 4.05 V),
   IC17 a/d (6.8K/3.3K, against a reference loaded by both cars' 51K
   inputs), IC16 b/c (2·4.29 V − u) and the IC16 a/d followers ((u + ref)/2,
   loaded). The IC31/IC30 comparators (hysteresis as IC29) take the larger
   of each pair through the IC24/IC23 4016s; the IC18/IC32 followers drive
   the four D-7 MC3340s' CONTROL (NO1 front/back, NO2 front/back).
6. **CAR CON**: IC18 c/d, 2·ref − front CONTROL, limited below by the LM324
   and above by its high limit less the cells' load; car 1's ref is
   12 V·5.6K/10.7K = 6.28 V (R192 5.1K/R191 5.6K), car 2's
   12 V·R190/(5.6K + R190) = 6.58 V with R190 = 6.8K (the board photo; the
   schematic writes 68K, which pins car 2's CAR CON at the rail: D-7 trace).
7. **D-6 banks**: three cells each, the D-3 cell model (`d3_model.cells_step`)
   with D-6's own half-rail: R82/R83 1K with C22 + C23 200 µF, loaded by
   the six comparators' 51K inputs, starting at 6 V. Cell 1 drives the
   bank MC3340's CONTROL through C26/C24 22 µF into its bias divider
   (10K/330 for car 1, 10K/3.3K for car 2) and the CONTROL pin's own
   source (5.53 V behind 4.70 kΩ, fitted to the transistor-level MC3340
   from −3 to 7 V within 3.2 µA). Cells 2 and 3 through MA150s to the bus
   and 10 µF into IN, as on D-3.
8. **D-7 MC3340s**: each bank's output feeds two inputs (front, back)
   through 2.2 µF each; both inputs load the bank's output through its
   output resistance, solved together. Each output goes through 2.2 µF,
   one switch of the IC25 4016 (open while the car's 74123 pulse is high,
   through TR11/TR10), the 10K/10K bias to 6 V, 2.2 µF and R207/R204 10K
   (front, into IC32 b with R426 33K feedback) or R220/R217 51K (back, into
   D-2's IC40 pin 6, a 6 V virtual ground).
9. **Front sum**: IC32 b's output through C15 2.2 µF and R409 82K into the
   D-4 mixer's 6 V virtual ground.

The blocks are stepped side by side, as in the core: the D-7 MC3340s take
the banks' outputs and their CONTROLs of the previous step, the banks take
CAR CON of the previous step (one step, 2.08 µs, late). Left out against the
reference: the selectors' reference (R208/R209 10K/10K, C33 10 µF) is taken
as settled at 6 V from the first step; the LM339's 0.3 µs and the 4016 controls' ramp; the
op-amps' slew outside the cells.

**The ramps' upper limit** (3 November 2026, a setting, not a reading).
A TL081 on 12 V typically swings to about 10.5 V, and with that limit
every pass sounded like a steady full-level tone (Aldo's "beep"). The
reason: the shaper pairs' crossings, where each MC3340's CONTROL is lowest
(loudest) and CAR CON highest (highest pitch), fall at u = 5.13 V, and a
ramp at 10.5 V gives u = 5.14 V. A reset therefore parked u at the
loudest, highest point for the whole windup (about 0.6 s), after which
the note could only fall. All seven board clips
(`reference/recordings/passing_cars/`) show the opposite order: the car's
~600 Hz line rises steadily by about 4 % (595 to 618 Hz) while its level
rises 12–15 dB over about 0.65 s, peaks, then falls, faster than it rose
(the shapers' slopes on either side of the crossing are 0.51 and 1.35 V/V,
a ratio of about 2.6; the clips' rise and fall rates differ by about 2.7).
So on the board u sweeps through the crossing from below. A 4 % rise needs
CAR CON about 0.37 V below its peak at the start (the bank's cells move
about 63 Hz/V there), so u about 0.7 V below the crossing, i.e. a ramp
start of about 12 V. Every resistor that sets this was read again on the
scan (R130/R131, R132/R133, R161/R157, R162/R163, R147/R122, R148/R158,
R159/R160) and agrees with the model; the board photo's colour bands are
too blurred to check them. With the upper limit at 12 V (the model's
`TL_HI`, `hid=0` on IC14/IC28 in `spice/d67_cars.cir`) a pass waits
through the windup about 19 dB below its peak, then rises about 4 % in
pitch over about 1 s at code 5 (about 0.45 s at code 7) to the crossing
and falls. Which part of the real board puts the start there is not
known.

**R109, an option** (6 November 2026, issue #105,
[sound/OTHER_CAR_COMPARE.md](sound/OTHER_CAR_COMPARE.md)). With R109 at
330 Ω, as drawn (".33 K", a deliberate point), car 1's CONTROL sits at
0.72 V and cell 1's swing stays below the MC3340's knee: car 1's note is
hardly modulated. Car 2's identical stage (R81 3.3K) is modulated deeply,
and so are the board clips and the Saturn remake's recordings. Car 1 with
3.3K matches the board clips' lines within about 2 %. The scan does not
support 3.3K, so the default stays as drawn. `jtmonacogp_snd_d67`'s
input `r109` (the OSD's "Passing car R109") selects 0 = 330 Ω, 1 = 3.3K
or 2 = 33K (Monza's redraw); the models take `r109` the same way, and the
tests run option 1 against its twin as well.

Each bank's output node is solved with each D-7 input's linear part (MC_VB
through MC_RIN) and the rest of its current, which moves a sixteenth of
the way to its new value each step. Until 2 November the rest was taken whole
from the previous step: the input's knee (up to 22 mS, against the bank
MC3340's 220 Ω and two inputs a loop gain up to 9.7) then made the node and
IC32 b flip by 4 to 5 V between steps at the top of each note, about
100,000 times in the 3 s scenario. That was the "quacking digital noise"
Aldo heard on the passing cars. A step of an eighth settles for any gain
below 15; after the MC3340 control offset (3 November, see "MC3340" in the
checks) the inputs reach a steeper part of their knee and an eighth flipped
again (about 23,000 times), so the step is now a sixteenth, which settles
for any gain below 31 (6 flips in the scenario). The lag (about 16 steps,
33 µs) acts only on the input's current beyond its linear part.

In the core, `jtmonacogp_snd_d67.v` runs five blocks at each step start:
`jtmonacogp_snd_d7ctl.v` (decoder to CAR CON, with the reset table),
two `jtmonacogp_snd_d6bank.v` (cells, CONTROL node, bus and MC3340) and two
`jtmonacogp_snd_d7car.v` (each car's two MC3340s and output networks). Each
MC3340 is a `jtmonacogp_snd_mc3340.v` with its own multiplier and table ROM
(1,750 36-bit words). When all five are done the top steps D-6's half-rail
and the front sum and returns the R409 current; everything is done by
clock 84 of the step. The back output (`i_mb`, the current into
D-2 times 51K) waits for D-2. The generator is `tests/sound/d67_fixed.py`,
which writes `jtmonacogp_snd_d67.vh`.

## D-2/7 rescue siren and back sound

The circuit is in the D-2 trace, with its check of 2 November against the
scan (R231 on IC40 pin 13 and R264 from 12 V among the corrections). The
floating-point model is `tests/sound/d2_model.py`; the SPICE reference
`tests/sound/spice/d2_rescue.cir`.

Each /RESCUE CP pulse (pad P, 20 ms low from sheet M's IC18) makes one
fall and rise of the rear envelope; as it passes 4.9 V on the way down the
front envelope falls fast and then rises slowly. The envelopes set the
loudness of the same siren tone in two MC3340s, rear and front.

1. **Pad P**: R278 4.7K pull-up, R280 2.2K into TR15 (2SC458), which holds
   IC42 pin 3 at 6 V (R243 / R281 10K) while pad P is high and lets it go
   to 12 V while it is low.
2. **Rear envelope** (IC42): the latch pair IC42 d/a (1K in from the other
   output, 100K feedback: gain −100, four passes a step), pin 12 at
   (12 V + IC42.8) / 2. The comparator IC42 c compares the envelope with
   3.44 V (R249 8.2K / R250 3.3K, R247 1K / R246 100K hysteresis). The
   integrator IC42 b (C53 + C54, 33 µF back to back: 16.5 µF) is steered
   from pin 1 through D18 / R283 51K (down) or R282 82K / D17 (up); the
   diode currents are tables of the MA150 with its series resistor
   (1/16 V steps). While the output sits at a limit the − input leaves 6 V.
3. **Front trigger** (IC43 a/b-c): IC43 a compares the rear envelope with
   4.90 V (R252 6.8K / R255 4.7K, 1K / 100K); its edge goes through C55
   0.68 µF into node Q (R251 10K, D32 clamping at −0.55 V) and R284 10K
   into the Schmitt IC43 a (R285 100K, 6 V), whose pulse sets the IC43
   latch (pin 5 from IC43.1, pin 10 from IC44.14).
4. **Front envelope** (IC44 a, C56 + C57: 23.5 µF) steered from IC43.7
   through D20 / R291 10K (down) or R290 220K / D19 (up); IC44 d compares it
   with 3.44 V (R264 8.2K from 12 V / R263 3.3K) and resets the latch.
5. **CONTROLs**: the followers IC40 c (rear) and IC44 c (front) take 100K
   from their envelope and 51K from the 2.8 V rail (R239 8.2K + 680 Ω /
   R238 2.7K), which both load; solved exactly.
6. **Siren tone**: the 555 IC39 on 12 V (R268 10K, R269 680K, C47 0.68 µF:
   0.325 s high, 0.321 s low) keys node W (R233 3.9K, R235 12K, R232 30K,
   R234 + R416 51K) through D15 / R230 22K: 8.40 or 7.54 V. IC40 d
   integrates W's current through R232 on C49 0.033 µF; while the Schmitt
   IC40 a (R272 51K from 6 V, R273 100K) is high, TR16 (R271 10K, D16,
   R270 2.2K; collector current a table from SPICE,
   `characterize_d2_tr16.py`) discharges C49 through R231 680 Ω. The tone
   is a sawtooth of about 700 Hz (650 Hz while the 555 is low), 3.9 to
   10 V. Eight sub-steps a step; IC40 a's output slews through an internal
   node at 0.5 V/µs (a table of the LM324 model's tanh), as in the
   reference. The 555 is updated once a step; while low, C47 discharges
   towards the 12 mV that R268 leaves on DISCHARGE.
7. **MC3340s** IC41 (rear, C51 2.2 µF) and IC45 (front, C59 1 µF) on the
   sawtooth: the D-3 table model.
8. **Rear output**: C52 2.2 µF, R276 18K into IC40 b (R277 22K, a 6 V
   virtual ground) with BACK OTHER CAR (the other cars' R220 / R217
   current), C50 10 µF and R274 1K into node Z. From Z: R279 1K to pad R
   (BACK SOUND OUT, into an assumed 10K amplifier input); R275 50 Ω to
   BACK SOUND STB. (D-4's IC57, sunk with SOUND OUT's mute); C114 2.2 µF
   and R424 100K into the D-4 mixer when DIP SW. 2's contact is closed.
9. **Front output**: C58 2.2 µF, R292 10K into IC44 b (R293 100K, gain
   −10), C60 2.2 µF and R410 220K into the D-4 mixer.

The MC3340s take the previous step's sawtooth and CONTROLs, and IC40 b the
other cars' back current of the previous step (one step, 2.08 µs, late), as
the core runs them side by side.

In the core, `jtmonacogp_snd_d2.v` steps the envelopes, the CONTROLs and
both output networks with one multiplier and a 708-word table ROM (the four
steering tables); one `jtmonacogp_snd_mc3340.v` serves IC41 and then IC45;
`jtmonacogp_snd_d2vco.v` (its own multiplier and a 642-word table ROM:
TR16 and the slewing node) runs the 555 and the VCO beside them. Everything
is done by clock 79 of the step. Outputs: the R410 and R424 currents times
R414, and pad R. The generator is `tests/sound/d2_fixed.py`, which writes
`jtmonacogp_snd_d2.vh`.

The game wires pad P to sheet M's /RESCUE CP. BACK SOUND OUT feeds the
cabinet's back speaker on the real machine; the core decimates pad R as a
second channel (`snd_b`, 4,096 per volt, full scale 8 V; provisional), on
the right channel when OSD "Back speaker" is on (not original circuitry;
otherwise both channels carry SOUND OUT).

## D-1/7 slip-zone sound

The circuit is in the D-1 trace (its review of 31 October). The
floating-point model is `tests/sound/d1_model.py`; the SPICE reference
`tests/sound/spice/d1_slip.cir`.

The S2688's noise rings a narrow band-pass whose centre a slow oscillator
sweeps up and down: a whistling hiss that warbles about 20 times a
second. Pad J (SLIP ZONE, from sheet F's /SLIPZONE) lets it through to the
mixer while it is low.

1. **Noise input**: the S2688's output (the D-4 noise source, the same bit
   as D-4's in each step) through C68 1 µF, R345 10K with C105 0.1 µF to
   ground, and R350 10K into node A.
2. **Band-pass** IC53 a: C71 and C70 0.022 µF from node A to the − input
   and to the output, R348 220K from the − input to the output, + at 6 V.
   Its bandwidth is 1/(π·R348·C) = 66 Hz whatever shunts node A; the
   centre is set by what does.
3. **Shunt**: R349 100 Ω and a 2SC458 from node A to ground, its base
   from the C63 follower through R308 10K with R343 10K to ground. Node A
   has no other path to ground, so the transistor sits saturated with no
   collector current and its small-signal resistance falls as the base
   current rises: about 170 Ω with the follower at 1.93 V, 145 Ω at
   2.31 V, so the centre moves from about 1,185 to 1,270 Hz. Node A
   stays within about ±25 mV. The current is a cubic in node A's voltage
   (the quadratic term gives the band's second harmonic, about 2.5 kHz,
   which the reference has and the slip-zone pass recording shows), its four coefficients tabulated against
   the follower level from 0 to 6 V in 1/32 V steps from SPICE DC sweeps
   of the reference's transistor (`characterize_d1_tr.py`; worst fit
   error 0.18 µA, at follower levels where the transistor turns on), and
   continued linearly beyond ±40 mV (only while the board powers up).
4. **Op-amp**: IC53 a's finite gain-bandwidth (1.2 MHz, the reference's
   macro-model) lowers the centre by about 2.5 %, so it is modelled: the
   output is the integral of the input difference, stepped by backward
   Euler (the capacitors fix the input difference for a given output).
   The output resistance (50 Ω) changes the response by under 0.1 dB and
   is left out. C70 is stepped first and C71 from C70's new charge, which
   keeps the resonance's damping: with both stepped from the old charges
   (plain Euler) the filter rings longer and its output comes out 15 %
   louder than SPICE's (0.6 % with this ordering).
5. **Oscillator** IC53 c: C63 22 µF charged and discharged through R309
   10K from the output; the + input from VR7's wiper (20K across 12 V, a
   Thevenin source) through R351 1K with R307 100K from the output. The
   output slews through an internal node at 0.5 V/µs (a table of the
   macro-model's tanh), as on D-2. While it moves between its limits,
   R307 feeds it back and the input difference grows by e^a in a step
   (a = 0.57); taken from the step's start (Euler) it would grow by 1 + a,
   which made the switching slow and the oscillator 0.17 % slow, so the
   table's linear part is scaled by (e^a − 1)/a. IC53 d follows C63.
6. **Gain** IC53 b: C69 2.2 µF, R347 33K, R346 100K (gain −3.03).
7. **Output**: the 4016 IC54 (300 Ω on) closes while pad J is low (the
   7416 IC56 releases R352's pull-up); its output node has R353 / R354 51K
   to 12 V and ground, and C73 2.2 µF with R412 51K into the D-4 mixer's
   6 V virtual ground.

VR7 is a trimmer. The trace's notes beside it, "2.2 V" and "1.8 V", read
as C63's swing, give a wiper at 0.167 of its travel from the ground end:
C63 then swings 1.93 to 2.31 V, about 19.7 times a second, and the band's
centre is about 1,228 Hz. That is the core's setting for now
(`d1_model.VR7_A7`). Against the recordings (2 November): the slip-zone
pass recording's centre is the same (1,228 Hz), the microphone board's is
higher (1,320 Hz, a wiper near 0.23); both boards warble more slowly
(14.9 and 16.3 Hz) and ring more narrowly than the drawn parts give. These
are for the tuning pass.

In the core, `jtmonacogp_snd_d1.v` steps the whole sheet with one
multiplier and a 901-word table ROM (the slewing node's table and the four
coefficient tables); it is done by clock 61 of the step. Output: the R412
current times R414. The generator is `tests/sound/d1_fixed.py`, which
writes `jtmonacogp_snd_d1.vh`. The noise bit comes from
`jtmonacogp_snd_noise.v` (`nbit`, this step's S2688 output from the step's
second clock).

## D-5/7 hi-score tune

The circuit is in the D-5 trace (its checks of 1 and 2 November). The
floating-point model is `tests/sound/d5_model.py`; the SPICE reference
`tests/sound/spice/d5_hiscore.cir`.

When a game ends with a new best score, sheet A pulses HI SCORE (pad 3,
/HISCORE from pad AF, about 1.3 ms). A small sequencer then plays 17 PROM
rows: each row picks one of three notes and a length; two oscillators
play the note (one per bank of trimmers), a vibrato wobbles it, an
envelope shapes each note through the MC3340, and the result goes into
the D-4 mixer through R408 39K. While the tune plays, the alarm line
(IC35 pin 4) un-mutes SOUND OUT, which is otherwise muted between games.

**Sequencer** (logic, exact at the model step; it settles in eight
passes a step):

1. **Tempo**: IC27, a 74LS132 Schmitt oscillator (R114 1K output to
   input, C106 47 µF and R113 22K to ground), enabled by /END; its
   capacitor is stepped with the exact single-RC factor, with typical
   74LS132 figures (thresholds 1.6 / 0.8 V, output 3.4 / 0.25 V, 0.2 mA
   out of the input below the upper threshold). CLK is its output
   inverted.
2. **Latch 1** (IC37, a NAND pair) is set by HI SCORE: it clears the
   address counter IC22 and holds IC26 loading, and lets go at the first
   CLK high after the pulse.
3. **IC26** (74161) counts each row's length: it loads the PROM's
   duration bits and counts to 15, so a row lasts 16 − duration clocks.
   **IC22** (74393, one 5-bit counter) steps the address when IC26's
   carry rises.
4. **END** = NAND(A0, A4) (IC38): address 17 stops the clock and clears
   IC26 and the 74123; its rising edge fires the IC46 / R267 / C46 pulse
   that resets latch 2. Latch 2 (IC37) is set by HI SCORE.
5. **Alarm**: IC35 pin 4 = NOR(latch 2, MUTE), to D-4's mute gate (IC67
   pin 10). MUTE is sheet A's pad A26 (high after a tilt).
6. **74123**: fired by IC26's /LOAD at each row (cleared by END); R358
   47K, C74 3.3 µF with D29: tw = 0.25·R·C·(1 + 0.7/R[kΩ]) = 39 ms (the
   SN74123 data sheet's constant with the diode).

The PROM (IC21, 74S188, prm40.ic21): bits 0–3 the duration, bit 4 C, bit
5 B, bit 6 A (a low bit grounds that note's branch in both banks through
the IC13 7417s), bit 7 H (low: the IC48 7407 sinks the envelope through
R55 68K, a faster decay). The PROM's rows 0–14 are 52 clocks in all,
rows 15 and 16 (H high, a slow decay) 32.

At power-up the sequencer is parked at address 17 with latch 2 set, as
after a tune; the drawing does not decide it (a real board powers up
anywhere, and might play part of the tune once).

**Analog part** (per step, op-amps ideal inside their output range,
capacitors by Euler unless said):

1. **Vibrato**: the IC1 a integrator (C3 0.47 µF, R14 100K) and the IC1
   b Schmitt (R17 100K, R19 180K) switching TR1 through R18 and D1: a
   triangle of about 10.8 Hz between about 3.86 and 7.59 V, into both note summers through C2/C1
   4.7 µF and R8/R7 1M (a few tens of millivolts on the note voltage).
2. **Note voltages**: IC1 c and d, inverting summers (R4/R3 39K in,
   R9/R6 10K feedback) about the R20 33K / R10 point; their inputs the
   bank nodes (R23 / R1 1K to 12 V, the selected branch to ground).
3. **Sawtooths** (IC2/IC4/TR2 and IC3/IC5/TR3): a two-slope model,
   falling at the integrator's rate, rising at the reset rate, turning
   at points characterized from SPICE (`characterize_d5_vco.py`,
   `data/d5_vco.json`: the comparators' delays and the transistor's
   turn-off carry the turns beyond the thresholds); the time past a turn
   is carried into the other slope. On the first step after power-up the
   integrator's output is taken as the turning rule's start (going up if
   it is below the lower turning point), with no slope applied, so that
   it does not count as a crossing.
4. **Mixer** IC15 c, then the IC6 c Sallen-Key low-pass and the IC6 d
   Sallen-Key high-pass, both stepped exactly (first-order-hold
   matrices).
5. **Envelope**: the 74123's Q (3.4 V behind 100 Ω) through D4 and R49
   1K (tabulated) into C14 6.8 µF with R52 470K and R55 68K (PROM H);
   IC6 a/b make CONTROL = n50 + (n50 − envelope)·R57/R48, n50 the R50 /
   R47 divider of 5 V (C9 47 µF).
6. **MC3340** IC7 through C8 1 µF (the D-6/D-7 table model) with a pole
   for C100 680 pF on pin 6, its output through C15 2.2 µF and R408 into
   the mixer's virtual ground.

**Settings the drawing leaves open:**

- **R10** is drawn 1K over a crossed-out value. With 1K the note
  voltages stay below 0.44 V whatever the trimmers, and the oscillators
  cannot reach the printed notes (in SPICE they give about 68 Hz or
  stall). With **10K** every printed note sits inside its trimmer's
  range, and the recordings (below) fit it; the model uses 10K. R29 is
  overwritten too and is read 51K, like R37.
- **Trimmers** VR1–VR6 (the "ADJ" notes): set so that each note has the
  frequency printed on the drawing, do/mi/so = C/B/A = 262/330/392 Hz,
  with both banks alike (`d5_model.solve_trimmers`: VR4 and VR1 339 Ω,
  VR5 and VR2 454 Ω, VR6 and VR3 615 Ω). Aldo's choice (2 November): the
  trimmers were set by hand at the factory, so the printed figures are
  taken as the factory setting. A setting with the Saturn version's
  notes may come as an OSD option later.
- **Tempo**: with the drawn 47 µF and typical 74LS132 figures a clock
  is 68.0 ms; the recordings run at 37.5–45.6 ms (41.8 ms on average).
  The period scales with C106, so the 74LS132's spread and the
  electrolytic's tolerance are taken together as an effective C106 of
  29.0 µF, which gives 42 ms.
- **DIP SW 1** (4 poles): the fourth, normally closed, grounds the
  PROM's /CE (R112 pull-up) and is taken closed; the other three ground
  note lines, and what each selects is not traced yet (D-5 trace). They
  are taken open and are not in the DIP menu.

**Recordings** (2 November, in the project's reference folder; the
boards all differ):

| Recording | Notes C / B / A | Clock | Row 0 |
|---|---|---|---|
| hiscore_l (line, one board) | 278.5 / 278.5 / 407.8 Hz, one voice | 37.5 ms | about 8 clocks |
| fanfare_mic_board_3 (microphone) | two voices: 293.4+341.4 / 364.6+164.6 / 379.2+159.6 Hz | about 43 ms | |
| fanfare (SEGA 60th anniversary CD, one Tokyo board) | one fixed 1,155 Hz tone for every note | 45.6 ms | about 3 clocks |
| fanfare_saturn (Saturn version, official, not the board) | 293.7 / 277.5 / 371.6 Hz, two voices near unison, vibrato 7–8 Hz | 40.8 ms | 4 clocks |

All follow the PROM's rhythm (rows 13 and 14 two clocks, rows 15 and 16
sixteen with the slow decay) and stop at END. No drawn oscillator can
make 1,155 Hz (190–500 Hz with these parts), so the CD's board is taken
as faulty or different. With R10 1K no recorded pitch is reachable; with
10K hiscore_l and board 3's upper voices are inside the trimmers'
ranges. The model's row 0 lasts about 4.5 clocks (latch 1 lets go at the
first CLK high after HI SCORE); the boards give 3 to 8, an open item.

In the core, `jtmonacogp_snd_d5.v` steps the whole sheet with one
pipelined multiplier (a product issued in one state is read in the
next) and one table ROM of 2,354 36-bit words (the turning points, the
reset rates, the D4 diode and the MC3340's tables); the MC3340 is
computed inline on the same multiplier. It is done by clock 79 of the
step. It holds the PROM's 32 bytes, written from the ROM download
(offset 8768). Output: the R408 current times R414, and the alarm line.
The generator is `tests/sound/d5_fixed.py`, which writes
`jtmonacogp_snd_d5.vh` with the core's settings; the tests read the
SPICE reference's settings from a second include
(`jtmonacogp_snd_d5_ref.vh`, written into the build directory, with
`D5_REF` defined).

## Setting switches (DIP menu)

The MRA's `<switches>` give MiSTer's "DIP Switches" page; each switch is 0
by default:

| dipsw bit | Switch | 0 (default) | 1 |
|---|---|---|---|
| 0 | sheet A changeover switch | 1 COIN 1 PLAY | 1 COIN 2 PLAY |
| 8 | DIP SW. 2, back sound (R424) | closed: the back sound in the front speaker's mix | open |
| 9 | DIP SW. 2 contact 2-15 (R423) | open | closed: a louder explosion |

The board's own positions are not on the drawings. The defaults keep a
single speaker complete (Aldo, 2 November). D-5's DIP SW 1 is not in the
menu: its three note poles are not traced yet (see D-5).

## D-4/7 mixer and SOUND OUT

IC66 b sums the input currents into its 6 V virtual ground through R414 and
is limited to the LM324's range: Vm = 6 V − R414·ΣI, 0.02..10.5 V. The
currents summed so far are MY CAR SOUND's (R411 100K, gain
R414/R411 = 0.22), the explosion's (R401 220K), EXTEND's (R402 220K) and the
skid tone's (R403 220K), gain 0.1 each, the other cars' front sum
(R409 82K, gain 0.27), the front siren (R410 220K, gain 0.1) and the back
sound (R424 100K, gain 0.22, while DIP SW. 2's contact is closed). Vm drives C103 10 µF and R413 1K into the R407 1K /
pad 13 node. The cabinet's amplifier input is taken as 10K (assumed; it is
not on the board). While muted, IC57 sinks the node through R406 100 Ω
(20 Ω on): pad 13 drops to 0.0965 of its unmuted level (−20.8 dB, not
silent), and C103's time constant shortens accordingly.

The sample is pad 13 at 16,384 per volt (full scale 2 V; the sample
saturates beyond it). This gain is provisional and not original circuitry:
the cabinet's amplifier and volume are not modelled. Milestone 1 used 24,576
per volt; with the explosion added that clipped, so it was lowered. In the
test scenario the explosion peaks at about 0.55 V on pad 13 (RMS about
0.35 V), MY CAR SOUND alone at about 0.4 V. Pad 13 can swing about
−5.0..+3.8 V when IC66 b limits. The balance between sounds is to be set
against the real board's recordings once all are built. No filter follows pad 13: the board's own coupling
capacitors (C72, C103) are its only high-pass. At power-on C103 charges from
0 V, which gives the board's power-on thump; in the game it comes muted (no
COIN IN), about 0.5 V decaying in 11 ms.

## Checks

Four layers, each against the one above it:

1. **SPICE reference** (`tests/sound/spice/d3_mycar.cir`, ngspice 42):
   the D-3 sheet wired pin by pin from the trace, with behavioural LM324 and
   TL081 macro-models (`opamps.lib`: rails, slew rate, output resistance),
   CD4016 switches, open-collector outputs, MA150 diodes, 2SC458
   transistors (`parts.lib`) and the transistor-level MC3340. Two scenarios
   from power-on with every capacitor at 0 V (`d3_reference.py`): **full**,
   3 s of S-ACCE codes, SHIFT A and MY CAR SOUND ON changes; **cells**, the
   lag forced to 0.5..10.5 V in steps, shift off and on. Their measured
   features are stored in `tests/sound/data/d3_spice_*_features.json`, so
   the test suite does not need ngspice.
   The D-4 sources have their own netlist (`spice/d4_effects.cir`, with a
   behavioural NE555 in `ne555.lib`: XSPICE comparators, latch and
   discharge switch). Its scenario (`d4_reference.py`), 2 s from power-on:
   a crash 0.05–0.30 s (explosion and skid), off the road 0.45–0.80 s (the
   skid alone), EXTEND's beep 0.85–1.32 s, a second crash 1.40–1.70 s
   while the first rumble still decays. The S2688 bits and the 74123
   pulses are made by the model's own logic and fed to SPICE as sources,
   so both hear the same noise. Its features, per 50 ms window, are in
   `data/d4_spice_features.json`. ngspice stopped at 0.856 s ("timestep
   too small" at IC65's output, where the transistor-level MC3340 has no
   junction capacitance) until 10 pF was put on each MC3340 output and the
   Gear method used; 10 pF is about what the pin and its wiring add.
   `ne555.lib` first turned the comparators' outputs into logic levels
   with a band of ±1 µV: where a slow ramp met the threshold inside that
   band, XSPICE gave the latch an unknown state, and OUTPUT sat between
   its levels for 0.1–0.23 ms (six times in the first D-4 run, found on
   2 November while building D-2). The band is now ±1 pV, and the D-4
   reference was run again (75 minutes). It was run once more on 4 November
   with the MC3340 control offset below (ngspice 47, 23 minutes; the stored
   features are from it): the stages before the MC3340s moved by about 1 mV
   at most against the ngspice 42 run, so the version changes nothing here.
   The largest MC3340 output mean difference became 5.3 mV, and its tolerance
   went from 5 to 6 mV.
   ngspice keeps only the written vectors (`save`), which keeps a long
   run's memory to tens of megabytes.
   The other cars have theirs (`spice/d67_cars.cir`, with a smoothed
   LM339 and CD4016 and the transistor-level MC3340s). Its scenario
   (`d67_reference.py`), 3 s from power-on: S-ACCE code 2, then 5 from
   0.5 s and 7 from 2.0 s; pad C low for one step at the start of every
   frame from 0.3 to 2.6 s. Features per 50 ms window in
   `data/d67_spice_features.json`. XSPICE gates start with every input
   low, which fired car 1's one-shot at t = 0; the netlist holds the
   one-shots' triggers low for the first millisecond (an AND with a
   power-on signal, not on the board). Run time 40 minutes; with ngspice
   keeping only the written signals its memory went from several GB to
   32 MB, with the same results.
   D-2 has its own (`spice/d2_rescue.cir`). Its scenario
   (`d2_reference.py`), 6 s from power-on: pad P low for 20 ms at 1.0 s
   and at 3.0 s (the second while the front envelope still rises), BACK
   SOUND STB. sunk from 5.0 to 5.5 s, and from 0.2 s a 400 Hz sine of
   0.5 V behind 51K on BACK OTHER CAR (a test signal). Features per 50 ms
   window in `data/d2_spice_features.json`; run time about 15 minutes.
   Its first run found the NE555 band problem above: C47's slow ramp
   sat in the band as it crossed the trigger level, and the latch stayed
   unknown for most of the run. The stored run is the corrected one.
   D-5 has its own (`spice/d5_hiscore.cir`): the analog part, driven by
   the model's sequencer (the PROM's A, B, C, H bits and the 74123's Q as
   sources, so both see the same note changes). Its scenario
   (`d5_reference.py`), 3 s from power-on: HI SCORE low for 1.3 ms at
   0.2 s, MUTE low; to fit the whole tune into the run the sequencer runs
   on a test tempo (C106 18.8 µF, 2.5 times faster than the core's), and
   the lower bank is set a semitone below the printed notes so that the
   two voices are distinct (identical voices add in whatever phase their
   start leaves them). Features per 50 ms window in
   `data/d5_spice_features.json`; run time 73 minutes with a 0.1 µs
   maximum step (at 1 µs the sawtooth's period is 1.8 % off). With the
   default trapezoidal method the first run stalled at 0.9488 s, where
   note B gives way to C as the 74123 fires, and made no progress for
   three hours; the netlist uses Gear, as D-4's.
2. **Floating-point model** (`d3_model.py`) against SPICE (`d3_check.py`):
   closed loop, cell frequencies within 0.24 % (cells) and 0.6 % (full),
   lag within 0.27 mV, output RMS within 2.5 %; driven block by block with
   SPICE's own inputs, point by point, MC3340 output within 0.052 V (full)
   and 0.084 V (cells), CON within 0.077 V.
   D-4 (`d4_model.py`, `d4_verilog_check.py model`), per 50 ms window
   over the 2 s scenario: the noise amplifier's RMS within 7.5 mV, the
   band-passes' within 0.033 V (of about 2 V), the envelopes within 9 mV,
   the MC3340 controls within 1.2 mV, the MC3340 outputs within 0.018 V
   and IC66 a within 0.045 V RMS (of up to 4.5 V), the mixer currents
   within 4.5 mV (times R414); the 555's cycles within 0.08 % over the run
   (3 in a window, from phase), the triangle's period within 0.12 %.
   D-6/D-7 (`d67_check.py model`), per 50 ms window over the 3 s
   scenario: the 74123 pulses start within 2 µs (one step) of SPICE's,
   the same three; ramps within 0.044 V, IC15 within 0.021 V, the four
   CONTROLs within 0.027 V and CAR CON within 0.027 V (means); the cells'
   cycles within 1 per window and 0.30 %, 0.13 %, 1.04 % and 0.12 % over
   the run; the bank CONTROL nodes' RMS 5–8 % below SPICE's (about
   1.1 V; cause not found yet: the CONTROL pin's linear source is the
   first suspect), the front sum's RMS within 2.7 % on average (worst
   window 17 %, near the reset where the level is small). Step-to-step
   flips (both of two consecutive changes above 0.2 V, opposite signs) of
   IC32 b and the two bank output nodes: 2 / 2 / 2 over the run (SPICE,
   resampled to the steps: 0 / 1 / 0); at most 8 allowed.
   D-2 (`d2_check.py model`), per 50 ms window over the 6 s scenario: the
   siren tone's cycles within 1 per window and 0.05 % over the run (about
   34 per window: 700 and 650 Hz with the 555); the 555's edges within
   0.5 ms (SPICE's supplies rise over the first millisecond); the
   comparators' and latches' edges, the same 24, within 2.3–4.8 ms (the
   envelopes' falls 0.2–0.7 % shorter or longer than SPICE's); envelope
   means within 0.015 V (rear) and 0.054 V (front, in the window of its
   fast fall), CONTROLs within 0.019 V; the RMS of the MC3340 outputs, IC40 b,
   node Z, pad R and IC44 b within 0.06–0.15 V of up to 5 V (worst in the
   windows where an envelope switches; elsewhere within a few mV).
   D-5 (`d5_check.py model`), per 50 ms window over the 3 s scenario: the
   notes' frequencies within 0.8 Hz (upper bank) and 1.6 Hz (lower) of
   about 245 to 390 Hz, in the windows where the note holds (in the six
   where a note changes the measure depends on where the change falls,
   so it is left out); the note voltages within 2.2 mV, the envelope
   within 4.8 mV, CONTROL within 1.9 mV (means); the sawtooths', mixer's
   and filters' RMS within 0.035 V of about 1 V; the MC3340's output and
   the R408 current within 0.0083 V RMS. The vibrato runs about 0.08 %
   slow, so its phase drifts by about 2.3 ms over the run (window means
   within 0.22 V at the end). Driven by SPICE's own signals, the
   filters follow within 0.012 V (RMS difference 2 mV) and the MC3340
   chain within 0.061 V (RMS difference 3 mV).
3. **Fixed-point twins** (`d3_fixed.py`, `d4s_fixed.py`, `d4_fixed.py`): the Verilog's
   arithmetic operation for operation. Against the floating-point model
   over 3 s: lag and CV equal, cell outputs and CON within 0.016 V, MC3340
   output within 0.11 V (from phase). D-4 (`d4s_fixed.py check`): every
   signal within 2 µV of the floating-point model over the 2 s scenario,
   the same 555 edges. D-2 (`d2_fixed.py check`): the envelopes and
   CONTROLs equal, every comparator, latch and 555 edge at the same step;
   over the 6 s scenario the sawtooth discharges 4,055 times in both, each
   discharge within 65 steps (0.14 ms) of the model's. D-5
   (`d5_fixed.py check`): the sequencer identical at every step; over the
   3 s scenario the upper sawtooth turns within one step of the model's,
   its level within 2 mV.
4. **Verilog** against the twins, bit for bit, every step, and against the
   SPICE features (`scripts/run_tests.py`):
   - `tb_snd_d3`: D-3 alone, the full scenario, 1,440,000 steps;
     `d3_verilog_check.py` compares every step with the twin and the
     waveform features with SPICE. Result (1 November): every step equal
     to the twin; against SPICE, cell frequencies within 0.60 %, lag within
     0.27 mV, CON mean within 0.025 V, MC3340 output mean within 0.080 V and
     RMS within 2.4 %, the mixer current's RMS within 1.7 %.
   - `tb_snd_d4`: the D-4 sources alone (`jtmonacogp_snd_noise.v`,
     `jtmonacogp_snd_expl.v`), the D-4 scenario below, 960,000 steps;
     `d4_verilog_check.py` compares 21 signals with the twin at every step
     and the window features with SPICE. Result (2 November): every step
     equal to the twin; all features within the tolerances, with the same
     differences as the floating-point model.
   - `tb_snd_d67`: the other cars alone (`jtmonacogp_snd_d67.v`), the 3 s
     D-6/D-7 scenario, 1,440,000 steps, under Verilator (Icarus would take
     over two hours); `d67_verilog_check.py` compares 28 signals with the
     twin at every step and the window features with SPICE. Result
     (2 November): every step equal to the twin; finished by clock 84;
     all features within the tolerances (the same differences as the
     floating-point model); 3 / 2 / 2 step flips (at most 8).
   - `tb_snd_d2`: D-2 alone (`jtmonacogp_snd_d2.v`), the 6 s D-2
     scenario, 2,880,000 steps, under Verilator; `d2_verilog_check.py`
     compares 22 signals with the twin at every step and the window
     features with SPICE. Result (2 November): every step equal to the
     twin; finished by clock 82 (79 before each latch pass was split
     over two clocks, for timing); all features within the tolerances.
   - `tb_snd_d1`: D-1 alone (`jtmonacogp_snd_d1.v`), the 3 s D-1
     scenario, 1,440,000 steps, under Verilator; `d1_verilog_check.py`
     compares 7 signals with the twin at every step and the window
     features with SPICE. Result (2 November): every step equal to the
     twin; finished by clock 61; all features within the tolerances.
   - `tb_snd_d5`: D-5 alone (`jtmonacogp_snd_d5.v`) with the reference's
     settings (`D5_REF`), the 3 s D-5 scenario, 1,440,000 steps, under
     Verilator; its PROM from the PROM image through the download port.
     `d5_verilog_check.py` compares 17 signals with the twin at every step
     and the window features with SPICE (with the original PROM set only).
     Result (2 November): every step equal to the twin; finished by clock
     79; all features within the tolerances, with the same differences as
     the floating-point model.
   - `tb_sound`: the board top at 48 MHz, 0.3 s of play-like inputs (with
     two EX.CP bursts, an off-road stretch, a /RESCUE CP pulse, a slip
     zone, a HI SCORE pulse at 10 ms that starts the tune, and MUTE high
     through the first half of COIN IN's release), then all 32
     combinations of the five gate inputs (with /RESCUE CP pulses,
     /SLIPZONE low in every third, MUTE high in every other one, and the
     back-sound contact open in the second half); inputs change mid-step.
     `sound_check.py` compares the gates, D-3's, the other cars', D-2's,
     D-1's and D-5's currents, D-5's alarm line, pad R, pad 13 and every
     sample of both channels with the twin (D-5 with the core's settings
     and the PROM the testbench loaded), checks that the tune played with
     the alarm line both high and low, and writes `build/tests/sound.wav`
     and `sound_back.wav`. Result (2 November, under Verilator as a
     quick check): every one of 150,400 steps equal to the twin; the tune
     playing in 145,600 of them, 135,200 with the alarm line high.
   - `tb_play_sound`: the connected sheets with the sound board from
     power-up into a game (coin, pedal, both gears); checks the gates
     against the game state, a sample every 1,000 clocks, the engine heard
     in the game and not before the coin, and the same bit-exact comparison
     (`play_sound.wav`).

To regenerate the references (needs ngspice):

    cd tests/sound
    python3 characterize_mc3340.py        # build/sound/mc3340_dc.json
    python3 mc3340_fit.py                 # data/mc3340_tables.json
    python3 d3_reference.py full ../../build/sound     # about 5 minutes
    python3 d3_reference.py cells ../../build/sound    # about 2 minutes
    for s in full cells; do
        python3 d3_check.py features ../../build/sound/d3_spice_$s.npz data/d3_spice_${s}_features.json
        python3 d3_check.py driven ../../build/sound/d3_spice_$s.npz
        python3 d3_check.py model $s ../../build/sound/d3_model_$s.npz
        python3 d3_check.py compare data/d3_spice_${s}_features.json ../../build/sound/d3_model_$s.npz
    done
    python3 d3_fixed.py check
    python3 d3_fixed.py vh ../../cores/monacogp/hdl/jtmonacogp_snd_d3.vh
    python3 d4_reference.py ../../build/sound/full    # about 70 minutes
    python3 d4_verilog_check.py features ../../build/sound/full/d4_spice.npz data/d4_spice_features.json
    python3 d4_verilog_check.py model ../../build/sound/d4_model_features.json
    python3 d4s_fixed.py check
    python3 d4s_fixed.py vh ../../cores/monacogp/hdl
    python3 d4_fixed.py vh ../../cores/monacogp/hdl/jtmonacogp_snd_mix.vh
    python3 characterize_d7_reset.py      # data/d7_reset_tr.json
    python3 d67_reference.py ../../build/sound        # about 40 minutes
    python3 d67_check.py features ../../build/sound/d67_spice.npz data/d67_spice_features.json
    python3 d67_check.py model
    python3 d67_fixed.py check
    python3 d67_fixed.py vh ../../cores/monacogp/hdl
    python3 characterize_d2_tr16.py       # data/d2_tr16.json
    python3 d2_reference.py ../../build/sound/d2      # about 15 minutes
    python3 d2_check.py features ../../build/sound/d2/d2_spice.npz data/d2_spice_features.json
    python3 d2_check.py model
    python3 d2_fixed.py check
    python3 d2_fixed.py vh ../../cores/monacogp/hdl
    python3 characterize_d1_tr.py         # data/d1_tr.json
    python3 d1_reference.py ../../build/sound/d1      # about 17 minutes
    python3 d1_check.py features ../../build/sound/d1/d1_spice.npz data/d1_spice_features.json
    python3 d1_check.py model
    python3 d1_fixed.py check
    python3 d1_fixed.py vh ../../cores/monacogp/hdl
    python3 characterize_d5_vco.py        # data/d5_vco.json
    python3 d5_reference.py ../../build/sound/d5      # about 75 minutes
    python3 d5_check.py features ../../build/sound/d5/d5_spice.npz data/d5_spice_features.json
    python3 d5_check.py model - ../../build/sound/d5/d5_spice.npz
    python3 d5_fixed.py check
    python3 d5_fixed.py vh ../../cores/monacogp/hdl

## Assumptions and uncertainties

Agreement with SPICE shows that the core computes what the drawn circuit
does with these part models. It is not a measurement of a real board.

- Part figures are typical data-sheet values or SPICE model parameters
  (`tests/sound/sound_parts.py`), none measured on a Monaco GP board: the
  LM324's output limits (0.02 V, V+ − 1.5 V), slew and output resistance;
  the 2SC458 switching level (3.72 V) and saturation; CD4016 on resistance
  (300 Ω at 12 V); the MA150 diode.
- The comparator delay (`CMP_OVER`) is fitted to the SPICE macro-model, not
  to a real LM324.
- The MC3340 is Motorola's internal schematic with generic transistors; its
  error is largest near the input's collapse edge.
- R414 is 22K, clear at full resolution in all three scans (D-4 trace, 4
  November); it sets the engine's level in the mix. R409 (other cars) is 82K and R408 (D-5)
  39K, both read again on 2 November (D-4 trace).
- D-4: the S2688's clock (100 kHz) and output levels (3.0 / 10.5 V) are
  MM5837 figures, not measured on this chip; they set the noise's colour
  and the explosion's and skid's loudness. R361 is read 150K (the
  glyph is written like an R in all three scans, which are copies of one
  drawing; 150 ohms would clip the stage, D-4 trace, 4 November); it sets the
  noise level.
- D-4: the 74123 width uses the data sheet's K = 0.28 and nominal 4.7 µF
  tantalums; a real board's capacitors may differ by ±20 %.
- D-4: the NE555's output levels on 5 V (3.3 V / 0.05 V) are typical
  figures; the skid tone's level follows them.
- D-4: DIP SW. 2 contact 2-15 (R423, a louder explosion) is open by
  default in the DIP menu; the board's setting is not on the drawing.
- D-4: the MC3340 supply is not drawn and is taken as 12 V.
- D-4: the band-passes' Euler step raises their peak gain by about 2 %
  (against an 8 times finer step); against SPICE the explosion comes out
  about 1.5 % louder.
- D-7: R190 is taken as 6.8K, read on a board photo; the schematic writes
  68K, with which car 2's CAR CON would stay at the rail (D-7 trace). It
  sets car 2's pitch.
- D-7: the TL081's limits (1.5 V from each rail) and output resistance
  (50 Ω) are the reference's macro-model figures; the ramps' hold time
  after a reset depends on the upper limit. The 22 µF ramp capacitors and
  the 74123 timing parts are nominal (±20 % on a real board).
- D-6: the bank MC3340's CONTROL pin is modelled as a 5.53 V source behind
  4.70 kΩ, a fit to the transistor-level model within 3.2 µA from −3 to
  7 V; outside that range the pin is not characterised.
- D-6/D-7: the five blocks see each other's outputs one step (2.08 µs)
  late, which the reference does not; its effect is part of the
  differences below.
- D-2: the symmetric latch pairs (IC42 d/a, IC43 b/c) power up as the
  reference's do (IC42 pin 1 low, IC43 pin 7 low); the drawing does not
  decide it. TR16's collector current is a table from the reference's
  2SC458; D32 (MA80) is taken as an MA150. The 555's output on 12 V is
  taken as 10.3 V high (V+ − 1.7 V) and 0.05 V low.
- D-2: pad R's load (the back speaker's amplifier) is taken as 10K, like
  SOUND OUT's. DIP SW. 2's back-sound contact is closed by default (the
  board's setting is not on the drawing).
- D-2: the MC3340s and IC40 b see the sawtooth, the CONTROLs and BACK
  OTHER CAR one step (2.08 µs) late.
- D-1: the 2SC458 is the reference's generic model (hFE 250, BR 5); the
  band's centre against C63's level depends on its saturation
  resistance. VR7 is set from the trace's voltage notes (0.167 of its
  travel); C63 is a nominal 22 µF tantalum (±20 % on a real board), which
  with VR7 sets the warble's rate. Pad J takes /SLIPZONE by its name; the
  connector between the boards is not drawn.
- D-1: against the 3 s SPICE run, the floating-point model's oscillator
  starts 0.78 ms early (SPICE's supplies rise over the first millisecond)
  and runs 0.045 % slow; in 50 ms windows the band's centre differs by up
  to 2.7 Hz and IC53 b's RMS by up to 2 %.
- D-5: R10 is 10K, R29 51K (both hand-corrected or overwritten on the
  drawing); the six trimmers are set to the printed notes and the tempo
  to the recordings' mean (42 ms a clock) through an effective C106 of
  29.0 µF; these are settings, not readings (see D-5). The 74LS132's
  thresholds and input current, and the 74123's constant, are typical
  data-sheet figures. DIP SW 1's three note poles are taken open. The
  sequencer powers up parked at address 17. The first note lasts about
  4.5 clocks in the model; the recordings give 3 to 8.
- D-5: the sawtooths' turning points and reset rates are characterized
  from the reference's TL081/2SC458 models (`characterize_d5_vco.py`);
  the MC3340 is the D-6/D-7 table model. The alarm reaches D-4's mute
  gate one step (2.08 µs) late.
- D-7: pad C (/F-SOUND, sheet H IC75 b) goes low only when the strobe line
  of an other car rises while H8 and H6 are low. In the game-level
  simulations (tb_play_sound, and tb_play up to its time limit, with the
  original PROMs) it never did, so the other cars' restart has been
  checked only with the scenario's own pad-C pulses, not from the game.
- The cabinet amplifier's input (10K) is assumed.
- The 6 V reference is taken as ideal.
- The output level is not calibrated: Aldo's real-board recordings are the
  reference for the level and timbre of each sound, to be compared once more
  sounds are built.

## Open issues reported on the MiSTer (2 November 2026)

Aldo played build `jtmonacogp_20261102d.rbf` (commit 350811c, D-1 to D-7)
on his MiSTer and reported the following. His
recordings are in the project files under `reference/recordings/`
(`passing_cars/pass_1..5.wav`, `pass_skid.wav`, `pass_stop.wav`,
`service_car.wav`: by their content these are from a real board;
`mister/passing_core.wav`: the core, line out).

1. **Passing cars sound awful about one time in two** ("quacking digital
   noise"). Two causes, both in the model:
   - The D-7 inputs' current taken whole from the previous step made the
     bank output nodes and IC32 b flip by 4 to 5 V between steps (fixed 2
     November, see the D-6/D-7 section). Aldo heard that build on 3
     November: the pass still sounded like a "beep".
   - The beep is the envelope: with the ramps limited at 10.5 V each reset
     held the note at its loudest and highest point for about 0.6 s. The
     ramps' upper limit is now 12 V, fitted to the board clips (3
     November, see "The ramps' upper limit" in the D-6/D-7 section);
     not yet heard on the MiSTer.
   Measured before both fixes:
   - The core's pass matches the simulation of `jtmonacogp_snd_d67.v` (same
     lines at 146, 404, 545, 691 and 1,641 Hz), so it is the model, not the
     FPGA build.
   - The board's pass (all seven clips alike): lines at 141, 475, 533, 615
     (strongest), 756 and 1,230 Hz, i.e. a ~615 Hz cell on the bus
     amplitude-modulated by the ~141 Hz cell, and a ~533 Hz cell on
     CONTROL. The model's cells run at 624 (cell 1, CONTROL), 548 (cell 2)
     and 145 Hz (cell 3), so its bus carries 548 ± 145 Hz instead. The
     frequencies agree within about 12 % (the board spread seen on the
     engine); the roles of the two upper cells look swapped, possibly the
     factory-adjusted cell 1 (C21 6800P ∥ 470P "ADJ") set lower on that
     board.
   - Envelope: on the board each pass swells in by 12–15 dB over about
     0.65 s, with the pitch rising about 4 %, then falls faster (measured
     again 3 November with a 120 ms window). In the
     model car 1 starts at full level, stays constant for about 0.63 s
     (its ramp sits at the integrator's upper limit while C30 recharges),
     then car 2's voice takes over about 8 dB lower.
   - Car 2's voice in the model (CAR CON 2 at 9.65 V) has cell 1 at 660 Hz
     and an 80 Hz beat (lines 82, 152, 504, 580, 662, 732, 814 Hz); no board
     clip shows it.
   - IC32 b (front sum, R426 33K) clips at its 10.5 V limit for about 8 %
     of the time on car 1's loud part, adding harmonics around 1.5 to
     1.8 kHz that the board clips do not have.
   - The core recording has short clicks (a few ms, up to 8 times the
     local level) at 3.09, 4.17, 4.91, 5.85 and 6.32 s; source not yet
     identified.
   Aldo (2 November): the bad sound is the first car's voice, the passes at
   about 0.1, 1.4, 2.9, 4.3 and 6.2 s of `passing_core.wav`; the second
   car's voice is probably wrong too.
2. **Slip zone too low.** Aldo's first target was the microphone board
   (1,320 to 1,330 Hz, VR7 about 0.22); on 2 November he decided to leave
   the slip zone as it is (VR7 0.167, about 1,228 Hz).
3. **Rescue (service) car siren pitch.** `service_car.wav` (board): two tones
   at 492.2 and 524.4 Hz, switching about every 0.30 s. The model's 555
   switching (0.325 / 0.321 s) agrees; its tones (700 / 650 Hz) are about
   30 % high, with the same ratio (board 0.939, model 0.929). The scan reads
   C49 0.033, R232 30K, R233 3.9K, R235 12K, R234 / R416 51K, R231 680 Ω
   (checked again 2 November). Aldo decided to leave the pitch as it is.
4. **Rescue siren sometimes missing until the car is halfway down the
   screen.** Aldo (2 November): the same behaviour is confirmed on the real
   hardware, so it is original and is left as it is.

## Hardware cost

D-3: one 36 × 27 multiplier, 2,906 × 36 bits of table ROM, about 85 clocks
per 100-clock step. Mixer: one more multiplier. D-4: the noise and skid
block one multiplier; each band chain one multiplier and 2,135 × 36 bits of
table ROM; IC66 a one multiplier.

Quartus 20.1.1 (`scripts/build_mister_docker.sh`, 2 November 2026, on main
with sheets I, J and K): D-3 2,291 ALMs, 18 M10K, 3 DSP blocks; the noise
and skid block 1,213 ALMs, 5 DSP (two for the 555's output mean); the
explosion 3,365 ALMs (each band chain about 1,385), 36 M10K, 9 DSP; the
mixer 453 ALMs, 3 DSP. The sound board in all: 7,345 ALMs, 54 M10K, 20 DSP
blocks. The whole MiSTer build: 20,323 ALMs (48 %), 415 of 553 RAM blocks,
60 of 112 DSP blocks. Timing met: setup slack +1.84 ns on the 48 MHz clock,
hold +0.241 ns.

With the other cars (Quartus 20.1.1, same script, 2 November 2026): D-6/D-7
10,021 ALMs, 58 RAM blocks, 36 DSP blocks (each bank about 1,870 ALMs and 6
DSP, each car's pair of MC3340s about 2,060 and 9, the control 1,694 and 3,
the top 454 and 3; each MC3340 8 RAM blocks for its 1,750-word table). The
sound board in all: 17,433 ALMs, 112 RAM blocks, 56 DSP blocks. The whole
MiSTer build: 30,348 ALMs (72 %), 473 of 553 RAM blocks (86 %), 96 of 112
DSP blocks (86 %). Timing met: setup slack +0.878 ns on the 48 MHz clock,
hold +0.247 ns. What is left (80 RAM blocks, 16 DSP blocks) will not hold
D-1, D-2 and D-5 built the same way: their MC3340s and oscillators will
have to share multipliers and table ROMs.

With every sheet (Quartus 20.1.1, same script, 2 November 2026, commit
350811c): D-5 2,732 ALMs, 19 RAM blocks, 3 DSP blocks (one multiplier,
the MC3340 computed on it); D-1 1,633 ALMs; D-2 3,621 ALMs. The sound
board in all: 25,063 ALMs, 151 RAM blocks, 71 DSP blocks. The whole
MiSTer build: 38,457 ALMs (92 %), 512 of 553 RAM blocks (93 %), 111 of
112 DSP blocks (99 %). Timing met: setup slack +0.683 ns on the 48 MHz
clock (+0.260 ns on the HDMI clock), hold +0.183 ns. The first build of
this design missed 48 MHz by 0.745 ns on two paths, both fixed without
changing a result: the picture's logic into the flip frame buffer's data
input (the colour is now registered at the pixel enable and written a
clock later) and D-2's rounding and shift after the state decoding (the
shift is now registered with the product). Quartus 17.0.2 (an older
version than JTCORES pins) does not fit this design: it builds the
graphics PROMs and the rank memory from registers.
