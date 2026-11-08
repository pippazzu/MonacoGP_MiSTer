# Monaco GP MiSTer FPGA

Core for SEGA Monaco GP (1979) and Pro Monaco GP (1980), based on the TTL board schematics. Monaco GP was verified against recordings of three original boards; the Pro release has also been tested on MiSTer hardware.

Use ROMs (not included) conforming to monacogp.zip (merged) from MAME's romset.

## Install

Extract the latest [release package](https://github.com/pippazzu/MonacoGP_MiSTer/releases) to the root of the MiSTer SD card. It installs both MRAs in `_Arcade` and one shared RBF in `_Arcade/cores`. Supply `monacogp.zip` separately. Launch **Monaco GP** or **Pro Monaco GP** to select the board; each has separate saved scores and DIP settings.

## Pro Monaco GP

Pro adds a scrolling attract display, overtaking bonuses and the +200 graphic, scores above 9999, and SUPER RACER SCORE. Hold Y to see the panel: the top bar has 9 green and 5 red lamps; the bottom bar has 14 red bonus lamps. Cars 1–14 light successive top lamps, 15 keeps the bar full, and car 16 clears it and adds a stored bonus. A crash clears the car bar while retaining stored bonuses for the payout.

The Pro-only DIP entry **RAM reset (board switch)** clears score memory while On. Set it back to Off after clearing.

PR-54 (+200) and PR-01/PR-02 (lamp decoding) are documented reconstructions, not original PROM dumps. The top bar follows the owner's observations; the bottom bar's count mapping is uncertain. See [the reconstruction notes](pro/reconstruction/LAMP_PROMS.md) and [Pro documentation](pro/README.md).

## Settings

- **Display:** the game uses external LEDs for scorekeeping and time: this core reproduces them via an overlay, along with a gear indicator. They can be hidden in the Display menu. Hold Y to display the full LED panel.
- **Back speaker:** as featured in the sit-down cabinet, selecting "Right channel" plays back siren and passing car sound effects when behind the player.
- **Passing car R109:** the resistor that sets how much passing car 1's sound is modulated (sound sheet D-6). The schematic reads .33K, the default; 3.3K gives the dense, buzzy sound heard in board recordings and the Saturn remake. It can be changed while playing. See [the comparison](docs/sound/OTHER_CAR_COMPARE.md).
- **Sensitivity:** recommended low for dial controls (preferred control method), high or highest for analog stick, high for digital controls.

## Controls

- **Acceleration:** analog acceleration is enabled via right analog stick, or R trigger if you use a compatible MiSTer main unstable. Real boards only have four possible accelerator steps, including 0.
- **Steering:** analog steering via left analog stick.
- **Gear:** a lever on the real board, a toggle (B button) in this core.

## Not on the original board

The score, time and gear overlays and the on-screen LED panel. Scores are also kept between sessions: use Save settings in the OSD to write them. The original board has no score saving feature. Original Monaco GP's first-boot scrolling remains under investigation; saved scores have been ruled out as the cause. Pro's separate attract circuit is implemented.



## Behavior verified on original hardware

- Edges of the spinning car sprites disappear, especially when near the bottom of the screen.
- White and purple lines often do not touch the houses on the left side of the road.
- Passing car sound effects sometimes not triggering.
- Bridge warning sign with two stray pixels (also present in PROM data), faintly visible in one of the recordings.
- Siren sometimes not triggering until the rescue car reaches the player in tunnel zone.
- Tunnel zone graphics not scrolling completely when coming back to Zone A.
- High score fanfare plays back wrong notes in every single real board recording. The tuning closest to factory spec is featured in the Sega Saturn remake.
- Siren sound sometimes playing without a rescue car showing up: this seems to be triggered by a sudden change in acceleration when the sound starts playing.

## To be verified

- **Audio pitch and tone,** especially for the passing car sound effects: most surviving boards only play back one out of two possible sounds (with 4 variations each). This core seems to be close to a Monza GP bootleg board.
- **Attract mode behavior:** unsure if real board scrolls through the zones when first booting. Static road with passing cars after one game over is real hardware behavior, to be confirmed if house placement is the same on real boards after a game over screen in tunnel zone.

## Credits

Andrea Bogazzi: general supervision, highscore saving, flipscreen framebuffer and contribution to the initial schematic tracing.

Uses the JT Framework by Jose Tejada (Jotego), not an official JT Core. This core is licensed under GPLv3.

Vibecoded.

## Source and builds

JTFRAME is pinned in `UPSTREAM_REVISION`. Use `python3 scripts/setup_jtframe.py` to fetch it, prepare your own ROMs with `scripts/prepare_roms.py`, and run `python3 scripts/run_tests.py`. Build scripts are in `scripts/`; Windows uses `scripts/build_mister_windows.sh` with Quartus and Go installed. See [release provenance and validation](docs/RELEASE_20261107.md).
