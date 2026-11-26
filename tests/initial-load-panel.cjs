const assert = require('node:assert/strict');
const fs = require('node:fs');

const source = fs.readFileSync('src/loading/LoadingMenu.as', 'utf8');
const body = source.match(/private function LSCEnsureInitialSavePanel[^\n]*\s*\{([\s\S]*?)\n      \}/)[1];
const ensurePanel = new Function('snapshot', body);
const mainMenuLoad = { initialSaveLoad: true, loadingMenuOpen: true };
const shortPanel = {
  InMinimalMode: true,
  LSCShortMode: true,
  LeftText_mc: { visible: false },
  BlackRect_mc: { visible: false },
};

ensurePanel.call(shortPanel, { ...mainMenuLoad, initialSaveLoad: false });
ensurePanel.call(shortPanel, { ...mainMenuLoad, loadingMenuOpen: false });
assert.equal(shortPanel.LeftText_mc.visible, false, 'Other transitions keep their short layout');

ensurePanel.call(shortPanel, mainMenuLoad);
assert.equal(shortPanel.InMinimalMode, false);
assert.equal(shortPanel.LSCShortMode, false);
assert.equal(shortPanel.LeftText_mc.visible, true);
assert.equal(shortPanel.BlackRect_mc.visible, true);
assert.equal(shortPanel.LSCNeedsStatsPost, true, 'Report the new panel state to the native bridge');

shortPanel.LSCNeedsStatsPost = false;
ensurePanel.call(shortPanel, mainMenuLoad);
assert.equal(shortPanel.LSCNeedsStatsPost, false, 'Polling must not repeatedly report the same panel state');
assert.equal(shortPanel.LSCInitialSaveLoad, true, 'Subsequent data events keep the initial load in full mode');

const noDataPanel = {
  InMinimalMode: false,
  LSCShortMode: false,
  LeftText_mc: { visible: false },
  BlackRect_mc: { visible: false },
};
ensurePanel.call(noDataPanel, mainMenuLoad);
assert.equal(noDataPanel.LeftText_mc.visible, true, 'A main-menu save load can open before client data arrives');

console.log('Passed: initial save fallback only opens on a main-menu save load and reports its new state once.');

const bridge = fs.readFileSync('native/src/main.cpp', 'utf8');
const creation = bridge.slice(bridge.indexOf('void OnMenuCreated('), bridge.indexOf('class LoadSink'));
const opening = bridge.slice(bridge.indexOf('class MainMenuSaveListenerSink'), bridge.indexOf('class ReadSnapshot'));
assert(!creation.includes('BindSaveSelection('), 'Movie construction must never invoke main-menu listener registration');
assert.match(opening, /event\.opening\s*&&\s*event\.menuName\s*==\s*"MainMenu"/);
assert.match(opening, /ui->GetMenu\(event\.menuName\)/);
assert.match(opening, /!g_saveListenersBound\.exchange\(true\)/);
assert.match(opening, /BindSaveSelection\(\*menu\)/);
assert.match(bridge, /ui->RegisterSink\(&g_mainMenuSaveListenerSink\)/);
console.log('Passed: registration uses the live main menu on opening and runs once per movie.');
