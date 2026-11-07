# Pro sheet N logic (jtmonacogp_bonus)

`cores/monacogp/hdl/jtmonacogp_bonus.v` implements every gate, flip-flop,
counter and one-shot of Pro Monaco GP sheet N, the bonus circuit (manual
420-0525, PDF page 12, board 96822-P D-5/5). It follows the second-pass pin
tables and wire ledger in [trace/SHEET_N_TRACE.md](trace/SHEET_N_TRACE.md).
What N's inputs mean on the Pro board is in
[trace/BONUS_INPUTS_TRACE.md](trace/BONUS_INPUTS_TRACE.md) (issue #36).
The module only has to match the drawing; `jtmonacogp_game.v` connects it
with `PRO = 1` (see "Pro board" below, issue #71).

## What the sheet does

All of this follows from the drawn wiring and the data-sheet functions of
the parts. Signal names are the drawn labels.

- **Reset.** IC95 (5, 4 → 6) gives W01, which is high while /COIN & TEST or
  /INI. RESET is low. W01 clears IC80 and, through IC102, IC94. IR inverts it
  to W02, which clears IC81 and IC132 (through IC53) and loads IC140 with 0.
- **Car count.** IC100's first half (A = /OTHER CAR, B = PLAYER ST,
  /CLR = /SCORE ST, about 44 ms) clocks IC132 (74161) from its /Q. So
  IC132 counts at the end of each pulse. IC100's second half (A = /BRIDGE
  AP, B = PLAYER ST, /CLR = GPR = NAND(PR-38-7, PR-38-9), about 13 ms)
  disables the count through ENP and ENT while it runs. IC132 is cleared by
  IC53 = AND(IC143.6, GAME, W02), and IC143.6 = NAND(PR-38-7, PR-38-9,
  IC100.13) · /ACC1.
- **Bonus pulse.** IC108.6 = (IC132 RCO · IC100.13) + (IC100.5 · PLAYER
  ST) is the B input of IC107's second half (A = /OTHER CAR, /CLR = /SCORE
  ST, about 44 ms). Its Q goes through IC72 (NOR with IC80.9) and IC108
  (OR with IC140's MAX/MIN) to IC140's clock. So IC140 steps at the end of
  the pulse, and the same edge fires IC107's first half: BONUS CP and
  /BONUS CP, about 0.29 s. 16 car-count pulses give one bonus.
- **Bonus store.** IC140 (74191) counts up while /GAME is low (R34 to
  D/U). At 15, MAX/MIN goes high and holds IC108.3 high, so no further
  clock reaches it: the count stays at 15.
- **Payout.** /GAME rising clocks IC94 (D at Vcc) unless MAX/MIN, now
  counting down, holds its clear. IC94's Q opens V5 through IC101 (12, 13
  → 11). IP inverts that into /BONUS POINT for sheet F, and the same
  signal clocks IC81 (÷2) and IC80 (÷10, ÷10). Every 200th falling edge,
  IC80.9 falls and IC140 steps down. At 0, MAX/MIN goes high and clears
  IC94, just after the falling edge that ended the last pulse. So the
  payout is stored bonuses × 200 pulses. /GAME END (IC95.8 → IC126 → M5) is
  low once /GAME is high and IC94 is clear.
- **Outputs.** IC133 sends IC132's count while V2 is low and IC140's while
  V2 is high to BONUS A–D (M1–M4). BONUS SOUND = NAND(NAND(V4, BONUS CP),
  NAND(IC100.13, IC132 QC, QD, V2)).

## Readings fixed in the model

