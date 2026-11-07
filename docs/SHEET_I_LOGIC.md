# Sheets I, K and J logic: high-score memory, ranks and the score display

Four modules, each checked against a pin-wired reference:

| Module | Sheet | Reference | Test |
|---|---|---|---|
| `jtmonacogp_score.v` | I, score counter (31 October) | `tests/sheet_i_score_reference.v` | `tb_score` |
| `jtmonacogp_rank.v` | I, memory, search and ranking | `tests/sheet_i_rank_reference.v` | `tb_rank*` |
| `jtmonacogp_ranks.v` | K, the five rank latches | `tests/sheet_k_reference.v` | `tb_rank*` |
| `jtmonacogp_leds.v` | J, display scan, muxes, decoders | `tests/sheet_j_reference.v` | `tb_leds` |

`jtmonacogp_panel.v` draws the LED panel on screen. It is **not original
circuitry** (see "In the core").

The pin-level reading of sheet I's memory and ranking part is in
[trace/SHEET_I_TRACE.md](trace/SHEET_I_TRACE.md), "Memory and ranking".
Sheets J and K follow [trace/SHEET_J_TRACE.md](trace/SHEET_J_TRACE.md) and
[trace/SHEET_K_TRACE.md](trace/SHEET_K_TRACE.md).

## What sheet I does after a game

Signal names are the drawn labels. 11A, 12C and the other designators are
the board's grid positions.

1. **Sequence.** While GAME is low, 11A (first half of a 74390) counts H5
   and stops at 8. 12A (7442) decodes its odd counts:
   - 1, **ADR. INC.**: 9F (the memory address) steps on to a new slot;
   - 3, **192 LD.**: the down-counter 7H..10H (four 74192s) loads 9999;
   - 5, **RAM R/W**: the 2111s write the score P. The 8216s drive P onto
     the memory bus while 11A's QC is high (count 4 to 7); outside that
     time they read the memory onto the D bus;
   - 7, **256 CL.** (13F, a NOR with the power-up signal): 12B sets and the
     search starts; N, the players-to-date count (10B..10D first halves),
     counts one.
2. **Search.** 12B gates the 14 MHz clock into 12C. 12C steps the memory
   address (9F) and 12D together once every eight clocks. The down-counter
   counts once every 256 addresses (12D's QD), so every stored score is
   compared with every value from 9999 down to 0000. Within each address,
   12C's count 5 (J2's Q2) strobes the memory comparison (D bus with the
   down-counter, 6F..3F) and count 7 (Q3) the score's comparison (P with
   the down-counter, 6H..3H). The down-counter's borrow after 0000 resets
   12B: the search is over after 10,000 × 256 × 8 clocks of 14 MHz, about
   1.43 s.
3. **Ranks.** Each memory match counts 11A's second half (up to 8). Through
   10A (74259, used as a demultiplexer) it clocks the next of sheet K's
   five latches, which take the D bus: 1ST..5TH get the five highest stored
   scores, in order. Equal scores take more than one rank.
4. **R.** Until the score's own comparison first matches, which sets 12B's
   second half (F), every memory match counts R (10B..10D second halves).
   R is the new score's rank among all stored scores.
5. **Flashing.** 14H (74259) is addressed by R's units digit (R-1A..C)
   and takes D = NOR(F, Vs/16): once F is set, row R's FLASH line follows
   Vs/16 and row R of 1ST..5TH blinks. Its /CL is 11A's second half QD:
   while fewer than eight matches have been counted 14H is a
   demultiplexer (only the addressed line follows D), from eight on an
   addressable latch. 13E (latch 1, set by R-1D, cleared by RST) drives
   /E: once R's units digit has reached 8, 14H's lines are cleared (or,
   from eight matches on, held).
6. **Reset and power-up.** COIN & TEST or INI. RESET (13H, "RST") clears
   12C, 12D, 11A's second half, R, F, 12B and 13E: a coin ends a search.
   After /INI. RESET rises, 12C's second half counts eight V2 periods; until
   then LATCH CL. holds sheet K and N cleared and 13F blocks the search.
   During /INI. RESET (6.28 s) 11A runs freely and writes the score, which
   RST holds at 0000, into every slot: the memory is all zeros after
   power-up. The RTL starts with the memory at zero.

The memory has 256 slots and 9F is never cleared. Each game writes the
next slot, so the oldest of the last 256 games is overwritten.

## The correction: 7H's DOWN clock

As drawn, 7H's DOWN input (pin 4) is 12D's QD (pin 6). A 74192 counts on
the rising edge of DOWN, so the first count comes 128 addresses into the
search. Every pass over the memory but the first then starts 128 addresses
after the slot just written. The score's own comparison matches at the
first address of its pass, before the memory reaches the new slot, so the
new score itself is never counted in R. R is the number of stored scores
above the new one. A new best score gets R = 0, and 14H's Q0 is not
connected: no row flashes.

The real panel flashes **1ST** for a new best score during the game-over
screen (Aldo's photo, 1 November 2026: 1ST dark in the flash phase, 2ND
999x, 3RD..5TH 0000). That is the behaviour with DOWN the inverse of 12D's
QD: each pass then starts at the new slot, the new score is the first
memory match of its pass, and R = 1 + the number of stored scores above it.
Ties go to the newer score.

`jtmonacogp_rank.v` and the reference take that reading by default
(`DOWN_INV = 1`). `DOWN_INV = 0` is the circuit as drawn; the test
`rank_drawn` runs it. Which inverter or wire the board has for this is not
known (no photo of that area); the logic needs only the inversion. The
five ranks (1ST..5TH) do not depend on it.

