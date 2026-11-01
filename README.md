# Transit Report

Loading screen customization for Starfield. Current WIP version: **0.9.5**. Version **1.0** is reserved for the first public Nexus and GitHub release.

## Features

- Four larger lifetime statistics per page, with one to five pages.
- Category selection or randomized counters on each load.
- A/D and controller D-pad page navigation.
- Animated Orbital Chart, Artifact Starfield and Grav-jump backgrounds, or game images.
- Badge and indicator selection, local PC clock and loading tips.
- FOMOD choice of OSF Settings, standalone Gameplay Options or installer-only configuration.

## Requirements and install

Starfield **1.16.244.0**, matching SFSE and Address Library for SFSE Plugins. The OSF option additionally requires OSF Settings and its requirements. The standalone option does not require OSF Settings or OSF UI.

Install the release ZIP in MO2, choose one backend and name the mod Transit Report. Use Replace when changing backend. Disable previous Loading / Loading Screen Configurator installations. Gameplay Options replaces six game menu files and can conflict with other menu replacers. OSF integration does not replace framework menus.

Defaults match the tester screenshot: Orbiting Star badge, hidden indicator, Orbital Chart, character/progress/tips enabled, two pages, diagnostics off, 12-hour clock, Random Each Load and All Stats in every category. Saved preferences are preserved.

See [installation details](docs/INSTALL.md), [build instructions](docs/BUILD.md), [changelog](CHANGELOG.md), [validation](RELEASE_VALIDATION.md) and [third-party notices](THIRD_PARTY_NOTICES.md).

## Source layout

- `native/`: SFSE plugin and vendored CommonLibSF dependencies.
- `src/`: loading screen and Gameplay Options ActionScript, OSF schema and settings catalog.
- `assets/templates/`: SWF templates needed to preserve game symbols and layout during compilation.
- `scripts/`: portable UI build and FOMOD packaging helpers.
- `tests/`: settings mapping checks.
- `installer/`: FOMOD definitions.
- `docs/`: install, build, statistics and license documentation.

## Testing status

Native and edited UI scripts compile; settings mapping and package checks pass. Standalone Gameplay Options persistence and compatibility require in-game verification. Short transitions intentionally show no statistics. Confirmation is removed. Counters are captured once after entering a save; initial loading omits missing readings.

## License

Authored code is GPL-3.0-or-later with the included linking/modding exceptions. Third-party libraries and game-derived UI templates retain their respective terms; see THIRD_PARTY_NOTICES.md. No game executable, save, personal configuration or build cache is included.

Installer-only backend: select **Neither — configure in installer** for all 17 FOMOD choices with no OSF schema or Gameplay menu patches. Values come from Data/SFSE/Plugins/TransitReport/Installer/*.ini; saved menu preferences are ignored. Reinstall with Replace to change options.
