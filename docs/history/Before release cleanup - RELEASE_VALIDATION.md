# 0.9.7 validation

Native JPG/PNG cache preparation and alpha-preserving assets were verified in earlier in-game overlays. The tester also verified the custom indicator on a short transition. Those tests used fixed filenames and forced test selections.

Automated checks cover Documents folder creation, arbitrary filenames/case, PNG alpha pixels, JPG decode, cached content reuse, changed-content refresh with old timestamps, multiple/invalid/missing input fallback and output size limits. Settings checks cover Gameplay mapping and all three FOMOD backend layouts; OSF Custom values must agree with the native catalog.

Native/UI compilation and final archive checks are recorded with the staged build. The final merged 0.9.6 build, natural mode switching, Documents folder behavior under the game/MO2 and all three settings backends still need the in-game checklist. No claim of complete runtime verification is made.

Original named animated designs added: badge, indicator and wallpaper each have 180 script-free timeline frames at 30 fps. Selected frames were rendered with JPEXS and inspected for motion and correct transparency. Cache-first/bundled-default fallback and the new loops still need final in-game verification.

Named-preset revision: Transit Emblem and Orbital Horizon are independent selections in all three backends. Automated loader checks cover Custom versus built-in paths, all three slots and stale asynchronous callbacks. Final in-game option-switching verification remains pending.

Random-pool revision: native checks passed with ten wallpaper images, unchanged-cache reuse, invalid-image skipping, arbitrary filenames and stale-cache pruning. Menu tests passed for one random pick per load, empty pools, separate named preset paths and stale-event guards. The final random pool behavior still needs in-game testing.


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
