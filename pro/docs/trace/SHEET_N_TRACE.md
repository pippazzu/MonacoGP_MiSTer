# Sheet N trace — Pro Monaco GP, second pass

Date: 2026-11-05. Sega 420-0525, PDF page 12, sheet N, `96822-P (D-5/5) IC BOARD ASS'Y MO.A`, issue 1980.7.16.

**This replaces the first-pass transcription.** Connections were reread from fresh crops, not accepted from the earlier tables. Manufacturer pinouts are checks on the reading, not replacements for it. Remaining uncertainties are explicitly listed below. No HDL, PROM data, gameplay descriptions, emulators or remake code were used. No bonus threshold or scoring rule is asserted.

## Evidence and coordinate system

Source: `C:/Users/kakyo/Downloads/promonacogp420-0525_1.pdf`, SHA-256 `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`.

**All second-pass coordinates are at scale 1, not the first pass's 0.8 scale:** pypdfium2 upright rendering of N is 10200 x 6617 pixels. Boxes are (left, top, right, bottom), origin top-left. Crops were inspected at high zoom, including original-resolution delivery for the long strips. Coordinates locate evidence in the original PDF render; enlarging a crop does not create additional source detail.

Fresh evidence directory: `C:/Users/kakyo/.codex/visualizations/2026/11/03/01a1a260-b7d3-7c90-805a-3bfc2fa52b96/n-pass2/`. Each ID below is a PNG filename there. `N.png` is the complete fresh render. The PDF and crops have not been added to the repository.

| Crop ID | Box on N | Purpose |
|---|---|---|
| v4-row | (2800, 900, 7400, 1000) | Full V4 wire to 113.2 |
| point-row | (3800, 1800, 7400, 1950) | Full lower clock row to IP.11 |
| divider | (3700, 1200, 5400, 2050) | IC81 and both IC80 halves, actual pin numerals |
| upper-left | (2200, 800, 4300, 2000) | Input captions, IC101 clock gate, reset input gate |
| left | (2300, 1600, 4400, 4400) | IC94, IC102, IC100 and left vertical trunks |
| centre | (4200, 1800, 6300, 4400) | Counter/reset/control wires |
| rightmid | (6000, 2850, 7600, 3900) | IC140 and mux-side connections |
| lowerleft | (2400, 3850, 4200, 5500) | PR38 gates, clear wire, C34/C54/C57 |
| lowermid | (4100, 3800, 5900, 5200) | IC53, IC101/108, first IC107 half |
| counter | (4000, 2950, 4900, 3800) | IC132 pins and small capacitor |
| reset | (2900, 1650, 3750, 2050) | Reset inverter designator |
| reset-out | (3500, 1790, 5500, 2020) | Reset/output-clock crossings |
| sound | (6400, 850, 8100, 1600) | IC21/IC113 input pins |
| busrise | (6400, 1500, 7200, 3300) | Four sound-input risers and junctions |
| decodepath | (3800, 2350, 7200, 2950) | Source rows of sound decode |
| bridge-path | (2800, 2650, 4300, 5100) | IC100 clear, Q and /Q paths |
| resetpath | (4700, 1750, 5500, 4100) | Reset and IC80-output trunks |
| controlpath | (5200, 2900, 7000, 4750) | IC72/108/140 and IC107 interconnections |
| gamepath | (2650, 3950, 6550, 4400) | GAME pair and R34/C55 |
| rightbottom | (6050, 3850, 8550, 5000) | Second IC107 half and CP outputs |
| mux | (7000, 2250, 8850, 3350) | IC133 and display buffering |
| ports-right | (7100, 1100, 9450, 3400) | Named output arrows and M1–M5 |
| lowergate | (2800, 4600, 3250, 5080) | Previously omitted two-input gate |
| inverter-point | (7080, 1800, 7400, 1980) | /BONUS POINT inverter |
| note | (8250, 3350, 9600, 4200) | Crossed M8 pad and removal note |

Additional overview crops `right`, `bottom` were used for orientation only. The pin/wire readings cite the focused crops above.

**Notation:** `nn.p` = ICnn pin p. `/` transcribes an overbar. `clear` describes the scan reading, not a continuity measurement of a physical PCB. No dot means no junction at a crossing; bends and wire endpoints are followed continuously. Supply pins absent from a symbol are not assumed physically unconnected.

Two local aliases prevent uncertain package labels from becoming invented IC identities:

- **IR/IP:** reset inverter (9 -> 8) and point inverter (11 -> 10). Each looks like IC88, but ink overlaps the triangle. Pin numbers, function and connections are clear; package identification remains uncertain.
- **GPR:** the upright two-input NAND above/left of IC143, inputs 10/9 and output 8. Its label resembles 113, but a scan rule crosses the lettering. Connections are clear; the package designation remains uncertain. It must not be merged with IC143.8 merely because both output numerals are 8.

