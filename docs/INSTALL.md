# Installing Transit Report

Version 1.0. Install Transit Report 1.0.zip. The staging START HERE.txt identifies the current installer and source archives.

## Install or update

1. Install Starfield 1.16.244.0, matching SFSE and Address Library for SFSE Plugins.
2. For the OSF Settings method, install OSF Settings and its stated requirements.
3. Install the complete Transit Report ZIP through a FOMOD-capable mod manager. Disable older Transit Report versions and artwork-test overlays.
4. Choose one configuration method below. Use **Replace** when updating or switching methods so files belonging to the previous method are removed.
5. Fully restart Starfield and launch through SFSE.

## Choose a settings method

- **OSF Settings:** open OSF Settings, then Transit Report. Its groups have untitled dividers.
- **Gameplay Options:** open Settings > Gameplay Options > TRANSIT REPORT, from the main menu or pause menu. This method needs no OSF integration. It installs three settings-panel replacements: mainmenu_settingspanel.swf, settingspanel.swf and settingspanel_lrg.swf. Other settings-panel replacements may conflict.
- **Neither - configure in installer:** choose all 13 controls during installation. No in-game settings entry. Reinstall with Replace to change the choices; older menu preferences are ignored by this method.

The package does not include mainmenu.swf, pausemenu.swf or pausemenu_lrg.swf. OSF Settings and installer-only do not install settings-panel replacements. All methods include loadingmenu.swf and fadermenu.swf.

## Defaults and using the loading screen

Defaults: Individual theme selections, Orbiting Star badge, Hidden indicator, Orbital Chart background, Normal (100%) badge and indicator sizes, character/progress/tips/lifetime stats On, 12-hour clock, two stat pages, and Hide zero-value stats Off. Saved preferences can retain your previous selections.

Normal (100%) uses the enlarged baseline, equal to the earlier 150% size. Sizes range from 50% to 150% in 25% steps.

Enabled lifetime stats are automatically randomized from the available pool of 67 counters. Change pages with A/D or controller D-pad left/right. Hide zero-value stats filters zeros before pages are selected. Short transitions show the indicator only. Initial save loading omits stats that have not been captured yet; no Status-menu visit is required.

Choose a faction and set the desired badge, indicator and/or background to **Theme** to use it. Other choices, including Hidden, Original and Custom, remain independent. Random Each Load uses one matching faction for all Theme slots on that loading screen.

## Add your own artwork

1. Launch the game once to create the Artwork folders.
2. Place PNG, JPG, JPEG or GIF files in Documents/My Games/Starfield/Transit Report/Artwork/Badges, Indicators or Backgrounds.
3. Select **Custom** for the corresponding artwork slot in your chosen settings method.
4. Fully restart Starfield after adding, removing or replacing images.

Any filenames work; each folder accepts up to 64 images. Valid images are randomly selected each loading screen, avoiding immediate repeats when alternatives exist in the current session. Transparent PNG is suitable for badges/indicators. Animated GIF badges and indicators play their own animation; still indicators rotate. APNG animation is not supported.

No separate importer or converter is required. Generated cache files go to Data/Interface/TransitReport/Cache, which MO2 may redirect to Overwrite. Keep original images in Documents. Invalid images are skipped; an empty valid pool uses Orbiting Star for badge/indicator or Orbital Chart for background.

Still images: 64 MB per file, up to 16 megapixels; output is reduced to at most 2560px on its longest side. Animated GIFs: up to 240 frames, 60 seconds, 2048px canvas and 16 megapixels across decoded frames. Runtime animation is resized to at most 512px and quantized to 30fps.

## Troubleshooting and uninstalling

- Missing Gameplay controls: confirm the Gameplay Options method is installed, check which mod wins settings-panel conflicts, restart, and inspect Documents/My Games/Starfield/SFSE/Logs/LSCNativeBridge.log.
- Old settings or artwork choices: confirm only one Transit Report copy is enabled, replace the old installation, and restart. Do not delete your personal artwork to reset a menu preference.
- For a crash report, include the chosen settings method, game version, reproduction steps and relevant SFSE/crash logs.
- Disable/remove Transit Report to uninstall. No ESM/ESP is installed. Personal images and settings in Documents remain; generated cache files can be removed separately.

Artwork choice order ends with **Theme, Hidden, Custom** for badge, indicator and background. Hidden background uses plain black while preserving enabled information.
