# Transit Report — Changelog

## 0.9.5
- Add Neither / installer-only backend with all 17 FOMOD settings; no OSF entry or Gameplay menu patches. — 0.9.5
- Adopt Transit Report as product name; Nexus title Transit Report - Loading Screen Customization.
- Reintroduce FOMOD with exactly one settings backend: OSF Settings or standalone Gameplay Options.
- Add standalone native preference persistence and Gameplay list integration; keep native game option events separate.
- Remove confirmation setting, review screen, native review callbacks and direct OSF UI dependency.
- Keep four-stat pages, compact initial layout, lifetime-only selection, backgrounds and controller navigation.
- Use space-separated ZIP names and Transit Report installer metadata for MO2.
- Preserve OSF IDs and DLL filename for compatibility. Standalone preference store is separate.
- Standalone integration still needs runtime compatibility and persistence tests.


- Matched both menus defaults to the tester screenshot: hidden indicator, Orbital Chart, 12-hour clock and Random Each Load; two pages and all lifetime categories enabled.

## 0.9.4 — Test build 02
- Limit every category/random/review page to four counters instead of six.
- Enlarge stat labels and values; allow long labels to wrap at a slightly smaller size.
- Compact the initial loading layout when lifetime data is unavailable. Fit the game-image backing to visible character information and clock instead of reserving empty stat space.
- Preserve cached review data across saved-game resets, so the confirmation request is not skipped with an empty payload.
- Add a replacement no-gameplay-reads diagnostic package for crash isolation.
- Reserve 1.0 for the first Nexus/GitHub release; use numbered test builds for further iterations.

## 0.9.4 — Lifetime-only cleanup and staging repair
- Remove Credits, Last location, Health and carried mass/capacity from settings, displays and random pool.
- Remove technical actor readings; stop inventory, location, actor-value and position collection.
- Keep only lifetime counters in the ribbon; remove the empty STATUS heading and divider.
- Rename Included sample to Orbiting Star for the badge and indicator.
- Remove the separate background-preview action. Do not ship OSF menu modifications or an extra preview mod.
- Improve confirmation-mode transition registration and diagnostics. Automatic remains default.
- Restore the desktop staging workflow, current README, checklist, source kit and changelog.

## 0.9.3 — Review experiment and image readability
- Add a dark panel behind information when game-image backgrounds are selected.
- Remove the experimental suffix from Credits and Last location labels.
- Add an optional private OSF UI paused review after full loading; A/Enter continues, B/Escape exits.
- Add a separate background-preview action (subsequently removed in 0.9.4).
- Move current-stat controls next to lifetime categories and mix them into random selection (reverted in 0.9.4).
- Browser checks passed; actual post-load handoff unverified. Preview pause confirmed in runtime logs.

## 0.9.1 — Page limit and stat trimming
- Add maximum 1–5 stat pages, default 2.
- Remove oxygen, CO2, resistances, star power, percentages and derived capacity readings.

## 0.9.0 — Lower ribbon
- Implement the user's selected six-column ribbon layout beneath character information.

## 0.8.9a — Sampler serialization safeguard
- Prevent overlapping gameplay/counter captures and concurrent snapshot resets.
- Crash investigation remains inconclusive; FaceCustomization rendering was on the crash stack.

## 0.8.9 — Expanded lifetime selection
- Support 67 lifetime counters across seven categories; test log found 66.
- Category dropdowns offer hidden/all/random/specific-stat choices; add random each load.

## 0.8.8b — Initial loading display
- Hide unavailable snapshot readings on the initial save load.

## 0.8.8a — Counter timing and visibility
- Shorten capture delay to three seconds; show diagnostic waiting state instead of hiding the counter page.

## 0.8.8 — Single-counter test and compact OSF controls
- Try one People Killed capture per loaded save, initially with a 15-second delay.
- Replace many individual settings with compact category controls.
- User subsequently confirmed People Killed worked.

## 0.8.7a — Cosmic overlay line fix
- Clear inherited outlines before drawing the lower gradient and central glow.

## 0.8.7 — Cosmic backgrounds
- Add artifact-inspired starfield and grav-jump tunnel background choices.

## 0.8.6 — Full-screen statistics
- Remove information cards from short transitions.
- Add derived Condition & Capacity readings (subsequently removed).

## 0.8.5 — Controller navigation
- Add XInput D-pad left/right. User confirmed it worked.

## 0.8.4 — Native keyboard navigation
- Replace unsuccessful UI key events with native A/D polling. User confirmed it worked.

## 0.8.3 — Isolated visual test
- Animate the orbital background and introduce clearly marked sample pages.
- User confirmed animation; UI-only A/D events did not work.

## 0.8.2 — Failed transfer workaround
- Replace the native lifetime array transport with scalar fields; post-load failure persisted.

## 0.8.1 recovery
- Restore the earlier native bridge and UI after the post-load hangs.

## 0.8.0 and earlier
- Earlier staged test builds cover original/custom badge and indicator choices, credit/location snapshots,
  OSF Settings migration, character stats and the orbital visual theme.
- The 0.8.0 automatic-stat test reported hangs and is not a recommended install.
