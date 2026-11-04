# Transit Report 0.9.6 installation

Install Transit Report 0.9.6.zip with MO2/Vortex. Disable ALL earlier artwork-test overlays before installing this complete package. Replace the old Transit Report installation rather than merging it, especially when switching backends.

Select exactly one settings method:
- OSF Settings: choose Transit Report in OSF Settings. Requires OSF Settings and its requirements.
- Gameplay Options: use Settings > Gameplay Options > TRANSIT REPORT. Replaces six menu files and may conflict with other menu replacers.
- Neither — configure in installer: choose all settings on the conditional FOMOD pages. Adds no in-game settings entry. Reinstall with Replace to change choices.

All three methods offer Custom for Character badge, Loading indicator and Loading background. Add one or more PNG/JPG/JPEG images of any filenames to the matching folder under Documents/My Games/Starfield/Transit Report/Artwork: Badges, Indicators or Backgrounds. The game creates these folders on startup. Select Custom and restart Starfield after changing an image. PNG transparency is supported; indicators rotate; badges remain still. Animated GIF/APNG import is not included.

No converter or separate application is required. The plugin generates cache SWFs under Data/Interface/TransitReport/Cache. MO2 may put these in Overwrite. Do not put source images in Cache. Keep custom images in Documents when updating/uninstalling the mod.

Empty or invalid-image folders use Orbiting Star for badge/indicator and Orbital Chart for wallpaper. Custom selects randomly from valid images; random choices may repeat. Images are limited to 16 megapixels / 64 MB; the longest output side is at most 2560 pixels.

Existing defaults are preserved: Orbiting Star badge, hidden indicator, Orbital Chart, two pages, 12-hour clock, Random Each Load and all categories enabled. No settings-menu framework files are overridden.

Requirements: Starfield 1.16.244.0, matching SFSE and Address Library. OSF Settings is required only for its integration option. Launch through SFSE.

Disable Transit Report to uninstall. Personal Documents artwork/settings remain. Generated cache files may be removed separately. No save plugin or ESM is installed.

## Included animated designs

Select **Transit Emblem** for the included animated badge or indicator, and **Orbital Horizon** for the included animated planet wallpaper. These are dedicated built-in selections, independent of personal image files. **Custom** uses only your Documents images. Existing Orbiting Star and procedural background choices remain unchanged.

User PNG/JPG images remain still (the UI rotates a user indicator). GIF/APNG decoding is not included. No former collection test logo is part of the release.

## Random Custom images

Put up to 64 PNG/JPG/JPEG images of any names in each Artwork folder. Custom chooses one valid image per loading screen and keeps it steady for that screen. Named built-in designs are separate selections and ignore personal files. New/changed images are prepared at startup, while unchanged cached assets are reused. Invalid files are skipped; an empty valid pool falls back to Orbiting Star or Orbital Chart. Restart after adding/removing/changing files.
