# Transit Report

Loading screen customization for Starfield: lifetime character statistics, animated backgrounds, badges and a local clock.

**Download:** [Nexus Mods](https://www.nexusmods.com/starfield/mods/18687) · Current version: **0.9.5a** (public beta ahead of 1.0)

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
