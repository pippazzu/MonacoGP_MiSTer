# Handle (steering) board 96599-P

Source: Sega **Monaco GP (420-0358)** manual, PDF page **14**,
manual 420-0358, PDF page 14 (3328 × 2560, stored
upright), "HANDLE, LOGIC DIAGRAM (ACCELERATOR BOARD)", title block
"96599-P IC BOARD ASS'Y". Coordinates are stored-image pixels. Read on
full-resolution crops (150,450)-(1200,2000), (1150,600)-(2000,2000),
(1700,700)-(3200,2050). The board is small and sparse: every junction is a
drawn dot, every other crossing plain.

## Parts

| Ref | Part | Notes |
|---|---|---|
| IC1 | 7414 | hex Schmitt inverter, drawn as triangles with the hysteresis mark and an input or output bubble ("C" above each section) |
| IC2 | 74107 | dual J-K flip-flop, negative-edge clock, active-low clear ("74107/2" per half; "D" inside each) |
| IC3 | 7400 | quad NAND ("E" inside each section) |
| TR1, TR2 | 2SC458 | NPN |
| sensors | PS4001 or EE-SG3-B (Omron photo-micro sensor) | slotted IR LED / phototransistor pairs, outline drawing at the bottom |
| LED1, LED2 | LED | "MONITOR LED" in the collector loads |
| R1, R2, R5, R6 | 1 kΩ | |
| R3 | 220 Ω | |
| R4 | 150 Ω | |
| C1 | 3.3 µF | supply decoupling |
| C2 | 0.1 µF | supply decoupling |
| C3, C5 | 2200 pF | collector to base of TR1, TR2 |
| C4 | 1 µF | (a note under it reads like "9-91", not a value) |

## Connector

| Pin | Signal |
|---|---|
| 1 | Vcc |
| 2 | HAN-L-CP → (F) |
| 3 | HAN-R-CP → (F) |
| 4 | ground |

## Front end (both channels alike)

- The two sensors' IR LEDs are in series: Vcc → sensor 1 A–K → R4 150 Ω →
  sensor 2 A–K → ground.
- Sensor 1 phototransistor: C to Vcc, E → TR1 base, with R2 1 kΩ to
  ground. TR1: emitter to ground, collector → LED1 → R1 1 kΩ → Vcc, and
  C3 2200 pF from collector to base. TR1 collector → IC1.13.
- Sensor 2 likewise: E → TR2 base (R5 1 kΩ to ground), TR2 collector →
  LED2 → R6 1 kΩ → Vcc, C5 2200 pF collector to base, collector → IC1.11.
- So when a slot lets the light through, the transistor conducts, its
  collector is low, and the Schmitt output is high: **A = IC1.12** (sensor
  1 lit), **B = IC1.10** (sensor 2 lit).

## Logic

| Part / pin | Connection |
|---|---|
| IC1 13 → 12 | A: → IC2.12 (1CK), IC3.9, IC2.8 (2J), IC2.11 (2K) |
| IC1 11 → 10 | B: → IC2.9 (2CK), IC2.1 (1J), IC2.4 (1K), IC3.2 |
| IC2 1Q 3 | → IC3.1 (1/Q 2 open) |
| IC2 2Q 5 | → IC3.10 (2/Q 6 open) |
| IC2 1CLR 13, 2CLR 10 | → IC1.8 |
| IC3 1, 2 → 3 | NAND(1Q, B) → IC1.3, IC3.4 |
| IC3 9, 10 → 8 | NAND(A, 2Q) → IC1.1, IC3.5 |
| IC1 3 → 4 | **HAN-L-CP** (pin 2) |
| IC1 1 → 2 | **HAN-R-CP** (pin 3) |
| IC3 4, 5 → 6 | drawn OR with input bubbles = NAND(IC3.3, IC3.8) → R3 220 Ω → node with C4 1 µF to ground → IC1.9 |
| IC1 9 → 8 | → both CLRs |

## Behaviour

- IC2's first half has J = K = B and clocks on A falling: it toggles when
  A falls while B is high. The second half has J = K = A and clocks on B
  falling: it toggles when B falls while A is high. Turning one way, A
  falls with B high once per slot; the other way, B falls with A high.
- HAN-L-CP = 1Q AND B, HAN-R-CP = A AND 2Q (each through a NAND and a 7414
  inverter): a pulse starts at that falling edge.
- IC3.6 = HAN-L-CP OR HAN-R-CP charges C4 through R3 (τ = 220 µs). When C4
  passes the 7414's upper threshold, IC1.8 goes low and clears both
  flip-flops: the pulse ends. C4 then discharges through R3 into IC3.6
  (low), and the clear lifts when it falls below the lower threshold. With
  typical LS levels (output high about 3.4 V, thresholds about 1.7 V and
  0.9 V) the pulse lasts about 0.15 ms and the clear about 0.29 ms more. A
  pulse also ends early if its own sensor's line falls first.

## Unresolved

1. The analog front end (2200 pF collector–base, LED loads) shapes the
   edges; the Schmitt inputs remove its slowness. Not modelled beyond the
   logic levels.
2. The RC times depend on the 7400's output levels into 220 Ω and on the
   7414's thresholds, which vary between parts; the values above are
   typical.
3. The slotted disc (number of slots, spacing of the two sensors) is not
   drawn, so how many pulses one turn of the wheel gives is unknown.