## Sheet A evidence: GAME polarity

Only for this question, PDF page 8 was rendered fresh at scale 1. The original **A-game** crop (5200, 2100, 7700, 3900) cuts off the `74/2` caption below IC47. The recheck crop **A-game-wide**, (5000, 2050, 8000, 4100), includes the caption and both outgoing labels. It is saved in the sibling `f-bonus/` evidence directory. Page A renders to 10184 x 6617 pixels at scale 1. The widened crop shows IC47's `74/2` section: Q pin 9 rises to the unbarred `GAME (N)` arrow; complementary Q pin 8 goes to the barred `/GAME (N)(F)` arrow. On N, `lowerleft` and `gamepath` show the bar immediately above the lower caption. Therefore:

| N row | Resolved label and loads | Evidence | Confidence |
|---|---|---|---|
| Upper GAME line | GAME -> 53.10 | A-game; gamepath | clear |
| Lower GAME line | /GAME -> 94.11, 95.9, C55, R34 then 140.5 | A-game; left; gamepath; centre | clear |

Sheet A was not used to establish any other N connection or to infer scoring behavior.

## End-to-end long-wire ledger

These routes supersede the first-pass candidate nets. Crop chains overlap. The stated positive junctions are visible dots; intervening crossings without dots are not additional loads. Approximate waypoints are navigation aids within the exact crop boxes, not measured PCB coordinates.

| ID | Source -> destinations read on N | Route / junction evidence | Confidence |
|---|---|---|---|
| W01 | 95.6 -> 80.2, 80.14, IR.9, 102.9 | upper-left -> divider -> reset-out -> left. Dots on the reset input branch and first counter-clear drop; second clear terminates at the same row. IR output crosses the descending 102.9 wire without a dot | clear; IR identity uncertain |
| W02 | IR.8 -> 81.13, 53.11, 140.11 | reset-out -> centre -> controlpath. Dot at 81 clear drop near (4150, 1950); row turns down near (5270, 1950), reaches dotted join near (5270, 4100), then runs left to 53.11 and right to 140.11 | clear; IR identity uncertain |
| W03 | 80.9 -> 72.2 | divider -> centre. Separate vertical near x5380 ends directly on upper NOR input 2. No join to 95.8, reset row, V2 or intervening counter-output rows | clear |
| W04 | 107.5 -> 72.3 and C38 | lowermid -> controlpath. Dot immediately after Q5; one branch goes to C38, other rises near x5390 and bends into NOR input 3 | clear |
| W05 | 140.12 -> 108.1 and 102.8 | rightmid -> controlpath -> centre -> left. Q12 loops right/up then left; dot near (5730, 3280) splits to 108.1 and the long row returning to 102.8 near y2450 | clear |
| W06 | 108.3 -> 140.14 and 107.2 | controlpath -> rightbottom. Dot near (6130, 3580) on counter-clock row; drop bends right into mono input 2 | clear |
| W07 | 95.8 -> 126.1 only among drawn N loads | centre -> ports-right, horizontal near y2270. Crosses W02/W03 with no dot; it does NOT feed 72.2 | clear |
| W08 | 100.5 -> 101.4 | bridge-path -> lowermid. Q5 goes right, down near x3950, then right into input 4. It does NOT supply 101.9 | clear |
| W09 | 100.12 -> 132.7 and 132.10 | bridge-path -> counter. /Q12 goes right/down near x4070 to a dotted split for the two enables; no continuation to 53.9 | clear |
| W10 | 100.13 -> 21.9, 101.9, 143.11 | bridge-path -> decodepath -> busrise -> sound; lowerleft -> lowermid. Dotted Q13 split near (3730, 3520); upper branch runs via x3900/y2650 to sound riser x6650; lower branch dots onto row near y4800 feeding 101.9 and bent return to 143.11 | clear |
| W11 | GPR.8 -> 100.11 and C54 | lowergate -> lowerleft -> bridge-path. Output rises near x2950 to clear 11; C54 has a dot on this same vertical near y4620. PR38 and other-car crossings are not junctions | clear; GPR identity uncertain |
| W12 | 143.6 -> 53.9 and C57 | lowerleft -> lowermid -> gamepath. Dot at NAND output 6 to C57 and rising line near x4070, then horizontal near y4100 to 53.9. Does NOT feed 101.4 | clear |
| W13 | 132.15 -> 101.10 | counter -> centre -> lowermid. Output 15 drops near x4820, bends left near y4340, then down/right into 101.10. Crosses /GAME without a dot | clear |
| W14 | PLAYER ST -> 100.10, 100.2, 101.5 | left -> bridge-path -> lowerleft -> lowermid. Dots at mono B inputs; same vertical continues down and bends right into 101.5 | clear |
| W15 | /OTHER CAR -> 100.1, 107.9 | bridge-path -> lowerleft -> lowermid. Dot on input row near (3200, 3520); vertical descends and bends right near y4680 into 107.9. Does not join /SCORE ST or Q13 where crossed | clear |
| W16 | /SCORE ST -> 100.3, 107.11, C34 | left -> bridge-path -> lowerleft -> lowermid. Dot at (approximately 3490, 4450) joins clear 3 and C34; horizontal continues to 107 clear 11. Adjacent Q13 vertical crosses without a dot | clear |
| W17 | 132.12 -> 133.11 and 21.12 | counter -> centre -> decodepath -> busrise -> sound. Output row near y2820 has dot at riser x6700, not either neighboring row | clear |
| W18 | 132.11 -> 133.14 and 21.10 | same crop chain as W17. Next row near y2880 has its own dot on riser x6760 | clear |
| W19 | V2 -> 133.1 and 21.13 | left -> decodepath -> busrise -> mux -> sound. Dot on V2 row near (6820, 2530), then riser to 21.13; main row continues to mux selector 1 | clear |
| W20 | 107.13 -> CE BONUS CP and 113.1 | rightbottom -> controlpath/rightmid -> busrise -> sound. Dot after Q13, long vertical near x6940; rises across counter/mux rows without junction dots, then bends into 113.1 | clear |
| W21 | /GAME -> 94.11, 95.9, R34/C55 | lowerleft -> gamepath -> left -> centre. Dot at lower GAME row's x3080 trunk; further dot near (3080, 2580) to 95.9. C55 dot before R34; R34's far end runs up to 140.5 | clear |
| W22 | GAME -> 53.10 | gamepath; continuous upper row bends up to middle gate input, no other dotted tap on this row | clear |
| W23 | PR-38-7 -> 143.9 and GPR.10; PR-38-9 -> 143.10 and GPR.9 | lowerleft/lowergate. Separate dots on respective rows, then separate verticals to GPR. Inputs 9/10 on the horizontal 7410 are written beside the upper/lower wires respectively | clear; GPR identity uncertain |
| W24 | /ACC1 -> 143.1 and 143.2 | lowerleft. Single wire rises into two tied bubbled inputs of middle gate | clear |
| W25 | 101.11 -> 81.12 and IP.11 | upper-left -> divider/reset-out -> point-row -> inverter-point. Dot at clock output drop near (3890, 1600); lower row near y1890 crosses other verticals without dots | clear; IP identity uncertain |
| W26 | 94.9 -> 101.13; 94.8 -> 95.10; 102.10 -> 94.13 | left and upper-left. Each is a separate continuous local-to-medium wire, no intervening dotted tap | clear |
| W27 | V4(F) -> 113.2 | upper-left -> v4-row -> sound. Continuous horizontal wire with no tap or junction dot | clear |

