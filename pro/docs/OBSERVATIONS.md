# Pro Monaco GP: observations from a real cabinet

Evidence that is not on the schematic, kept apart from the traces. Each item
says where it comes from. Use it to check readings, never in place of one.

## Source: video screenshots of a working cabinet (Aldo, 6 November 2026)

Two screenshots from a gameplay video of a Pro Monaco GP cabinet, supplied by
Aldo. The images are not stored here (third-party footage). The screen is
photographed at an angle and the tube is curved, so sizes and positions are
approximate.

### Play instructions card

Read from the card on the cabinet:

> INSERT COIN TO START GAMES. PLAY IS POSSIBLE UNTIL TIMER READS "0".
> HOWEVER, IF SCORE EXCEEDS 2000 POINTS AT THIS TIME, GAME MODE WILL CHANGE
> TO "REMAINING CAR" PLAY AND PLAY CAN BE CONTINUED UNTIL ALL CARS ARE GONE.
> ONE EXTRA CAR WILL BE AWARDED AT 4000, 6000 AND 8000 POINTS RESPECTIVELY.
> FOLLOWING BONUS POINTS AWARDED AT END OF GAME:
> OVERTAKING 16 SUCCESSIVE CARS: 1 BONUS (200 POINTS).
> OVERTAKING 1 CAR ON THE BRIDGE: 1 BONUS (200 POINTS).

This agrees with the traces (`trace/SHEET_N_TRACE.md`,
`trace/SHEET_F_BONUS_TRACE.md`, `trace/BONUS_INPUTS_TRACE.md`): 16 counted
episodes or one bridge episode give one bonus, each bonus is paid as 200
points after game over.

### Why "successive" and "overtaking": PR-38 D6 · D7

PR-38-7 and PR-38-9 are PR-38's D6 and D7. In Monaco GP's PR-38 dump
(`prm38.ic115`, the only dump available; Pro's PR-38 may differ), D6 · D7 = 1
only at low player speed:

| SP. CONT. | ACCE. (player speed, 0–15) with D6 · D7 = 1 |
|---|---|
| 0 | 0–4 |
| 1 | 0–6 |

Low gear tops out at ACCE. 6; high gear goes higher (`docs/SHEET_F_LOGIC.md`).
So D6 · D7 = 1 means the player is slow and other cars pass the player.
From the sheet N wiring:

- an overlap while D6 · D7 = 1 **clears** the car count (IC143 -> IC53 ->
  IC132 /CLR): being overtaken resets it, hence "successive";
- the bridge one-shot's /CLR is GPR = NAND(PR-38-7, PR-38-9), so it is
  **held clear while D6 · D7 = 1** and can only run when the player is fast:
  only overtaking on the bridge gives the bonus.

Note: `trace/BONUS_INPUTS_TRACE.md` calls D6 · D7 the "fast bits" and says the
bridge one-shot is "held clear unless the fast bits are set". The gates it
transcribes, and the RTL in `cores/monacogp/hdl/jtmonacogp_bonus.v`, give the
opposite, which matches the card. Only that prose needs correcting.

### The +200 graphic

- Red, directly below GAME OVER, as traced
  (`trace/SHEET_M_C_PLUS200_TRACE.md`). It also shows during play.
- Its height is roughly three quarters of GAME OVER's, consistent with a
  12-row glyph against GAME OVER's 15 rows (`reconstruction/plus200-glyph.txt`).
- **To check:** in the GAME OVER screenshot, +200 seems to start under
  GAME's A and to be wider than the traced 32-line window allows (about 40
  lines, measured roughly). The angle and curvature make this unreliable.
  Compare a screenshot of the finished core with the footage before changing
  anything.

### Score panel

The cabinet's panel reads "BEST SCORE OVER 10000" and "BEST 5 OF 300 GAMES",
consistent with the sheet K and sheet I traces.

## Source: video screenshot of the bonus lamp panel (Aldo, 6 November 2026)

A further screenshot from gameplay video of a Pro Monaco GP cabinet, supplied
by Aldo (issue #69). Not stored here (third-party footage). Only what is
listed below was read from it; the number of lamps and which ones are lit
were not.

### Bonus lamp panel

- The top section is labelled **"NUMBER OF CARS SUCCESSIVELY OVERTAKEN"**,
  with a horizontal bar of lamps whose colours go green, then yellow, then
  red along the bar.
- Below it is a section labelled **"BONUS POINTS (×200 PT.)"**.

This fits the sheet I wiring (`trace/SHEET_I_TRACE.md`, "Bonus lamps"): two
groups of lamps on two commons, one per V2 phase, showing IC132's car count
(0–15) and IC140's stored bonuses (0–15) from sheet N. Which common drives
which section, and how many lamps light for a given count, are not given by
the screenshot or the schematic: `reconstruction/LAMP_PROMS.md` proposes a
bar graph as a reconstruction.

## Source: Aldo's description of a working Pro cabinet (6 November 2026)

Aldo's own observations, not schematic readings.

### Bonus lamp panel, in operation

- The top bar ("NUMBER OF CARS SUCCESSIVELY OVERTAKEN") fills first, one
  lamp per overtaken car, **from left to right**.
- Colours: the first 9 lamps are **green**, the last 5 **red**. That is 14
  lamps as described; the wiring has 15 outputs per row
  (`trace/SHEET_I_TRACE.md`), so one lamp is unaccounted for or was
  miscounted.
- When the top bar is full, the next overtaken car lights one lamp on the
  bottom bar ("BONUS POINTS (×200 PT.)", **red**), and the top bar starts
  filling again from empty.

This confirms the bar-graph reading of PR-01/PR-02
(`reconstruction/LAMP_PROMS.md`): a count of n lights lamps 1 to n, left to
right, the car count (IC132) on the top row and the stored bonuses (IC140) on
the bottom row. It also fits IC132 wrapping to 0 when the 16th car adds a
bonus.

*Clarified by Aldo, 6 November 2026 (#112):* there are **14 lamps a bar**:
9 green and 5 red on top, 14 red on the bottom, so 14 is not a miscount. On
the top bar, 1 car lights 1 lamp, 2 cars 2 lamps, and so on to 14 cars, 14
lamps; **15 cars still show 14 lamps**. The **16th** car turns the top bar
off and lights one more red lamp on the bottom bar, then the top bar fills
again. This agrees with sheet N's timing as drawn (the bonus at IC132's
wrap) and with the card's "16 successive cars". A **crash** clears the top
bar; the bottom bar stays until game over. Aldo is **not sure** whether going
off the road also clears the top bar.

### Attract mode (no game running)

The road scrolls and gets wider and narrower. There is no player car, and
other cars appear at random, at most 2 on screen at a time. Compare with the
new sheet B, C and D logic (#109: /DISPLAY timer, D-TIME, SLOW).

### Driving Meter

What it shows on a real cabinet is currently unknown (`trace/METERS_TRACE.md`
finds no drive for it on the schematics).
