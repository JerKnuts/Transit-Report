# Panel-only Gameplay Options test

Branch: `test/gameplay-panel-bridge`. Version remains 0.9.8. This experiment is not published or merged into main.

The native callback binds `TRConfig` to `SettingsPanel_mc` instead of the main-menu/pause-menu root. The panel owns the function slot and can refresh existing rows when binding occurs after settings data arrives. No menu references are retained and no polling or new UI hooks are introduced.

Gameplay installs only `mainmenu_settingspanel.swf`, `settingspanel.swf` and `settingspanel_lrg.swf`. Other settings-panel replacements may conflict.

Install the Panel Bridge Test ZIP with **Replace**, choosing **Gameplay Options**. Fully restart Starfield. Verify that the installed Transit Report mod no longer contains `mainmenu.swf`, `pausemenu.swf` or `pausemenu_lrg.swf`.

1. Before loading a save, open Settings > Gameplay Options. Confirm Transit Report appears and vanilla options still work.
2. Change the badge size and clock format, then load a save and check the loading screen.
3. Open Gameplay Options from the pause menu. Confirm the same values, then change Lifetime stats and a background choice.
4. Trigger another full load and a short transition. Confirm settings and controller navigation.
5. Exit Starfield completely, relaunch, and check both settings entry points for persistence.
6. If available, check the large-interface setting and reopen Gameplay Options.

Native logs report `panel-only Gameplay bridge bound` on success. A missing-panel warning means the settings panel was unavailable at the creation callback or a conflicting panel is active. Record whether options were missing from the main menu or pause menu. Do not interpret compilation as proof of runtime binding or stability.

OSF Settings and installer-only remain available in the FOMOD. The previous Polish Test archive remains the fallback.

## Runtime report: November 9-10, 2026

The user reported one crash after loading a save and pressing Esc. Crash log `2026-11-09-23-53-02.log` contains Scaleform frames followed by LSCNativeBridge.dll offsets 0x156C2, 0x16546 and 0x1C162, under the SFSE menu-creation callback. This implicates the test binding path but does not isolate whether member lookup, assignment, or immediate row refresh triggered it.

After restarting, the user repeated the test successfully, changed settings, and confirmed their effect during loading. Functional operation is confirmed for that repeat; intermittent stability is not established. A later runtime log also reported the MainMenu panel unavailable at binding time. Do not merge or call the first crash fixed based on the successful repeat. The delivered test ZIP has not been changed during investigation.

## Test 2: deferred connection

The immediate-Esc repeat on another character produced the same Starfield+3337690 and LSC offsets as the first crash (`2026-11-10-00-14-55.log`). An intervening crash (`2026-11-10-00-10-51.log`) occurred in Scaleform advancement without LSC in the probable stack; this does not establish an OSF UI fault.

Test 2 removes nested GetMember lookups and all native Invoke calls from the menu-creation connection. It assigns TRConfig through Scaleform's permanent queued variable mechanism at the menu root's SettingsPanel_mc path. If the clip is unavailable, Scaleform can retain the assignment until creation. The visible panel refreshes its rows from ENTER_FRAME once the connection and engine settings data exist, then unregisters that listener. No native polling, retained menu pointers or new game/UI hooks are added.

Reference: https://help.autodesk.com/cloudhelp/ENU/Scaleform-Help/cpp_ref/01109.html

Install **Transit Report 0.9.8 Panel Bridge Test 2.zip** with Replace, choose Gameplay Options and fully restart. Compare immediate Esc and delayed Esc after entering a save on both characters. Also test main-menu settings, pause-menu settings, controller navigation and persistence. Logs distinguish deferred bridge assigned/queued; queued is not proof of successful runtime binding. This is a targeted fix attempt, not a verified crash fix.