| Reading | As modelled | Why |
|---|---|---|
| IC132 pin 9 (/LOAD) is not drawn | High (never loads) | A floating TTL input reads high. The reference leaves the pin unconnected (`z`, read high). If it were tied low, IC132 would load 0 on every clock and never reach 15. |
| IR, IP, GPR package labels (IC88? IC113?) | Kept as the trace's aliases, separate instances in the reference | The labels do not change the logic. |
| IC81 (74107) clock | Falling edge | The data sheet's output transition. The standard part is master-slave and the LS107A is edge-triggered; with J = K = 1 both toggle there. |
| 74123 family | 74123 formula, 0.28·R·C·(1 + 0.7/R) | The family is not printed. Every Monaco sheet uses this formula. With the 74LS123's 0.45·R·C the widths would be 70, 21, 465 and 70 ms instead of 44, 13, 294 and 44 ms. Only the `*_PIXELS` parameters would change. |
| R34/C55 on /GAME | Not reproduced, except as `DU_LAG` | C55 is on the driven /GAME side of R34. The trace derives no delay from them. |
| C34, C37, C38, C54, C57, the 680 pF on 132.2 | Not reproduced | Edge filters on trigger and clock nets. The trace gives no widths. |

## Open readings, as parameters or flags

**Game over with exactly 0 or 15 stored bonuses (U5,
`SHEET_F_BONUS_TRACE.md`): not settled by the drawing.** /GAME rising
clocks IC94. The same edge, through R34, turns IC140 to count down, which
changes MAX/MIN and so IC94's clear. `DU_LAG` is the number of settling
steps (reference: layers) by which /GAME reaches IC140 pin 5 after IC94's
clock. In the reference, `DU_LAG` `rn_layer` elements sit on the R34
branch.

| `DU_LAG` | 0 stored | 15 stored | 1–14 stored |
|---|---|---|---|
| **0 (default, the model's natural order)** | IC94 stays clear: no pulse, /GAME END at once | Full payout, 3000 pulses | n × 200 |
| 1 | IC94 sets and is cleared in the next step, before its Q is seen. The reference shows a 0.04 ns pulse on 101.11, absorbed by IC81's filter (counted as a hazard). No pulse. | IC94 clocks on the up-count MAX/MIN, stays clear: **no payout** | n × 200 |
| 2 | IC94's Q is high for one step. With V5 high, 101.11 makes one short pulse that IC81 counts, so the divider starts one count ahead (cleared by the next coin). It is not a settled /BONUS POINT pulse. | No payout | n × 200 |

The default is 0 because, under the settled-layers rule, an asynchronous
clear is combinational and the clock acts on the settled nets. So the new
direction reaches IC94's clear before its clock acts, and the reference's
timing rule gives the same order. This is a modelling order, not a
measurement. Settling it needs a real board.

**End of a car-count pulse while PR-38-7 and PR-38-9 are both high: not
settled, flagged, not a parameter.** When IC100's first half ends, its /Q
clocks IC132 in the same change that releases IC132's clear (143.8 →
143.6 → 53.8). On the board, C57 (1000 pF on 53.9) slows the release, so
`BONUS_INPUTS_TRACE.md` reads the count as probably staying 0. In this
model the clear is released first and IC132 counts 1. The directed test
checks that reading (stage 14: "the running car counts as it ends"). The
other order would need a delay on the clear path.

## Timing model

As for the Monaco sheet A and F control logic, the sheet is evaluated one
pixel late. Inputs are captured at edge 3 of the 7 MHz enable. Five or six
settling steps of the 48 MHz clock follow, and the settled outputs are
registered at the next edge 3.

**Settled layers.** In one step, gates and the asynchronous clears and loads
(IC80 CLR, IC81 /CLR, IC94 /CLR, IC132 /CLR, IC140 /LOAD, the 74123 /CLR) are
combinational. Each flip-flop, counter and one-shot compares its clock and
trigger nets with the previous step and changes its state for the next step.

- **No loop of gates needs a cut.** The only feedback (IC94 → IC101 → IC81
  → IC80 → IC72 → IC108 → IC140 → MAX/MIN → IC102 → IC94 /CLR) goes through
  clocked parts.