The NOR is labelled **72**, not 172: see `centre` and `controlpath`. The first pass's supposed 95.8 -> 172.2, 80.9 -> 172.3, 107.5 -> 108.1 connections were incorrect. W03–W07 give the actual routes read in this pass.

## Pin tables

The confidence of a wire referenced by Wxx is given in the ledger; the following tables also identify the local crop evidence. Type abbreviations are what is printed. For gates lacking a type caption, the datasheet family used for comparison is explicitly a compatibility check, not a read BOM entry.

### IC80 — two 390/2 sections; IC81 —107/2

| IC/pins | Scan connection | Evidence | Confidence |
|---|---|---|---|
| 80.1 | 81.3 | divider | clear |
| 80.3 -> 80.4 | First-half loop | divider | clear |
| **80.7 -> 80.15** | First-half output to second-half left input; numeral is 15, not 13 | divider | clear |
| **80.13 -> 80.12** | Second-half loop; left top numeral is 13, not 11 | divider | clear |
| 80.2, 14 | W01 | divider | clear |
| 80.9 | W03 | divider; centre | clear |
| 80.5, 6, 10, 11 | Not drawn on the two symbols | divider | clear omission; physical connections unknown |
| 81.1 J, 4 K | Vcc | divider | clear |
| 81.12 CK | W25 | divider | clear |
| 81.13 /CLR | W02 | divider | clear |
| 81.3 Q | 80.1 | divider | clear |
| 81.2 /Q and second half | Not drawn on N | divider | clear omission |

**74390 audit:** TI's DIP pinout gives 1=1CKA, 2=1CLR, 3=1QA, 4=1CKB, 7=1QD, 15=2CKA, 14=2CLR, 13=2QA, 12=2CKB, 9=2QD. These agree with the fresh scan reading. The first-pass 7 -> 13 and 11 -> 12 were transcription errors, not demonstrated schematic errors. No scan–datasheet disagreement remains for the visible IC80 pins. **Divider as a wiring fact:** IC81 has J and K tied high, so 81.12 to 81.3 divides by 2. Each IC80 section has QA fed back to CKB and uses QD as its output, dividing by 10: 80.1 to 80.7, then 80.15 to 80.9. Consequently, 81.12 to 80.9 divides by 2 x 10 x 10 = 200 during uninterrupted counting with resets inactive. This ratio does not establish a score or payout. N alone does not show which score digit receives /BONUS POINT or establish how many accepted pulses a payout interval contains.