## Sheet K

Each rank is three 74174s (16 of their 18 flip-flops) on the D bus,
clocked by its line from 10A; LATCH CL. clears all fifteen through 11D's
two inverters. The RTL takes a rank line's rising edge at the next host
clock (one clock after the 74174s); the D bus holds its value for at least
two more 14 MHz clocks.

## Sheet J

K9 (half 74393) counts V2's falling edges; QA..QC select one of eight rows
(2F, 7445) and the same input of the sixteen 74151s. Rows 1ST..5TH are lit
while selected and their FLASH line is low (NOR, then 7406). Rows 6 (人中)
and 7 (位) show N and R in groups 2..4; their group 1 (units column) is
the timer, tens T2 and units T1 from sheet A, which goes through connector
H to the separate timer display. Group 1 is the units column on the panel.
The 7448s have no blanking: leading zeros show, and codes 10..14 show the
7448's own glyphs.

## Timing model

The rank module runs on the 14 MHz enable. At each enable:

1. the inputs (H5, V2, GAME, /COIN & TEST, /INI. RESET, the score, Vs/16),
   which change between enables, and their consequences settle;
2. 12C counts with the resulting 12B state, and 12D, 9F and the
   down-counter follow;
3. the comparisons, F, R, 11A's second half, 13E and 14H settle.

The 2111s are read through a register: the D bus shows the address set at
the previous enable. Every strobe comes at least four enables after the
address changes, so no comparison sees the register's delay.

The reference has small delays (0.5 ns gates, 1 ns flip-flops) only to
order events; they are not measured TTL delays.

## Tests

- `tb_leds` (sheet J, about 20 s): 40 frames of random rank, score, N, R,
  timer and FLASH inputs changed every eight lines. Scan, the eight row
  drives and all 28 segments match the reference at every clock; all
  eight rows, all sixteen codes and FLASH blanking of rows 1..5 are seen.
- `tb_rank` (sheets I and K): power-up, then games with the scores 1234,
  0712, 2500, 0712 (a tie), each followed by the whole 1.43 s search. Every
  host clock compares the score lines, the five rank lines, LATCH CL., N,
  R, the FLASH lines, the search flag and sheet K's 80 latch outputs (one
  clock later in the RTL); the D bus is compared while a strobe is on.
  After each search the five ranks, N and R are checked against a model
  of the memory (R = 1 + the number of stored scores above).
  - `rank`: four games, `DOWN_INV = 1`;
  - `rank_drawn`: three games as drawn (`DOWN_INV = 0`); ranks and N
    checked, R reported;
  - `rank_early`: three games, the last coin in the middle of its search.

The run times are in `scripts/run_tests.py`.

## In the core

`jtmonacogp_game.v` connects the modules in the connected-sheets view:
the 14 MHz enable, H5 = h[5], V2 = v[2], Vs/16 from sheet H, GAME,
/COIN & TEST and /INI. RESET from sheet A, the score from sheet I's
counter, the timer from sheet A.

`jtmonacogp_panel.v` (not original circuitry) draws the panel over the
picture: 1ST..5TH, SCORE, OF (人中, players to date),
RANK (位) and TIME, as seven-segment digits in a black box: lit segments
in the game's full red (12'hf00, that of GAME OVER and +200), unlit
segments black, so the panel adds no colour the game does not show. With
pro = 1 the Pro board's SUPER RACER SCORE digits and its two lamps (YOUR
SCORE 10000POINT, TODAY'S HIGH SCORE 10000PT.) follow the same rule: 12'hf00
lit, black unlit. It keeps each row as sheet J's outputs show it during that row's scan, so
the flashing row blinks as on the panel. The row captions are the panel's
printing, not drawn by the board. It is shown only while button 3
(Scoreboard, Y by default) is held, in play or between games, and at no other
time (Aldo, 4 November). The development displays leave it off.

The sound board's HI SCORE tune is started by sheet A (`hiscore_n`, pad
AF: MCLR falling with EXTEND set), not by sheet I.

## Open items

- The DOWN inversion: which part makes it is not known (above).
- The panel's layout on screen is a choice, not the cabinet's.

## Keeping the scores (not original circuitry)

The original board forgets its scores at power-off: /INI. RESET lets 11A run
freely, which writes 0000 to every address. The core keeps them instead.
`jtmonacogp_rank.v` with `KEEP = 1` differs from the drawing in three ways, and
`KEEP = 0` (the pin-wired reference tests) is the drawing:

- The memory is a block RAM in `mem.yaml` (`score`, 256 x 16 bits). `scoreptr`
  holds 9F's value when a search ends. Together they are JTFRAME's NVRAM file,
  514 bytes: `JTFRAME_IOCTL_RD` in `macros.def`, `<nvram>` in the MRA.
- Nothing is written, and ADR INC. does not step, between /INI. RESET and the
  first rise of GAME. 9F takes the saved value during /INI. RESET, so a game
  never overwrites the scores of earlier sessions until the 256 addresses
  wrap, as on the board.
- One search runs when 12C's power-up delay ends, so the five ranks show at
  once. N does not count, and R and FLASH read zero until a game starts.

N, the players to date, still starts from zero at each power-up. A tilt also
raises /INI. RESET, and no longer clears the scores.

MiSTer loads the file with the MRA and writes it from the OSD's Save settings
(`Main_MiSTer`, `arcade_nvm_save`). `tests/tb_rank_keep.v` and
`tests/tb_score_ioctl.v` cover this; the file's save on real hardware does not
have a simulation.
