# Transit Report — 0.9.5

Nexus title: **Transit Report - Loading Screen Customization**. Version **1.0** is reserved for the first Nexus/GitHub release.

Defaults in both menus: Orbiting Star badge; hidden indicator; Orbital Chart; character, progress and tips on; two pages; diagnostics off; 12-hour clock; Random Each Load; all seven categories set to All Stats. Existing saved preferences are preserved.

## Install

Drag `Release Archives/Transit Report 0.9.5.zip` into MO2. Use the mod name **Transit Report**.
Disable the old Loading / Loading Screen Configurator entry if it is still present. Keep one version enabled.
When reinstalling or changing backend, use **Replace**, not Merge, so old menu/schema/review files are removed.
The FOMOD asks for one of three settings locations:

- **OSF Settings (recommended for the existing collection):** use the Transit Report page in OSF Settings.
  Requires OSF Settings. Keeps the previous internal settings ID, so existing saved OSF preferences remain.
  Installs no MainMenu, PauseMenu or SettingsPanel patches.
- **Gameplay Options (standalone):** adds a TRANSIT REPORT section directly inside the game's Gameplay Options.
  Does not require OSF Settings or OSF UI. Saves its own preferences under
  Documents/My Games/Starfield/Transit Report/Settings.ini. Changes save immediately; back out of settings to play.
  This option replaces MainMenu, PauseMenu and SettingsPanel SWFs, including large-interface variants.
  Other replacements of those files can conflict. Check MO2 conflicts; this is an initial compatibility test,
  not a guarantee that every existing main-menu/pause-menu/UI overhaul is preserved.

Both options require Starfield **1.16.244.0**, matching SFSE and Address Library. No ESM or image importer.
Neither option modifies OSF framework files or requires an additional companion mod.
Preferences are separate between the two backends; changing installer choice does not convert them.

## Features

- Four larger lifetime readings per page, maximum 1–5 pages, default 2.
- Seven lifetime categories: hidden, all, random selection, or a specific counter.
- Random each load selects from enabled lifetime counters. Missing readings are omitted.
- Name, level, XP and an optional local PC clock. No Credits, Last location, health, mass or actor-stat controls.
- Original / Orbiting Star / hidden choices for character badge and loading indicator.
- Game images, orbital chart, artifact starfield and grav-jump tunnel backgrounds.
- Dark backing for game-image readability; compact initial loading layout without an empty stat area.
- A/D and D-pad navigation. Short transitions have only the chosen indicator.
- 67 supported lifetime counters; previous runtime logs found 66. Capture is once per loaded save after three seconds.
  Allow five seconds of gameplay, then trigger another full load. No menu visits needed to collect counters.

## Removed

Confirmation is removed completely: no wait option, review screen, preview action or direct OSF UI dependency.
Loading ends automatically. OSF UI can remain installed for other mods; Transit Report does not alter it.

## Testing limits

Native and all edited UI scripts compile. Installer/schema/choice mapping and UI event-routing checks pass.
The new standalone Gameplay Options controls, save persistence, root-menu native binding and compatibility
still need in-game confirmation. Consult LSCNativeBridge.log for the selected backend and settings bridge binding.
The internal DLL and OSF preference IDs remain unchanged for update compatibility; the visible product is Transit Report.
The repeated FaceCustomizationRenderPass crash also occurred with Transit Report disabled, as reported by the tester;
it is being investigated separately and this build does not claim to repair that engine-renderer failure.

## Installer-only configuration

Choose **Neither — configure in installer** to pick all 17 settings in the FOMOD. This installs no OSF schema and no Gameplay Options menu patches. Each selected setting is stored under Data/SFSE/Plugins/TransitReport/Installer/. Previous OSF and Gameplay preferences are ignored in this mode. Reinstall with Replace to change settings or switch backends. Defaults match the tester screenshot.