- **One simplification.** Each IC80 section's drawn QA → CKB wire (80.3 →
  80.4, 80.13 → 80.12) is taken inside the step, so a section counts as a
  BCD decade on its CKA falling edge. The link between the sections (80.7
  → 80.15) is a step like any other. Taking the internal links as steps
  too, the ripple from V5 to IC140 would need seven steps, more than a pixel
  has. The reference keeps both wires as wires; only the moment within the
  pixel when 80.9 changes differs. With the merge, the longest chain (V5 →
  IC81 → IC80a → IC80b → IC140 and IC107's first half) settles in 4 steps.
- The 74123 pulses are counted in pixels and decremented at each edge 3.
  They are retriggerable, a low /CLR ends them, and /CLR rising while A is
  low and B high triggers them (data-sheet function table).

| One-shot | R, C | Width | Pixels (7.1525 MHz) |
|---|---|---|---|
| IC100 pins 1–4, 13–15 | R20 47k, C39 3.3 µF | 44.1 ms | 315 245 |
| IC100 pins 5–7, 9–12 | R22 47k, C33 1 µF | 13.4 ms | 95 529 |
| IC107 pins 1–4, 13–15 | R24 47k, C41 22 µF | 293.8 ms | 2 101 633 |
| IC107 pins 5–7, 9–12 | R23 47k, C40 3.3 µF | 44.1 ms | 315 245 |

## Tests

`tests/tb_bonus.v` drives the RTL and `tests/pro_sheet_n_reference.v` with
the same stimulus. The reference is wired IC by IC and pin by pin from the
trace, with its own part models (`rn_` prefix, no code shared with the
RTL). Its timing rule:
- gates take 0.01 ns, and asynchronous clears and loads act 0.02 ns after
  their input;
- every clock and trigger input goes through a 3 ns inertial filter that
  counts the hazards it absorbs;
- edge-triggered parts act 1 ns after the filtered edge;
- the 74123s count 7 MHz periods.

The bench runs **three RTL/reference pairs at once**, `DU_LAG` 0, 1 and 2,
on one stimulus. Each RTL is compared with a reference built with the same
setting. The capacitors are divided by 1000. V2, V4 and V5 come from a
counter that advances one line every 2 pixels. That is not the sheet E
raster: it lets a 15-bonus payout (3000 V5 periods) fit a short run.

Checked for every pixel in each pair:
- all outputs and 24 bits of internal state (IC81, both IC80 decades,
  IC132, IC140, IC94, the four one-shot Qs, MAX/MIN and W01) are identical;
- the RTL had no step left to do at edge 3.

Directed checks, written from the trace:
- IC140 only steps by one, or is loaded with 0 by W01, and holds at 15
  during play;
- W01 clears IC81, IC80, IC132 and IC140;
- /BONUS POINT is low only while IC94 is set;
- /GAME END is low only with /GAME high and IC94 clear;
- each uncut payout gives exactly the expected number of /BONUS POINT
  pulses and leaves IC140 and the divider at 0;
- with 0 stored, IC81 is left at 1 only for `DU_LAG` 2 (game over is timed
  with V5 high);
- every BONUS CP and IC107 second-half pulse that runs out does so exactly
  its width after its last trigger;
- the car count: 8 cars count 8, /ACC1 clears it, PR-38-7 and 9 during a
  car clear it, and 16 cars give one bonus;
- the bridge: with PR-38-7 and 9 low (D6 · D7 = 0) the bridge one-shot runs
  and a car during it gives one bonus; with both high (D6 · D7 = 1) GPR
  holds it clear, and the same bridge and car give none.

The stimulus is not gameplay. It holds PLAYER ST high in the directed
stages; on the board PLAYER ST is a horizontal span repeated on every line
of the player's window (`BONUS_INPUTS_TRACE.md`). Within the directed
stages that does not matter, because the one-shots are retriggerable and
their pulses are much longer than a line.

| Stage | Stimulus | Result (all three pairs unless noted) |
|---|---|---|
| Power-up | /INI. RESET low | counters clear |
| Game 1 | 8 cars, /ACC1 clear, 3 cars and a PR-38 clear during the third, 15 more cars | 1 stored, **200** pulses |
| Game 2 | bridge with PR-38-7 and 9 low, then a car during it (IC100.5 · PLAYER ST path); the same with them high (no bonus); car count cleared; 16 cars | 2 stored, **400** pulses |
| Game 3 | 17 bridge-plus-car bonuses | held at 15; **3000** pulses with `DU_LAG` 0, **0** with 1 and 2 |
| Game 4 | no bonus, game over with V5 high | **0** pulses; IC81 left at 1 with `DU_LAG` 2 only |
| Game 5 | 3 stored, /INI. RESET during the payout | cut after 251 pulses, all cleared |
| Game 6 | 2 stored, a coin during the payout | cut after 100 pulses, all cleared |
| Random | 400 000 pixels of random inputs (coins, resets, games, cars, bridge, /SCORE ST, PR-38, /ACC1) | compared only |

`bonus` run (capacitors / 1000): **967 208 pixels** match in each of the
three pairs, in about 80 s in Icarus. Per pair:

| `DU_LAG` | Payouts (0 / 15 stored) | IC140 up / down | BONUS CP pulses exact | IC107 Q5 exact | Settled in |
|---|---|---|---|---|---|
| 0 | 8 (2 / 1), 2 cut | 38 / 25 | 39 of 2102 px | 66 of 315 px | ≤ 4 steps |
| 1 | 8 (2 / 1), 2 cut | 38 / 10 | 24 | 66 | ≤ 4 steps |
| 2 | 8 (2 / 1), 2 cut | 38 / 10 | 24 | 66 | ≤ 4 steps |

The reference absorbed one hazard on IC107's second-half B input in each
pair, and with `DU_LAG` 1 the 0.04 ns IC94 pulse on IC81's clock described
above.

**Not run:** the circuit as drawn (`FAST = 0`). Its BONUS CP pulse alone is
2.1 million pixels, and a 15-bonus payout on the real raster would be about
90 million. No Quartus synthesis of the module was done.

## Pro board: sheet N in the game (issue #71)

`jtmonacogp_game.v` has a parameter `PRO` (default 0) and a wire `pro`. With
`PRO = 1` sheet N runs inside the connected sheets, and sheets A, F and G
use their Pro gates. A parameter for now: the MRA and the mode selection
are separate work.

| N input | From | In `jtmonacogp_game.v` |
|---|---|---|
| PLAYER ST | G: Pro IC31 = AND(HWIN, HC4), `jtmonacogp_player` `player_st` (low with `pro` = 0) | `g_player_st`, held one pixel (`g_player_st_l`) |
| /SCORE ST | G: IC19 /Q (Pro IC121) | `score_st_n` |
| /OTHER CAR | H: pad B15 net | `h_other_car_n` |
| PR-38-7, PR-38-9 | H: PR-38 D6, D7 | `prom_q[17*8+6]`, `prom_q[17*8+7]` |
| /BRIDGE AP | D: NOT(BRIDGE AP) (Pro IC59) | `~bridge_ap` |
| /ACC1 | F | `f_acc1_n` |
| GAME, /GAME, /COIN & TEST, /INI. RESET | A | `a_game`, `a_game_n`, `a_coin_test_n`, `a_ini_reset_n` |
| V2, V4, V5 | A, F, E: the raster | `v[2]`, `v[4]`, `v[5]` |

| N output | To | Wire |
|---|---|---|
| /BONUS POINT | F (the Pro /SCORE CP gate) | `n_bonus_point_n` |
| BONUS SOUND | A (pad A29 OR) | `n_bonus_sound` |
| /BONUS CP | A (pad A28 NAND) | `n_bonus_cp_n` |
| BONUS CP | M, pad CE (+200) | `n_bonus_cp` |
| BONUS A–D | I, pads M1–M4 | `n_bonus` ({D, C, B, A}); on I they address only the lamp PROMs PR-01/PR-02, which have no dump and no model, so nothing takes them yet |
| /GAME END | I, pad M5 (HP) | `n_game_end_n` → `jtmonacogp_rank.v` `game_end_n`: the sequencer's MR (72.6) and 65's /A (T.R.S to K) |

Timing. N captures at edge 3, as sheets A and F do. PLAYER ST is sheet G's
net for the current pixel, so it is held one pixel, as PLAYER is for F, to
meet /OTHER CAR (H) and /BRIDGE AP (D), which are given for the previous
pixel. The one-shot widths are divided by `CS` like every sheet's.

With `PRO = 0`, N still runs but PLAYER ST is low, and sheets A and F ignore
its outputs: the game, play and player cases give the same results as
before this change.

**`play_pro`** (`tests/tb_play_pro.v`): the connected sheets with `PRO = 1`,
`FAST = 1` (one-shots / 1000, the 555's / 100), no sound board and no
sheets I (rank part), J and K, the real PROM image. A coin, the pedal
floored in low gear, the timer run out, then the payout. Checked: IC140
only steps by one and only in the game; /BONUS POINT only after it, exactly
200 pulses per stored bonus; one score step at the start of each pulse, so
200 points per bonus (the Pro sheet I counter takes /SCORE CP's falling
edge directly; /SCORE CP falls with /BONUS POINT); /GAME END low once IC140 is back at 0 and the
divider at 0; BONUS A–D = IC140 or IC132 by V2; every sheet settled before
its capture.

**A test stimulus stands in for a fast player.** In this core the car
starts beside the road, where it shakes, the handle is switched out and
ACCE. stays at 0–2 (`docs/CONNECTED.md`, open items); ACCE. also climbs only
one step every 16 frames, and the shortened game lasts about 54 frames.
So the player is always in PR-38's slow-player range (D6 · D7 = 1; ACCE.
0–4 with SP. CONT. low in Monaco GP's PR-38 dump). The other cars do pass
the PLAYER ST span (125 overlap pulses in the game), but each overlap then
clears IC132: the cars overtake the player, and the game, as wired, earns
no bonus. That is the bonus rule working, not a fault, but it leaves the
payout untested. The bench therefore holds N's two PR-38 inputs low (forced
on `u_bonus`, not on sheet H) from the start of the game until the first
bonus is stored, as a fast player's PR-38 data would, and then releases
them. Everything else is the game's own nets.

Not like the board in this run: with the one-shots / 1000, IC100's overlap
pulse (315 pixels) is shorter than a line, so every line of an other car
inside the PLAYER ST span is an episode of its own, where with the drawn
44 ms one car passing is one. The 16 episodes come from one or two passing
cars instead of 16. The payout is not shortened (V5 is the raster): 200
V5 periods, 50 frames, per bonus.

Result (6 November 2026, real PROMs, Icarus): the first bonus is stored 43
frames into the game (frame 50), after 19 overlap pulses with the
stand-in; 1 bonus at the end of the game (frame 62); 200 /BONUS POINT pulses in 50 frames; score
27 → 228. 200 of the 201 steps fall at the ends of the pulses. The other
one comes 4 pixels after GAME falls: a normal score pulse was in progress
(sheet F's score NAND low) and /GAME clearing the score divider ends it.
On the board the first /BONUS POINT pulse may start close enough to merge
with it (one edge, sheet F's AND); in the model /BONUS POINT reaches sheet
F a pixel later, so it counts. The bench allows that one step, only within
16 pixels of the end of the game and only with the normal NAND low.
116 frames, 94 minutes in Icarus beside other simulations. (Verilator 5.032
gave the same counts and score, for a quicker check.) That run had sheet I's
score counter as on the original board (pro = 0 at game level), which
counts the end of a /SCORE CP pulse.

With sheets I and K on the Pro board (pro = 1 at game level, PR #94; the
bench still has `RANK = 0`, so only the score counter of sheet I is in it):
the same game and payout, score 28 at the end of the game and 28 → 228,
all 200 steps at the starts of the /BONUS POINT pulses and none other: the
normal score pulse that was in progress when GAME fell had already counted
at its start. 116 frames, Icarus.

## Open items

- U5, the order at game over with 0 or 15 stored (above).
- The order of IC132's clock and clear release at the end of a car-count
  pulse with PR-38-7 and 9 high (above).
- IC132 /LOAD (pin 9), taken high.
- The 74123 family.
- BONUS A–D have no destination in the core: sheet I's lamp PROMs
  PR-01/PR-02 are not dumped (`pro/reconstruction/LAMP_PROMS.md`).
