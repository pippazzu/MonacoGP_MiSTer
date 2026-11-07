# Pro Monaco GP

Pro Monaco GP (Sega, 1980) support shares one RBF with Monaco GP. Select the Pro Monaco GP MRA to enable the revised board circuits and separate saved settings/scores.

Implemented features include the bonus circuit, +200 graphic, 14-lamp car and bonus bars, scores above 9999, SUPER RACER SCORE, and the Pro display/attract circuitry. Cabinet meters have been traced; this release does not emulate physical cabinet meters.

`docs/` contains the circuit readings, comparisons and observed behavior. `reconstruction/` documents PR-54 and PR-01/PR-02, which have no original dump in this release. Their modeled data is explicitly identified as reconstruction; a future lamp PROM dump can replace the parameter data without replacing the decoding logic.

The transcriptions cite Sega service manual 420-0525. Scans and local crop images are not distributed in this repository. Original Monaco GP traces are in the root `docs/trace/` directory.

The Pro-only RAM reset DIP holds the board switch closed while On; return it to Off after clearing the score memory.
