# Version 1.1.6 validation record

Version 1.1.6 contains the fix tested in-game in the 1.1.5 Save Menu Stability Test. The fix restores save details, location tips and the initial-load fallback by registering the listeners after the main menu opens. The user reported that the build appeared to work. The OSF Settings test log confirms registration of all five listeners, capture of all five save fields from a manually selected save, a transition from minimal to full loading mode, and arrival in gameplay. The log does not establish coverage of Continue, cancel-and-reselect, or the other settings backends.

# Version 1.1.5 validation record

The user confirmed that the 1.1.5 initial-load black-screen fix worked in-game. If the issue recurs, check the `TR initial load` entries in `LSCNativeBridge.log` and note whether music played and gameplay started.

Three November 24 crash logs place the 1.1.4 bridge on the stack during main-menu save listener registration. Two other logs show Scaleform crashes without a Transit Report frame. The same registration code is present in 1.1.5. A separate crash isolation build uses `diagnostic_no_save_selection` to skip that code path. Initial save details, location tips and the initial-save fallback depend on the listeners and are unavailable in that build.

On November 25, the user reported no crashes with the isolation build. The native log confirms that OSF Settings and the isolation build were active, the save reached gameplay, and lifetime stats were collected. This supports main-menu listener registration as the suspected cause of the three crashes that included Transit Report. The other two crashes remain unattributed.

# Version 1.1.4 validation record

Verify that **Initial save stats** shows and hides the save details on a full initial load without changing contextual tips. Verify that **Loading music** starts only on full loading screens when enabled and stops when the screen closes. Check both settings from OSF Settings, Gameplay Options and the installer-only setup. On a fresh install, verify that music plays, zero-value counters are hidden, and the badge and background use the same randomly selected faction. In-game verification is pending.

# Version 1.1.2 validation record

Save-selection capture test. Earlier 1.1 tests failed to display metadata. Log confirmed the main menu had been destroyed. Capture now uses selection events. In-game verification pending.

# Version 1.1 validation record

Save details Test 2, 2026-11-20. The first test showed no added details in-game. Capture timing and script-object lookup were revised. In-game verification pending for Continue and manually selected older saves. Version 1.0 validation below is historical.

# Version 1.0 validation record

Current version: **1.0**, built at the user's request on 2026-11-10. Source branch: **test/gameplay-panel-bridge**. Packaging does not publish, tag or merge the repository.

## Evidence recorded

- On 2026-11-10, the user tested the new 1.0 features in-game and reported that all worked.

- The user confirmed the OSF installation works.
- Gameplay Panel Bridge Test 1 could save/apply settings, but immediate Esc after loading produced repeated crashes, including on another character/save. It is superseded and must not be the release candidate.
- Test 2 removed native creation-time panel lookup/refresh calls, queues the connection, and refreshes from the panel's own frame event after readiness.
- The user reported Test 2 seemed fine with no crashes. The successful repeat is runtime evidence, not proof of long-term stability.
- The user previously verified Custom animated GIF badge playback and reported the post-load freeze resolved.
- Native/UI builds and automated settings, installer, random-stat, zero-filter, artwork and package checks passed on the current test code.

## Remaining hands-on validation

- [ ] Confirm main-menu and pause-menu Gameplay settings both work after a cold start.
- [ ] Confirm settings survive fully exiting and restarting with each chosen backend, especially Gameplay and installer-only.
- [ ] Repeat immediate-Esc and delayed-Esc tests after full loads on both characters; review any new logs.
- [ ] Check all seven coin glints, sizes, short-transition exclusivity, Custom pools and animated GIFs.
- [ ] Verify the untitled OSF dividers, Lifetime stats On/Off, hide-zero and 1-5-page navigation with keyboard/controller.
- [ ] Review compatibility with the user's other settings-panel mods.
- [x] User approved version 1.0 metadata and release packaging.
- [x] User tested the newly added 1.0 features in-game and reported all worked.
- [ ] Reconcile/tag/publish the repository when requested.

## Limits and unresolved history

The older FaceCustomization renderer crash was also reproduced with Transit Report disabled; its cause remains unresolved. Do not claim this work fixed it. No native runtime other than Starfield 1.16.244.0 is supported. Detailed panel-bridge evidence is retained in docs/PANEL_BRIDGE_TEST.md; old documentation is retained under docs/history and the staging Archive folder.
