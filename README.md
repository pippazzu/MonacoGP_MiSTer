# Monaco GP MiSTer FPGA

Core for SEGA Monaco GP (1979), based on the TTL board schematics. Verified against recordings of three original boards.

Use ROMs (not included) conforming to monacogp.zip (merged) from MAME's romset.

## Settings

- **Display:** the game uses external LEDs for scorekeeping and time: this core reproduces them via an overlay, along with a gear indicator. They can be hidden in the Display menu. Hold Y to display the full LED panel.
- **Back speaker:** as featured in the sit-down cabinet, selecting "Right channel" plays back siren and passing car sound effects when behind the player.
- **Sensitivity:** recommended low for dial controls (preferred control method), high or highest for analog stick, high for digital controls.

## Controls

- **Acceleration:** analog acceleration is enabled via right analog stick, or R trigger if you use a compatible MiSTer main unstable. Real boards only have four possible accelerator steps, including 0.
- **Steering:** analog steering via left analog stick.
- **Gear:** a lever on the real board, a toggle (B button) in this core.

## Not on the original board

The score, time and gear overlays and the on-screen LED panel. Scores are also kept between sessions: use Save settings in the OSD to write them. The original board has no score saving feature. When saved scores exist, the scrolling attract mode on first boot does not appear.



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
