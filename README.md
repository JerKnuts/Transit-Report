# Transit Report

Loading screen customization for Starfield: lifetime character statistics, animated backgrounds, badges and a local clock.

**Download:** [Nexus Mods](https://www.nexusmods.com/starfield/mods/18687) - Build version: **0.9.8**

## Faction themes

Constellation, Crimson Fleet, Freestar Collective, House Va'ruun, Ryujin Industries, Trackers Alliance and United Colonies each pair a matching wallpaper with a coin badge and indicator. All faction coins use filtered textures, a three-second tilt loop and a prominent glint. Choose Individual selections to use separate artwork controls.

## Custom artwork

Choose **Custom** for Character badge, Loading indicator or Loading background in OSF Settings, Gameplay Options or the FOMOD installer. Place one or more PNG, JPG, JPEG or GIF images with **any filenames** in each matching folder:

```text
Documents/My Games/Starfield/Transit Report/Artwork/
  Badges/
  Backgrounds/
  Indicators/
```

These folders are created on startup. Restart Starfield after adding or replacing images. The plugin automatically prepares compatible cached files; no importer, Python, separate program or manual SWF conversion is needed. Originals stay in Documents; generated files live under Data/Interface/TransitReport/Cache (MO2 may redirect them to Overwrite). Keep your personal images out of the generated Cache folder.

Transparent PNG is recommended for badges and indicators. Still badges remain still and still indicators rotate; animated GIF badges and indicators play their own animation. Wallpapers fill the screen without stretching and have a dark lower gradient for readable stats. Animated GIFs are composited and loop with their frame timing (quantized to 30fps); APNG import is not included. Custom folders support random selection.

Use one or more supported images per folder. Empty folders or invalid images fall back to Orbiting Star for badge/indicator and Orbital Chart for wallpaper. Text files are ignored. Images are limited to 16 megapixels and 64 MB; images larger than 2560 pixels on their longest side are reduced automatically. Included individual badge/indicator designs are Orbiting Star, Jump Gate and Signal Star. Included animated backgrounds are Orbital Chart, Grav-jump Tunnel and Survey Sweep. Existing settings and defaults remain unchanged.

## Features

- 67 lifetime counters automatically randomized from the full pool each load. Hide zero-value stats remains optional.
- Four stats per page, one to five pages; change pages with A/D or the controller D-pad.
- Animated Orbital Chart, Grav-jump Tunnel and Survey Sweep backgrounds, or the original game images with a dark backing for readability.
- Independent character badge and loading indicator options (Original, Orbiting Star or hidden).
- Optional local PC clock, character name/level/XP and loading tips.
- Three ways to configure, chosen in the FOMOD installer:
  - **OSF Settings:** a Transit Report page in OSF Settings.
  - **Gameplay Options:** a TRANSIT REPORT section in the game's own Settings > Gameplay Options (no OSF needed).
  - **Neither (configure in installer):** pick all 17 settings during installation; no in-game settings entry.

## Requirements

- Starfield **1.16.244.0**
- [Starfield Script Extender (SFSE)](https://www.nexusmods.com/starfield/mods/106) matching your game version
- [Address Library for SFSE Plugins](https://www.nexusmods.com/starfield/mods/3256)
- [OSF Settings](https://www.nexusmods.com/starfield/mods/18326) (only for the OSF Settings option)

## Install

Install the archive with a FOMOD-capable manager (MO2 or Vortex), choose a settings method and launch through SFSE. Use **Replace** (not Merge) when updating or switching methods, and keep only one copy enabled. See [docs/INSTALL.md](docs/INSTALL.md) for details.

## Compatibility

- **Gameplay Options** replaces the MainMenu, PauseMenu and SettingsPanel SWFs (including large-interface variants) and can conflict with other menu replacers. The OSF Settings and installer-only options don't touch those menus.
- Mods that replace `loadingmenu.swf` or `fadermenu.swf` conflict with all options.
- No ESM/ESP; safe to add to an existing save.

## Known limitations

- Stats are snapshots captured a few seconds after a save loads, so the first load of a session shows only character info. Play a few seconds, then trigger another full load.
- Short transitions (elevators, doors) show only the loading indicator.
- Gameplay Options persistence and the installer-only method still need broader in-game testing.
- A FaceCustomization renderer crash was also reproduced with Transit Report disabled. Its cause remains unresolved; this build does not establish a fix.

## Building from source

See [docs/BUILD.md](docs/BUILD.md). Layout:

- `native/`: SFSE plugin (`LSCNativeBridge.dll`) and vendored CommonLibSF.
- `src/`: loading screen and Gameplay Options ActionScript, OSF schema and shared settings catalog.
- `assets/templates/`: SWF templates the ActionScript is compiled into.
- `installer/`, `scripts/`: FOMOD definitions and packaging helpers.
- `tests/`: installer and settings-mapping checks.

The DLL and OSF settings ID keep their original `LSCNativeBridge` / `loading-screen-configurator` names so saved preferences carry over from earlier builds.

## License

Authored code is GPL-3.0-or-later with the included modding exceptions ([LICENSE](LICENSE), [EXCEPTIONS](EXCEPTIONS)). Third-party libraries and game-derived UI templates keep their own terms; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Thanks to the developers of SFSE, Address Library, OSF Settings, CommonLibSF and JPEXS FFDec, and to everyone testing Transit Report.

## Included animated designs

Select **Transit Emblem** for the included animated badge or indicator, and **Orbital Horizon** for the included animated planet wallpaper. These are dedicated built-in selections, independent of personal image files. **Custom** uses only your Documents images. Existing Orbiting Star and procedural background choices remain unchanged.

Animated GIF importing and playback are supported. User PNG/JPG images remain still (the UI rotates a still-image indicator). APNG animation import is not included. No former collection test logo is part of the release.

## Random Custom images

Put up to 64 PNG/JPG/JPEG/GIF images of any names in each Artwork folder. Custom chooses one valid image per loading screen and keeps it steady for that screen. Named built-in designs are separate selections and ignore personal files. New/changed images are prepared at startup, while unchanged cached assets are reused. Invalid files are skipped; an empty valid pool falls back to Orbiting Star or Orbital Chart. Restart after adding/removing/changing files.


0.9.6 test follow-up: user confirmed the previous test checklist passed except custom indicator overlap. Custom now appears last in each artwork selector; testing controls removed; Local PC time moved to Full loading screen. Custom indicator suppresses fallback artwork during subsequent refreshes. This follow-up needs an in-game overlap recheck.


0.9.6 post-load hitch investigation: lifetime capture now scans at most four entries per task with a 250-microsecond cooperative time target, reuses normalized name lookups, and publishes only completed scans. Timing logs record peak slice and slow gameplay samples. The target is checked between entries, not a hard real-time guarantee. Actual hitch improvement requires in-game comparison.


0.9.6 post-load hitch investigation: lifetime capture now scans at most four entries per task with a 250-microsecond cooperative time target, reuses normalized name lookups, and publishes only completed scans. Timing logs record peak slice and slow gameplay samples. The target is checked between entries, not a hard real-time guarantee. Actual hitch improvement requires in-game comparison.


Post-load follow-up: user log measured 2413 ms total counter-read work and 27.6 ms peak batch. Removed per-read VirtualQuery preflights; bounded read-only copies retain SEH fault protection. Incremental batches and timing remain. Also removed the obsolete diagnostics OSF query so the adapter expects the 16 shipped controls. Performance improvement is pending in-game measurement.


Short-transition indicator follow-up: enforce Custom/built-in replacement exclusivity at EXIT_FRAME and RENDER, after timeline advancement can restore original symbol visibility. Previous user log confirms lifetime scan reduced from 2413 ms total work to 0.151–0.163 ms, peak slice 0.011 ms; user reports freeze appears resolved. Short-transition visual fix still needs in-game confirmation.


0.9.7: Each artwork selector now includes Theme. Only slots set to Theme use the chosen faction. Original, Hidden, built-in and Custom choices work independently with any faction selected. Existing saved slot values are respected; select Theme explicitly to use faction artwork. Theme with no faction selected falls back to Orbiting Star/Orbital Chart.


Animated GIF limits: up to 240 frames, 60 seconds, 2048px source canvas and 16 megapixels across all decoded frames. Animations are resized to at most 512px. Very short frame delays are limited by 30fps playback. Restart Starfield after adding files. Custom animated badge playback was verified in-game by the user.


Local 0.9.8 update: Theme now offers Random Each Load. It picks one of the seven faction themes per loading screen and holds that choice throughout the load. Slots set to Theme share the selection; other artwork options remain independent. Immediate repeats are avoided when alternatives exist. In-game verification pending.


Local polish test: independent badge/indicator sizes (50%, 75%, 100%, 125%, 150%); no immediate random theme or Custom artwork repeats when alternatives exist (session-wide); optional hide-zero lifetime stats. Default size is Normal (100%), equal to the previous 150% and hide-zero is Off. In-game clearance and behavior testing pending.

Installer text fix: the installer-only choice is labeled "Neither - configure in installer". Category page titles also use plain hyphens to avoid corrupted characters.

FOMOD descriptions use general installation guidance; collection-specific recommendations and outdated initial-testing wording have been removed.

Coin glint update: tilt frames now preserve the nested glint animation, with a brighter moving highlight on all seven faction coins. Both badge and indicator use the corrected asset. In-game verification pending.

Lifetime stats are always random. Category and Lifetime display selectors have been removed from OSF Settings, Gameplay Options and the installer; previous category restrictions are ignored.

Lifetime stats can be switched On or Off under Full loading screen (On by default). Enabled stats remain randomized; Hide zero-value stats and page count remain independent. Faction coin glints now use half the previous peak opacity and a slower six-second sweep with shorter travel; the three-second tilt is unchanged. In-game verification pending.

OSF Settings sections use untitled divider groups; the Transit Report page title and setting labels remain visible. No OSF framework files are replaced.