### IC94 —74/2; IC95; IC102; inverters

| IC/pins | Connection/function | Evidence | Confidence |
|---|---|---|---|
| 94.12 D, 10 /PRE | Vcc | left | clear |
| 94.11 CK | /GAME, W21 | left; A-game | clear |
| 94.13 /CLR | 102.10 | left | clear |
| 94.9 Q; 94.8 /Q | 101.13; 95.10 respectively | W26 | clear |
| 95.5, 4 -> 6 | /COIN & TEST, /INI. RESET -> W01. OR body/input bubbles, NAND equivalent | upper-left | clear |
| 95.10, 9 -> 8 | 94.8, /GAME -> 126.1. AND body/output bubble, NAND | left; W07, W21 | clear |
| IR.9 -> 8 | W01 -> W02; inverter | reset; reset-out | clear pins/net; uncertain IC88 label |
| IP.11 -> 10 | W25 -> /BONUS POINT(F); inverter | inverter-point; ports-right | clear pins/net; uncertain IC88 label |
| 102.9, 8 -> 10 | W01, W05 -> 94.13; left-facing NOR | left; centre | clear |

The IC94 pin 10 Vcc tie is visibly drawn. Its handwritten add-note was recorded in the first pass; its date remains unreadable and has not been used as circuit evidence.

### IC100 — two123/2 sections

| Pins | Connection | Evidence | Confidence |
|---|---|---|---|
| 9 A, 10 B, 11 /CLR | /BRIDGE AP; PLAYER ST; GPR.8 respectively | left; W11, W14 | clear nets; GPR label uncertain |
| 5 Q | W08 | bridge-path | clear |
| 12 /Q | W09 | bridge-path; counter | clear |
| 6 Cext, 7 Rext/Cext | C33 between 6/7, positive at 7; R22 from 7 to Vcc | left; bridge-path | clear |
| 1 A, 2 B, 3 /CLR | /OTHER CAR; PLAYER ST; /SCORE ST | left; W14–W16 | clear |
| 13 Q | W10; no connection to C34 | bridge-path; lowerleft | clear |
| 4 /Q | 132.2 and small capacitor to ground | bridge-path; counter | clear |
| 14 Cext, 15 Rext/Cext | C39 between 14/15, positive at 15; R20 from 15 to Vcc | left | clear |

### IC132 —161; IC53

| Pins | Connection | Evidence | Confidence |
|---|---|---|---|
| 132.2 CLK | 100.4 and small capacitor | counter | clear |
| 132.7 ENP, 10 ENT | 100.12, W09 | counter; bridge-path | clear |
| 132.1 /CLR | 53.8 | counter; centre | clear |
| 132.3, 4, 5, 6 data | Ground | counter | clear |
| 132.14, 13, 12, 11 outputs | 133.2, 5, 11, 14 respectively; last two also W17, W18 | counter; centre; decodepath; mux | clear |
| 132.15 RCO | 101.10, W13 | counter; centre; lowermid | clear |
| 132.9 /LOAD | No pin 9 lead, caption or tie drawn on this symbol | counter | clear omission; uncertain physical tie |
| 53.9, 10, 11 -> 8 | 143.6, GAME, W02 -> 132.1 | W12, W22, W02; lowermid | clear |

IC53 is drawn as an OR body with bubbles at every input and the output: AND of the actual pin levels, compatible with 7411. Its pin 9 is **not** IC100.12.

### IC140 —191; IC72; IC108; IC101

| Pins | Connection/function | Evidence | Confidence |
|---|---|---|---|
| 140.3, 2, 6, 7 outputs | 133.3, 6, 10, 13 respectively | rightmid; mux | clear |
| 140.14 CLK | W06 | controlpath | clear |
| 140.5 D/U | R34 from /GAME | gamepath; centre | clear |
| 140.15, 1, 10, 9 parallel data | Ground | rightmid | clear |
| 140.4 /CTEN | Same ground wire | rightmid | clear |
| 140.11 /LOAD | W02 | controlpath | clear |
| 140.12 MAX/MIN | W05 | controlpath | clear |
| 140.13 /RCO | Not drawn | rightmid | clear omission |
| 72.2, 3 -> 1 | 80.9, 107.5 -> 108.2; NOR | W03, W04; controlpath | clear |
| 108.1, 2 -> 3 | 140.12, 72.1 -> W06; bubbled AND body with output bubble = OR | controlpath | clear |
| 108.5, 4 -> 6 | 101.8, 101.6 -> 107.10/C37; plain OR | lowermid | clear |
| 101.12, 13 -> 11 | V5, 94.9 -> W25; AND | upper-left | clear |
| 101.10, 9 -> 8 | 132.15, 100.13 -> 108.5; AND | W10, W13; lowermid | clear |
| 101.4, 5 -> 6 | 100.5, PLAYER ST -> 108.4; AND | W08, W14; bridge-path; lowermid | clear |

