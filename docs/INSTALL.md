# Installing Transit Report

Requires Starfield **1.16.244.0**, matching SFSE and Address Library for SFSE Plugins. No ESM and no image importer.

## Install

1. Install `Transit Report <version>.zip` with MO2 or Vortex. In MO2, name the mod **Transit Report**.
2. Choose one settings method in the FOMOD (below).
3. Launch through SFSE.

When updating or changing methods, use **Replace**, not Merge, so old menu, schema and choice files are removed. If you tested an earlier "Loading" / "Loading Screen Configurator" build, disable it; keep only one copy enabled.

## Settings methods

- **OSF Settings:** a Transit Report page in OSF Settings. Requires OSF Settings and its requirements. Installs no MainMenu, PauseMenu or SettingsPanel patches. Keeps the earlier internal settings ID, so existing OSF preferences carry over.
- **Gameplay Options (standalone):** a TRANSIT REPORT section in Settings > Gameplay Options, from both the main menu and the pause menu. Doesn't need OSF Settings or OSF UI. Preferences are saved to `Documents/My Games/Starfield/Transit Report/Settings.ini`, immediately on change; back out of settings to play. Replaces the MainMenu, PauseMenu and SettingsPanel SWFs (including large-interface variants), so check MO2 conflicts with other menu or UI overhauls.
- **Neither (configure in installer):** choose all 17 settings on the following FOMOD pages. Installs no OSF schema and no menu patches. Choices are written to `Data/SFSE/Plugins/TransitReport/Installer/`; reinstall with Replace to change them. Preferences saved by the other methods are ignored.

Preferences aren't shared between methods; switching doesn't convert them. None of the methods modifies OSF framework files.

## Defaults

Orbiting Star badge, hidden loading indicator, Orbital Chart background, character info, progress and tips on, two pages, diagnostics off, 12-hour clock, Random Each Load, and all seven categories set to All Stats. Existing saved preferences are kept on update.

## Using it

- Change pages during full loading screens with A/D or left/right on the D-pad.
- Stats are captured once, about three seconds after a save loads; no Status menu visit is needed. The first load of a session shows only character info, so allow a few seconds of gameplay before the next full load.
- Short transitions show only the selected loading indicator.

## Troubleshooting

`Documents/My Games/Starfield/SFSE/Logs/LSCNativeBridge.log` records the selected method and settings binding. Include it, your game version and your settings method in bug reports.
