# Transit Report

Loading screen customization for Starfield: randomized lifetime stats, faction themes, animated badges and indicators, custom artwork and a local clock.

Current build: **1.0**. This is the packaged 1.0 build; online publication is a separate step.

[Download on Nexus Mods](https://www.nexusmods.com/starfield/mods/18687) | [Source on GitHub](https://github.com/JerKnuts/Transit-Report)

## Features

- 67 lifetime counters, automatically randomized from the full available pool each loading screen.
- Lifetime stats On/Off, optional hiding of zero-value readings, and one to five pages with four stats per page.
- A/D and left/right on the controller D-pad change stat pages.
- Seven faction themes: Constellation, Crimson Fleet, Freestar Collective, House Va'ruun, Ryujin Industries, Trackers Alliance and United Colonies.
- Matching faction wallpapers and coin badges/indicators. Coins have a three-second tilt and a softer six-second glint sweep.
- Theme > Random Each Load selects one faction shared by artwork slots set to Theme. Other artwork choices remain independent.
- Individual Orbiting Star, Jump Gate and Signal Star badges/indicators; animated Orbital Chart, Grav-jump Tunnel and Survey Sweep backgrounds; original game artwork and Hidden options where available.
- Independent badge/indicator sizes: 50%, 75%, 100%, 125%, 150%. Normal (100%) is the enlarged baseline, equal to the earlier 150% size.
- Optional character name/level, XP display, loading tips and a 12/24-hour local PC clock.
- Custom PNG/JPG/JPEG images and animated GIFs, prepared automatically without a separate importer.
- Short transitions show only the selected indicator; stat pages are reserved for full loading screens.

## Requirements

- Starfield **1.16.244.0**; the native plugin is gated to this runtime.
- A matching [Starfield Script Extender (SFSE)](https://www.nexusmods.com/starfield/mods/106).
- [Address Library for SFSE Plugins](https://www.nexusmods.com/starfield/mods/3256).
- [OSF Settings](https://www.nexusmods.com/starfield/mods/18326) and its requirements only when choosing that integration.

## Installation and settings

Install the complete ZIP with a FOMOD-capable manager such as MO2 or Vortex. Select exactly one method:

| Method | Where to configure |
| --- | --- |
| OSF Settings | Open OSF Settings and select Transit Report. |
| Gameplay Options | Open Settings > Gameplay Options and find TRANSIT REPORT. OSF is not required for this method. |
| Neither - configure in installer | Choose settings during installation. No in-game settings entry; reinstall to change them. |

Launch through SFSE. Use **Replace**, rather than Merge, when updating or switching methods, disable earlier test overlays, and keep only one Transit Report installation enabled. Fully restart Starfield after installation. Existing saved preferences may override new defaults.

See [installation and custom artwork instructions](docs/INSTALL.md).

## Custom artwork

Run Starfield once to create these folders, then put your images in the matching folder:

```text
Documents/My Games/Starfield/Transit Report/Artwork/
  Badges/
  Indicators/
  Backgrounds/
```

Choose **Custom** for each desired slot and restart Starfield after adding, removing or changing files. Any filenames work. Each folder supports up to 64 images; one valid image is selected per loading screen. Random choices avoid immediate repeats when alternatives exist within the current session.

Transparent PNG works well for badges and indicators. Still badges stay still; still indicators rotate. Animated GIFs play their own looping animation. Wallpapers fill the screen without stretching and receive a dark lower gradient for readable text.

No Python, Pillow, external converter or manual SWF conversion is required to use the mod. The plugin prepares a cache under `Data/Interface/TransitReport/Cache`; MO2 may redirect generated files to Overwrite. Keep source images in Documents, not Cache. Empty or invalid Custom pools fall back to Orbiting Star or Orbital Chart.

Still-image limits: 64 MB per source file, 16 megapixels, with large output reduced to a maximum 2560px dimension. Animated GIF limits: 240 source frames, 60 seconds, 2048px canvas, and 16 megapixels across all decoded frames. Runtime animations use at most 512px dimensions and 30fps timing. APNG animation import is not supported.

## Compatibility and limitations

- All methods replace `loadingmenu.swf` and `fadermenu.swf`; other replacements of those files can conflict.
- Gameplay Options replaces only `mainmenu_settingspanel.swf`, `settingspanel.swf` and `settingspanel_lrg.swf`. It does **not** replace `mainmenu.swf`, `pausemenu.swf` or `pausemenu_lrg.swf`. Other settings-panel mods may still conflict.
- OSF Settings and installer-only do not install those settings-panel replacements. No OSF Settings or OSF UI framework files are modified.
- Stats are snapshots captured automatically after entering a save. No Status-menu visit is needed. Initial save loading omits unavailable stats; play briefly before triggering another full load.
- No ESM/ESP is installed. Personal artwork and saved settings remain in Documents when the mod is removed.
- Gameplay Options uses a deferred, panel-owned connection. The user reported no crashes in follow-up testing after earlier immediate-Esc crashes. Test history and remaining validation are recorded in [RELEASE_VALIDATION.md](RELEASE_VALIDATION.md).

## Source, license and credits

Build instructions: [docs/BUILD.md](docs/BUILD.md). Full release history: [CHANGELOG.md](CHANGELOG.md).

The native filename `LSCNativeBridge.dll` and internal OSF ID `loading-screen-configurator` are retained for compatibility with existing preferences.

Authored code is GPL-3.0-or-later with the included exceptions: [LICENSE](LICENSE), [EXCEPTIONS](EXCEPTIONS). Third-party components and game-derived templates retain their respective terms; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Thanks to the developers of SFSE, Address Library, OSF Settings, CommonLibSF and JPEXS FFDec, and everyone testing Transit Report. Development and documentation assistance: OpenAI ChatGPT/Codex.

Artwork choice order ends with **Theme, Hidden, Custom** for badge, indicator and background. Hidden background uses plain black while preserving enabled information.
