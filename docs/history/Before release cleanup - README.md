# Transit Report

Loading screen customization for Starfield: lifetime character statistics, animated backgrounds, badges and a local clock.

**Download:** [Nexus Mods](https://www.nexusmods.com/starfield/mods/18687) Ã‚Â· Build version: **0.9.7** (short-transition indicator recheck pending)

## Custom artwork

Choose **Custom** for Character badge, Loading indicator or Loading background in OSF Settings, Gameplay Options or the FOMOD installer. Place one or more PNG, JPG or JPEG images with **any filenames** in each matching folder:

```text
Documents/My Games/Starfield/Transit Report/Artwork/
  Badges/
  Backgrounds/
  Indicators/
```

These folders are created on startup. Restart Starfield after adding or replacing images. The plugin automatically prepares compatible cached files; no importer, Python, separate program or manual SWF conversion is needed. Originals stay in Documents; generated files live under Data/Interface/TransitReport/Cache (MO2 may redirect them to Overwrite). Keep your personal images out of the generated Cache folder.

Transparent PNG is recommended for badges and indicators. The badge is still and the indicator rotates. Wallpapers fill the screen without stretching and have a dark lower gradient for readable stats. This version supports still images; GIF/APNG animation import is not included; Custom image folders support random selection.

Use one or more supported images per folder. Empty folders or invalid images fall back to Orbiting Star for badge/indicator and Orbital Chart for wallpaper. Text files are ignored. Images are limited to 16 megapixels and 64 MB; images larger than 2560 pixels on their longest side are reduced automatically. Transit Emblem and Orbital Horizon are bundled as separate named selections. Existing settings and defaults remain unchanged.

## Features

- 67 lifetime counters across seven categories: pick categories, individual counters, or randomize each load.
- Four stats per page, one to five pages; change pages with A/D or the controller D-pad.
- Animated Orbital Chart, Artifact Starfield and Grav-jump Tunnel backgrounds, or the original game images with a dark backing for readability.
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
- A FaceCustomization renderer crash seen during testing also happens with Transit Report disabled; it is not caused by this mod.

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

User PNG/JPG images remain still (the UI rotates a user indicator). GIF/APNG decoding is not included. No former collection test logo is part of the release.

## Random Custom images

Put up to 64 PNG/JPG/JPEG images of any names in each Artwork folder. Custom chooses one valid image per loading screen and keeps it steady for that screen. Named built-in designs are separate selections and ignore personal files. New/changed images are prepared at startup, while unchanged cached assets are reused. Invalid files are skipped; an empty valid pool falls back to Orbiting Star or Orbital Chart. Restart after adding/removing/changing files.


0.9.6 test follow-up: user confirmed the previous test checklist passed except custom indicator overlap. Custom now appears last in each artwork selector; testing controls removed; Local PC time moved to Full loading screen. Custom indicator suppresses fallback artwork during subsequent refreshes. This follow-up needs an in-game overlap recheck.


0.9.6 post-load hitch investigation: lifetime capture now scans at most four entries per task with a 250-microsecond cooperative time target, reuses normalized name lookups, and publishes only completed scans. Timing logs record peak slice and slow gameplay samples. The target is checked between entries, not a hard real-time guarantee. Actual hitch improvement requires in-game comparison.


0.9.6 post-load hitch investigation: lifetime capture now scans at most four entries per task with a 250-microsecond cooperative time target, reuses normalized name lookups, and publishes only completed scans. Timing logs record peak slice and slow gameplay samples. The target is checked between entries, not a hard real-time guarantee. Actual hitch improvement requires in-game comparison.


Post-load follow-up: user log measured 2413 ms total counter-read work and 27.6 ms peak batch. Removed per-read VirtualQuery preflights; bounded read-only copies retain SEH fault protection. Incremental batches and timing remain. Also removed the obsolete diagnostics OSF query so the adapter expects the 16 shipped controls. Performance improvement is pending in-game measurement.


Short-transition indicator follow-up: enforce Custom/built-in replacement exclusivity at EXIT_FRAME and RENDER, after timeline advancement can restore original symbol visibility. Previous user log confirms lifetime scan reduced from 2413 ms total work to 0.151–0.163 ms, peak slice 0.011 ms; user reports freeze appears resolved. Short-transition visual fix still needs in-game confirmation.


0.9.7 artwork expansion: Wayfinder, Jump Gate, Eclipse, Pathfinder and Signal Star are available as both character badges and loading indicators. Five simple animated backgrounds added: Star Chart, Deep Orbit, Survey Sweep, Constellation and Solar Horizon. All three configuration backends include the options, with Custom last and existing values/defaults preserved. New designs require in-game visual verification.


0.9.7 linework correction: rebuilt Star Chart, Deep Orbit, Survey Sweep, Constellation and Solar Horizon as resolution-independent vector SWFs. No raster linework textures remain in those backgrounds; each is approximately 4–6 KB with a six-second loop. Exported at 3440-pixel width for visual inspection. All included badges plus the earlier collection test are shown in a separate comparison video; collection test is not packaged as a preset. In-game appearance still needs recheck.


0.9.7 badge selection cleanup: Orbiting Star, Jump Gate and Signal Star are the retained animated designs for badges and indicators. Original, Hidden and Custom remain. Transit Emblem, Wayfinder, Eclipse and Pathfinder are removed from selections and install assets; historical source concepts are retained. Background options are unchanged.


0.9.7 final background selection: retain Orbital Chart, Grav-jump Tunnel and Survey Sweep, alongside Game images and Custom (last). Other named backgrounds and their runtime assets are removed from the install package. Existing retained selection values and defaults are preserved across all three settings backends. Historical artwork concepts remain in source only.


0.9.7 Theme selector: Constellation pairs the approved coin badge and indicator (identical gentle tilt/glint) with the approved static navy/ribbon wallpaper. Individual selections remains the default and preserves existing separate artwork preferences. Theme controls are available in OSF Settings, Gameplay Options and installer-only configuration. Theme affects artwork only; lifetime stats, clock, tips and short-transition behavior are unchanged. In-game theme switching still needs verification.


0.9.7 Crimson Fleet theme: added to OSF Settings, Gameplay Options and FOMOD alongside Constellation. Uses the approved steel/crimson coin with identical gentle tilt/glint for badge and indicator, plus the static industrial-banner wallpaper. Individual selections remains the default; saved artwork choices and all stats/clock controls are preserved. New theme requires in-game switching verification.


0.9.7 Freestar Collective theme: added under that exact name in OSF Settings, Gameplay Options and FOMOD. Uses the approved gold RANGER badge with identical gentle tilt/glint for badge and indicator, plus the static wallpaper inspired by The Rock. Defaults and separate saved artwork choices remain unchanged. In-game verification pending.


0.9.7 artwork revision: replaced the Constellation ribbon wallpaper with the approved Lodge-inspired library interior and dark lower area for stats. The existing gentle-tilt coin badge and indicator are unchanged. Packaged wallpaper checked; updated background still needs in-game verification.


0.9.7 House Va'ruun theme: added to OSF Settings, Gameplay Options and FOMOD configuration. Approved silver/green serpent coin with matching gentle tilt/glint for badge and indicator, and Shattered Space-inspired wallpaper. Defaults preserved. In-game verification pending.


0.9.7 Ryujin Industries theme: added to OSF Settings, Gameplay Options and FOMOD. Approved silver/red coin with matching gentle tilt/glint for badge and indicator, and corporate lobby wallpaper with suspended dragon. Defaults preserved. In-game verification pending.


0.9.7 Trackers Alliance theme: added to OSF Settings, Gameplay Options and FOMOD. Approved silver/red/blue coin with identical gentle tilt/glint for badge and indicator, plus stone headquarters/bounty-board wallpaper. Defaults preserved. In-game verification pending.


0.9.7 United Colonies theme: added to OSF Settings, Gameplay Options and FOMOD. Approved navy/gold/silver coin with identical gentle tilt/glint for badge and indicator, plus UC lobby wallpaper with flags. All seven faction themes are included. Defaults preserved. In-game verification pending.


0.9.7 Crimson Fleet anti-aliasing test: runtime coin texture prefiltered to 192px with premultiplied-alpha resampling; tilt and glint reduced to limit fine-detail shimmer. High-resolution source PNG preserved. Other faction coins unchanged. In-game comparison pending.


0.9.7 faction coin refinement: applied the user-verified Crimson Fleet 192px premultiplied-alpha texture filtering, reduced tilt and softer glint to all seven faction coins. Detailed source PNGs preserved. Other six factions need in-game comparison. Crimson Fleet wallpaper 02 was subsequently approved and is now packaged.


0.9.7 Crimson Fleet wallpaper revision: replaced the banner wallpaper with the approved Key-inspired bar and recreation area. Previous render retained in historical review files. In-game wallpaper verification pending.


0.9.7 coin animation revision: applied the approved comparison to all seven factions. Three-second loop (twice as fast), stronger tilt and prominent glint for both badges and indicators. Keeps filtered 192px textures. Automated asset validation passed; in-game verification pending.
