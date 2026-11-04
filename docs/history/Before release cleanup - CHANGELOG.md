# Transit Report â€” Changelog

## 0.9.7 - Performance and indicator follow-up

- Removed repeated memory preflights from protected stat reads; user logs show capture work reduced from 2413 ms to approximately 0.16 ms.
- Retained incremental capture, bounds checks, fault protection and timing measurements.
- Added post-timeline artwork visibility enforcement to address doubled Custom indicators on short transitions; in-game confirmation pending.
- Custom appears last in artwork selectors. Removed testing controls and moved Local PC time into Full loading screen.
- Corrected OSF readiness to match the 16 shipped settings.
- Includes the 0.9.6 Custom folders and animated presets. Existing setting identifiers and values remain compatible.


## 0.9.6 â€” Custom artwork
- Randomly select a personal Custom image for each load from up to 64 files per folder; prepare changed files at startup and reuse content-addressed caches. Invalid files are skipped without rejecting the valid images.
- Add dedicated animated Transit Emblem badge/indicator and Orbital Horizon wallpaper selections. Custom remains reserved for personal Documents images.
- Add Custom choices for badge, wallpaper and indicator to OSF Settings, Gameplay Options and installer-only configuration.
- Read PNG/JPG/JPEG images with any filenames from each Documents/My Games/Starfield/Transit Report/Artwork folder.
- Automatically decode images, preserve PNG transparency and generate game-compatible cached assets at startup.
- Detect changed image contents, ignore text files and clear stale generated caches for removed or invalid inputs.
- Fit images without stretching, rotate custom indicators, and retain a dark wallpaper readability gradient.
- Keep existing selections/defaults; remove test banners and forced custom mode. No private test artwork is included.
- Native and UI compilation plus automated checks pass; the final merged build needs in-game verification in each settings backend.


## 0.9.5a â€” Vortex installer fix
- Fix the FOMOD failing to start in Vortex (`Xml_InvalidCharacter, 1, 39`). The generated ModuleConfig.xml now uses a double-quoted XML declaration, which Vortex's installer requires.
- Save info.xml and documentation as valid UTF-8.
- No changes to the plugin or interface files; settings are unaffected.

## 0.9.5 â€” First public release
- Add Neither / installer-only backend with all 17 FOMOD settings; no OSF entry or Gameplay menu patches.
- Adopt Transit Report as product name; Nexus title Transit Report - Loading Screen Customization.
- Reintroduce FOMOD with exactly one settings backend: OSF Settings or standalone Gameplay Options.
- Add standalone native preference persistence and Gameplay list integration; keep native game option events separate.
- Remove confirmation setting, review screen, native review callbacks and direct OSF UI dependency.
- Keep four-stat pages, compact initial layout, lifetime-only selection, backgrounds and controller navigation.
- Use space-separated ZIP names and Transit Report installer metadata for MO2.
- Preserve OSF IDs and DLL filename for compatibility. Standalone preference store is separate.
- Standalone integration still needs runtime compatibility and persistence tests.
- Match default settings across all methods: hidden indicator, Orbital Chart, 12-hour clock and Random Each Load; two pages and all lifetime categories enabled.

## 0.9.4 â€” Test build 02
- Limit every category/random/review page to four counters instead of six.
- Enlarge stat labels and values; allow long labels to wrap at a slightly smaller size.
- Compact the initial loading layout when lifetime data is unavailable. Fit the game-image backing to visible character information and clock instead of reserving empty stat space.
- Preserve cached review data across saved-game resets, so the confirmation request is not skipped with an empty payload.
- Add a replacement no-gameplay-reads diagnostic package for crash isolation.
- Reserve 1.0 for the first Nexus/GitHub release; use numbered test builds for further iterations.

## 0.9.4 â€” Lifetime-only cleanup and staging repair
- Remove Credits, Last location, Health and carried mass/capacity from settings, displays and random pool.
- Remove technical actor readings; stop inventory, location, actor-value and position collection.
- Keep only lifetime counters in the ribbon; remove the empty STATUS heading and divider.
- Rename Included sample to Orbiting Star for the badge and indicator.
- Remove the separate background-preview action. Do not ship OSF menu modifications or an extra preview mod.
- Improve confirmation-mode transition registration and diagnostics. Automatic remains default.
- Restore the desktop staging workflow, current README, checklist, source kit and changelog.

## 0.9.3 â€” Review experiment and image readability
- Add a dark panel behind information when game-image backgrounds are selected.
- Remove the experimental suffix from Credits and Last location labels.
- Add an optional private OSF UI paused review after full loading; A/Enter continues, B/Escape exits.
- Add a separate background-preview action (subsequently removed in 0.9.4).
- Move current-stat controls next to lifetime categories and mix them into random selection (reverted in 0.9.4).
- Browser checks passed; actual post-load handoff unverified. Preview pause confirmed in runtime logs.

## 0.9.1 â€” Page limit and stat trimming
- Add maximum 1â€“5 stat pages, default 2.
- Remove oxygen, CO2, resistances, star power, percentages and derived capacity readings.

## 0.9.0 â€” Lower ribbon
- Implement the user's selected six-column ribbon layout beneath character information.

## 0.8.9a â€” Sampler serialization safeguard
- Prevent overlapping gameplay/counter captures and concurrent snapshot resets.
- Crash investigation remains inconclusive; FaceCustomization rendering was on the crash stack.

## 0.8.9 â€” Expanded lifetime selection
- Support 67 lifetime counters across seven categories; test log found 66.
- Category dropdowns offer hidden/all/random/specific-stat choices; add random each load.

## 0.8.8b â€” Initial loading display
- Hide unavailable snapshot readings on the initial save load.

## 0.8.8a â€” Counter timing and visibility
- Shorten capture delay to three seconds; show diagnostic waiting state instead of hiding the counter page.

## 0.8.8 â€” Single-counter test and compact OSF controls
- Try one People Killed capture per loaded save, initially with a 15-second delay.
- Replace many individual settings with compact category controls.
- User subsequently confirmed People Killed worked.

## 0.8.7a â€” Cosmic overlay line fix
- Clear inherited outlines before drawing the lower gradient and central glow.

## 0.8.7 â€” Cosmic backgrounds
- Add artifact-inspired starfield and grav-jump tunnel background choices.

## 0.8.6 â€” Full-screen statistics
- Remove information cards from short transitions.
- Add derived Condition & Capacity readings (subsequently removed).

## 0.8.5 â€” Controller navigation
- Add XInput D-pad left/right. User confirmed it worked.

## 0.8.4 â€” Native keyboard navigation
- Replace unsuccessful UI key events with native A/D polling. User confirmed it worked.

## 0.8.3 â€” Isolated visual test
- Animate the orbital background and introduce clearly marked sample pages.
- User confirmed animation; UI-only A/D events did not work.

## 0.8.2 â€” Failed transfer workaround
- Replace the native lifetime array transport with scalar fields; post-load failure persisted.

## 0.8.1 recovery
- Restore the earlier native bridge and UI after the post-load hangs.

## 0.8.0 and earlier
- Earlier staged test builds cover original/custom badge and indicator choices, credit/location snapshots,
  OSF Settings migration, character stats and the orbital visual theme.
- The 0.8.0 automatic-stat test reported hangs and is not a recommended install.


0.9.6 test follow-up: user confirmed the previous test checklist passed except custom indicator overlap. Custom now appears last in each artwork selector; testing controls removed; Local PC time moved to Full loading screen. Custom indicator suppresses fallback artwork during subsequent refreshes. This follow-up needs an in-game overlap recheck.


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
