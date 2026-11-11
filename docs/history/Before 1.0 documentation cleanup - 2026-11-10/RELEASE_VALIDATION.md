# 0.9.8 release validation

## Completed

- Native plugin and eight UI files built successfully after the seven-theme integration.
- Theme paths, settings mappings and three FOMOD backends passed automated checks.
- All seven faction coins contain filtered 192px textures and 90 frames at 30fps.
- All faction wallpapers are packaged as static artwork.
- User confirmed Crimson Fleet texture filtering improved in-game appearance.
- User approved the faster tilt/glint comparison and all faction artwork.

## Final in-game verification required

- Install the current complete archive with Replace and test each settings backend.
- Check all seven themes on full loading screens and indicators on short transitions.
- Verify the latest three-second animation, glint, readability and lack of overlapping indicators.
- Check keyboard/controller stat navigation, Custom pools, initial save load and post-load performance.

Compilation and automated checks do not establish in-game stability. The earlier FaceCustomization crash also occurred with Transit Report disabled; its root cause remains unresolved.

No new version bump, GitHub push or Nexus upload is part of this staging cleanup.


0.9.7: Each artwork selector now includes Theme. Only slots set to Theme use the chosen faction. Original, Hidden, built-in and Custom choices work independently with any faction selected. Existing saved slot values are respected; select Theme explicitly to use faction artwork. Theme with no faction selected falls back to Orbiting Star/Orbital Chart. Runtime verification pending.

GIF test build: native decoder tested against independent Pillow composition for disposal modes 1/2/3, optimized rectangles, transparency and variable timing; static-image/cache tests pass. User verified custom animated badge playback in-game. Microsoft WIC metadata reference: https://learn.microsoft.com/en-us/windows/win32/wic/-wic-native-image-format-metadata-queries

0.9.8: user confirmed the Neon Comet Reactor GIF works as a Custom badge. Automated disposal/transparency/timing, cache and static importer regression checks passed. This does not establish all GIF files or all runtime scenarios are verified.


Local 0.9.8 update: Theme now offers Random Each Load. It picks one of the seven faction themes per loading screen and holds that choice throughout the load. Slots set to Theme share the selection; other artwork options remain independent. Immediate repeats are avoided when alternatives exist. In-game verification pending.


Local polish test: independent badge/indicator sizes (50%, 75%, 100%, 125%, 150%); no immediate random theme or Custom artwork repeats when alternatives exist (session-wide); optional hide-zero lifetime stats. Default size is Normal (100%), equal to the previous 150% and hide-zero is Off. In-game clearance and behavior testing pending.

Coin glint update: tilt frames now preserve the nested glint animation, with a brighter moving highlight on all seven faction coins. Both badge and indicator use the corrected asset. In-game verification pending.

Simplified lifetime settings: all three methods expose only Hide zero-value stats for lifetime selection. Random selection always uses the full available counter pool; old category/mode preferences are ignored. Page count remains configurable. Native and UI builds and random/zero/page checks pass; runtime test pending.

Lifetime stats can be switched On or Off under Full loading screen (On by default). Enabled stats remain randomized; Hide zero-value stats and page count remain independent. Faction coin glints now use half the previous peak opacity and a slower six-second sweep with shorter travel; the three-second tilt is unchanged. In-game verification pending.

OSF schema uses distinct whitespace group names for untitled dividers. All setting keys are unchanged. Check divider appearance in-game with the installed OSF version; no framework overrides are shipped.

Panel-only Gameplay Options experiment (test/gameplay-panel-bridge): native settings binding moved to SettingsPanel_mc. The Gameplay option ships only mainmenu_settingspanel.swf, settingspanel.swf and settingspanel_lrg.swf. Mainmenu.swf, pausemenu.swf and pausemenu_lrg.swf are excluded. Install with Replace and fully restart. Test settings from both main and pause menus and check persistence. Panel availability at the menu-creation callback needs in-game verification; missing binding logs a warning and leaves vanilla options.

Panel Bridge Test 2: targeted immediate-Esc crash mitigation. Native creation-time panel lookups and row-refresh invocation removed; queued permanent assignment connects the panel, and its own visible-frame callback refreshes ready rows. Immediate/delayed Esc, initial main-menu binding and stability need in-game verification. Details: docs/PANEL_BRIDGE_TEST.md.
