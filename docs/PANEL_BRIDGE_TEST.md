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