### IC143 —7410; GPR omitted gate

| Pins | Connection/function | Evidence | Confidence |
|---|---|---|---|
| 143.9 | PR-38-7 | lowerleft; W23 | clear |
| 143.10 | PR-38-9 | lowerleft; W23 | clear |
| 143.11 | 100.13, W10 | bridge-path; lowerleft | clear |
| 143.8 | To 143.13 only among drawn loads; not the clear/C54 wire | lowerleft | clear |
| 143.13, 2, 1 -> 12 | 143.8, /ACC1, /ACC1; OR body/input bubbles = NAND | lowerleft | clear |
| 143.3, 4, 5 -> 6 | All inputs tied 143.12; NAND output W12 | lowerleft | clear |
| GPR.10, 9 -> 8 | PR-38-7, PR-38-9 -> W11; upright two-input NAND | lowergate; lowerleft | clear pins/net; uncertain package label |

The GPR label resembles 113 but is crossed by a scan rule. If read as 143 it conflicts with the printed 7410's input count and duplicates its already-used output 8. The trace records this ambiguity rather than assigning it to 113 just to fit the datasheet. A sharper scan or PCB package/wire inspection is required to make the package identity clear.

### IC107 —two123/2 sections

| Pins | Connection | Evidence | Confidence |
|---|---|---|---|
| 9 A, 10 B, 11 /CLR | /OTHER CAR; 108.6; /SCORE ST | W15, W16; lowermid | clear |
| 5 Q | W04 and C38 | lowermid; controlpath | clear |
| 12 /Q | No outgoing wire drawn | lowermid | clear omission |
| 6, 7 timing | C40 between 6/7, positive at 7; R23 from 7 to Vcc | lowermid | clear |
| 1 A | Ground | rightbottom | clear |
| 2 B | W06 | controlpath; rightbottom | clear |
| 3 /CLR | Vcc | rightbottom | clear |
| 13 Q | W20; BONUS CP(M), CE | rightbottom | clear |
| 4 /Q | /BONUS CP(A), no pad label drawn | rightbottom | clear |
| 14, 15 timing | C41 between 14/15, positive at 15; R24 from 15 to Vcc | rightbottom | clear |

### IC21; IC113 sound sections

| Pins | Connection/function | Evidence | Confidence |
|---|---|---|---|
| 21.9 | 100.13, W10 | decodepath; busrise; sound | clear |
| 21.12 | 132.12, W17 | decodepath; busrise; sound | clear |
| 21.10 | 132.11, W18 | decodepath; busrise; sound | clear |
| 21.13 | V2, W19 | decodepath; busrise; sound | clear |
| 21.8 | Four-input NAND output -> 113.13 | sound | clear |
| 113.2, 1 -> 3 | V4(F), 107.13 -> 113.12; NAND | sound; W20; upper-left | clear |
| 113.12, 13 -> 11 | 113.3, 21.8 -> BONUS SOUND(A); OR body/input bubbles = NAND | sound; ports-right | clear |

The candidate third section GPR is kept separate pending a clear designator reading. The decoder inputs are transcribed without assigning a bonus threshold to them.

### IC133 —157; IC126 —17/17 x4

| Pins | Connection | Evidence | Confidence |
|---|---|---|---|
| 133.1 select | V2, W19 | mux; busrise | clear |
| 133.15 /enable | Ground | mux; ports-right | clear |
| 133.2, 5, 11, 14 | 132.14, 13, 12, 11 respectively | centre; decodepath; mux | clear |
| 133.3, 6, 10, 13 | 140.3, 2, 6, 7 respectively | rightmid; mux | clear |
| 133.4 -> 126.9 -> 126.8 | M1 BONUS A(I) | ports-right | clear |
| 133.7 -> 126.11 -> 126.10 | M2 BONUS B(I) | ports-right | clear |
| 133.9 -> 126.5 -> 126.6 | M3 BONUS C(I) | ports-right | clear |
| 133.12 -> 126.3 -> 126.4 | M4 BONUS D(I) | ports-right | clear |
| 126.1 -> 126.2 | 95.8 -> M5 /GAME END(I), R27 pull-up. Input/output bubbles make this noninverting | centre; ports-right | clear |
| 126.13 -> 12 section | Not drawn on N | ports-right | clear omission |

## Passive components

| Part | Value and endpoints | Evidence | Confidence |
|---|---|---|---|
| R22/C33 | 47K from 100.7 to Vcc; 1u tantalum between 100.6/7, positive 7 | left; bridge-path | clear |
| R20/C39 | 47K from 100.15 to Vcc; 3.3u tantalum between 100.14/15, positive 15 | left; bridge-path | clear |
| R23/C40 | 47K from 107.7 to Vcc; 3.3u tantalum between 107.6/7, positive 7 | lowermid | clear |
| R24/C41 | 47K from 107.15 to Vcc; 22u tantalum between 107.14/15, positive 15 | rightbottom | clear |
| R27 | 1K from 126.2/M5 to Vcc | ports-right | clear |
| R34 | 220 ohms between /GAME and 140.5 | gamepath; centre | clear |
| C55 | 0.1u, ceramic caption; /GAME side of R34 to ground | lowermid; gamepath | clear |
| C34 | 680p, /SCORE ST/100.3/107.11 to ground; NOT100.13 | bridge-path; lowerleft | clear |
| C37 | 680p, 108.6/107.10 to ground | lowermid | clear |
| C38 | 680p, 107.5/72.3 to ground | lowermid | clear |
| C54 | 1000p, GPR.8/100.11 to ground | lowerleft; bridge-path | clear net/value; GPR identity uncertain |
| C57 | 1000p, 143.6/53.9 to ground | lowerleft | clear |
| Small capacitor at 132.2 | 680p reading; 100.4/132.2 to ground. Designator resembles C47, last digit not safely distinguished | counter; bridge-path | clear endpoints; uncertain exact inscription |

Ceramic annotations under C54/C57 are not resistor symbols. Pulse widths are not derived here: component family, tolerance and trigger behavior would need separate treatment.

## Every-IC datasheet check

The following Texas Instruments PDFs were downloaded and their pin diagrams visually inspected. Original DIP/J/N-style mappings were used, not alternate W/FK/SO8 packages. These are manufacturer pinout references, **not evidence for wires or exact installed family suffixes**. Full type numbers are not printed next to several N gates; their comparison remains conditional on the symbol/function. Every visible N IC, including the formerly omitted gate, is covered.

| IC(s) | Manufacturer reference / inspected page | Check result |
|---|---|---|
| 80 | [74390/74LS390](https://www.ti.com/lit/ds/symlink/sn74ls390.pdf), p1 | Corrected 7 -> 15 and 13 -> 12 agree. Visible reset/output pins agree; omitted 5/6/10/11 not inferred wired |
| 81 | [74107/74LS107A](https://www.ti.com/lit/ds/symlink/sn74ls107a.pdf), p1 | J1, K4, CLK12, /CLR13, Q3 agree. Standard 107 and LS107A timing descriptions differ; no suffix inferred |
| 94 | [7474/74LS74A](https://www.ti.com/lit/ds/symlink/sn74ls74a.pdf), p1 | D12, CLK11, /PRE10, /CLR13, Q9, /Q8 agree |
| 100, 107 | [74123/74LS123](https://www.ti.com/lit/ds/symlink/sn74ls123.pdf), p1 | Both halves' A/B/CLR, Q, /Q and timing pins agree in both packages |
| 132 | [74161/74LS161A](https://www.ti.com/lit/ds/symlink/sn74ls161a.pdf), p1 | All shown pins agree; required /LOAD9 is omitted from drawing, physical tie unresolved |
| 140 | [74191/74LS191](https://www.ti.com/lit/ds/symlink/sn74ls191.pdf), p1 | Outputs3/2/6/7, clock 14, /load11, /enable 4, direction5, data15/1/10/9, MAX/MIN12 agree; 13 is the undrawn /RCO |
| 133 | [74157/74LS157](https://www.ti.com/lit/ds/symlink/sn74ls157.pdf), p1 | Select 1, /G15, input pairs 2/3, 5/6, 11/10, 14/13 and outputs4/7/9/12 agree |
| 126 | [7417](https://www.ti.com/lit/ds/symlink/sn7417.pdf), pp1, 3 | All five buffer pin pairs agree; noninverting/open-collector family, not an inverter |
| 95, 113; GPR conditionally | [7400/74LS00](https://www.ti.com/lit/ds/symlink/sn74ls00.pdf), pp1, 3 | Shown NAND pin groups match. GPR10/9 -> 8 matches 7400; ambiguous package label remains, not silently corrected |
| 72, 102 | [7402/74LS02](https://www.ti.com/lit/ds/symlink/sn74ls02.pdf), p1 | NOR 2/3 -> 1 and 8/9 -> 10 agree |
| IR/IP (candidate 88) | [7404/74LS04](https://www.ti.com/lit/ds/symlink/sn74ls04.pdf), p1 | Inverter 9 -> 8 and 11 -> 10 agree; number obscured, family not printed on N |
| 101 | [7408/74LS08](https://www.ti.com/lit/ds/symlink/sn74ls08.pdf), p1 | AND 12/13 -> 11, 9/10 -> 8, 4/5 -> 6 agree |
| 143 | [7410/74LS10](https://www.ti.com/lit/ds/symlink/sn74ls10.pdf), p1 | All three NAND sections match9/10/11 -> 8, 1/2/13 -> 12, 3/4/5 -> 6. GPR cannot additionally be the same physical 143.8 |
| 53 | [7411/74LS11](https://www.ti.com/lit/ds/symlink/sn74ls11.pdf), p1 | AND 9/10/11 -> 8 agrees with the De Morgan symbol |
| 21 | [7420/74LS20](https://www.ti.com/lit/ds/symlink/sn74ls20.pdf), p1 | Four-input NAND 9/10/12/13 -> 8 agrees. IC designator 21 is not a type 7421 caption |
| 108 | [7432/74LS32](https://www.ti.com/lit/ds/symlink/sn74ls32.pdf), p1 | OR 1/2 -> 3 and 4/5 -> 6 agree; both symbols describe OR |

Supply pins are not drawn on these N symbols. Reference DIP supplies are 16/8 for 390, 123, 161, 191, 157 and 14/7 for the remaining listed families. This is a datasheet observation, not a schematic tie. Undrawn gates on partly-used packages remain outside this sheet's evidence.

**Discrepancy report:** the IC80 discrepancies were first-pass misread numerals; no actual conflict remains there. IC132's absent /LOAD9 is an omission to investigate, not authority to add a tie. The GPR package lettering remains ambiguous; reading it as 143 produces a package/function conflict, whereas the candidate 113 fits the two-input NAND pinout. Compatibility alone does not settle its designator. No other mismatch was found among the visible pins, subject to the conditional family identifications above.

## Disposition of original checklist items 1–10

| Item | Second-pass result | Remaining evidence needed |
|---|---|---|
| 1 GAME pair | Resolved: upper GAME, lower /GAME. Sheet A IC47 Q9 and/Q8 evidence recorded | None for label polarity |
| 2 reset | W01/W02 resolved; IR/IP pin numbers and nets clear | Sharper designator scan or PCB evidence to certify IC88 identity |
| 3 control wires | Resolved with corrections W03–W07; IC72 replaces mistaken 172 | None for stated wire routes |
| 4 clears | Resolved with corrections: 53.9=143.6; 100.11=GPR.8; C34=/SCORE ST; 100.12 only counter enables | Sharper GPR label; see item 9 |
| 5 sound | Four decode inputs and CP branch traced W10, W17–W20 | No scoring interpretation certified by these rows alone |
| 6 passives | C38=680p; C54 on GPR-clear net; small counter capacitor's endpoints resolved | Sharper original scan/component list/PCB for its exact C47-like designator and confirmation of inscription |
| 7 PR38 order | Resolved 143.9=PR-38-7; 143.10=PR-38-9; separate GPR order also recorded | None for pin routing |
| 8 132 load | Confirmed no 9 lead/tie on symbol | PCB continuity or a more complete authoritative drawing; cannot invent Vcc tie |
| 9 pinout audit | All visible ICs checked against manufacturer diagrams; IC80 corrections and conditional identities recorded | Exact family suffixes/BOM, obscured IR/IP/GPR labels. No assertion that type-compatible inferred families are a read BOM |
| 10 M8 | Crossed M8 and note to cut/remove pin 8 confirmed in `note` | Destination-side connector/cabinet wiring or PCB continuity. N shows no signal wire atM8, so its removed function cannot be named. Sheet A was restricted to GAME evidence and not used to guess this |

Boxed `ジャンパー線無し` is the drawing's no-jumper-wires annotation. The M8 and IC94 notes are source annotations, not instructions to modify hardware.

## Rows changed and why

| First-pass row(s) | Second-pass change | Evidence/reason |
|---|---|---|
| IC80 7 -> 13; 11 -> 12 | **7 -> 15; 13 -> 12** | Fresh divider numerals; agrees with 390 datasheet, not a forced repair |
| GAME-upper/lower and all their loads | GAME, /GAME respectively; now clear | A-game-wide plus bar position on N |
| Reset fanout |53.11 and 140.11 confirmed alongside 81.13 | W02 dotted join; package label still uncertain |
| IC172 and its inputs | **IC72**; 2=80.9, 3=107.5 | centre/controlpath; first-pass wire assignments wrong |
| IC95.8 candidate branch | Removed supposed NOR connection; 126.1 is its drawn load | W07 no dots at crossings |
| IC108.1 |140.12, not 107.5 | W05 dotted MAX/MIN branch |
| IC140.12/IC102.8 | Shared net also reaches 108.1; now clear | W05 |
| IC108.3/IC107.2 | Shared with 140.14; now clear | W06 clock-row dot |
| IC53.9 |143.6, not 100.12 | W12 |
| IC100.11 and C54 | GPR.8, not 143.8 | W11; omitted gate now included separately |
| IC100.5; IC101.4 |100.5 -> 101.4, not 101.9; 143.6 removed from 101.4 | W08 |
| IC100.12 |132.7/10 only among drawn N loads; removed 53.9 claim | W09 |
| IC100.13; IC101.9; IC143.11 | Shared Q13 net to both inputs and 21.9, now clear | W10 |
| IC132.15; IC101.10 | Confirmed shared net | W13 |
| PLAYER ST; IC101.5 | Confirmed continuation from mono B inputs | W14 |
| /OTHER CAR; IC107.9 | Confirmed shared input | W15 |
| /SCORE ST; IC107.11; C34 | Shared with 100.3/C34; C34 removed from 100.13 | W16, visible dot versus adjacent undotted crossing |
| Four IC21 inputs and 113.1 | Candidates confirmed, now clear | W10, W17–W20 |
| PR38-to 143 inputs | Explicit order 9/10; new GPR connections recorded | W23 |
| C38 |680p now clear | lowermid fresh crop |
| Small capacitor 132.2 | Net clear; designator remains uncertain rather than a guessed C41/C47 | counter crop |
| IC132.9 | Drawing omission confirmed; physical tie remains unresolved | counter plus 161 pinout |
| All device types/pin roles | Added manufacturer audit, including previously omitted GPR | Datasheet table; conditional identities retained |
| Divider/bonus prose | State the divide-by-200 wiring ratio separately from score and payout | IC81 toggle plus two IC80 decade connections; N alone does not certify a payout/scoring rule |

## Still uncertain

1. IR/IP package numbers (candidate 88), and GPR package number (candidate 113; 143-like overwritten strokes). Clearer source or PCB evidence required.
2. Exact designator/inscription of the small 680p-like capacitor on 132.2, candidateC47.
3. Physical /LOAD9 tie on IC132; omitted from this drawing.
4. M8's destination-side function and effect of removal; no signal is attached to it on N.
5. Exact installed logic families/suffixes where N prints only abbreviations or gate symbols; package supply/unused-section wiring not drawn on N.
6. Handwritten date on IC94 pin 10 revision note. The tie itself is clear.

## Complete N inter-sheet interface and pads

Direction is relative to N. **“None drawn” means an internal off-sheet arrow with no connector/pad identifier printed on N**, not an unknown pad guessed from another sheet. Source/destination letters are transcribed as drawn, including V2(A) and V4(F). M8 is a separately crossed pad, not an additional named signal.

| Direction | Signal | Other sheet | Pad on N | N endpoint(s) | Confidence/evidence |
|---|---|---|---|---|---|
| In | V4 | F | None drawn |113.2 | clear; upper-left, v4-row, sound |
| In | V5 | E | CC |101.12 | clear; upper-left |
| In | /COIN & TEST | A | None drawn |95.5 | clear; upper-left |
| In | /INI. RESET | A | None drawn |95.4 | clear; upper-left |
| In | V2 | A | None drawn |133.1, 21.13 | clear; W19 |
| In | /BRIDGE AP | D | CD |100.9 | clear; left |
| In | PLAYER ST | G | None drawn |100.10, 100.2, 101.5 | clear; W14 |
| In | /OTHER CAR | H | None drawn |100.1, 107.9 | clear; W15 |
| In | GAME | A | None drawn |53.10 | clear; W22, A-game |
| In | /GAME | A | None drawn |94.11, 95.9, R34 to 140.5, C55 | clear; W21, A-game |
| In | /SCORE ST | G | None drawn |100.3, 107.11, C34 | clear; W16 |
| In | PR-38-7 | H | None drawn |143.9, GPR.10 | clear routing; GPR identity uncertain; W23 |
| In | PR-38-9 | H | None drawn |143.10, GPR.9 | clear routing; GPR identity uncertain; W23 |
| In | /ACC1 | F | None drawn |143.1, 143.2 | clear; W24 |
| Out | BONUS SOUND | A | None drawn |113.11 | clear; ports-right |
| Out | /BONUS POINT | F | None drawn |IP.10 | clear routing; IP identity uncertain; ports-right |
| Out | /GAME END | I | M5 |126.2 | clear; ports-right |
| Out | BONUS A | I | M1 |126.8 | clear; ports-right |
| Out | BONUS B | I | M2 |126.10 | clear; ports-right |
| Out | BONUS C | I | M3 |126.6 | clear; ports-right |
| Out | BONUS D | I | M4 |126.4 | clear; ports-right |
| Out | BONUS CP | M | CE |107.13 | clear; rightbottom |
| Out | /BONUS CP | A | None drawn |107.4 | clear; rightbottom |

Documentation-only second pass. No HDL or ROM changes, no simulation or physical continuity test. Review status: reread and datasheet-checked, still subject to the explicitly unresolved source limitations above.
