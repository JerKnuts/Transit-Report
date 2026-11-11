# Building Transit Report

Use Windows x64, Visual Studio 2022 C++ tools, xmake 3+, Java, JPEXS FFDec 26.4.0, Python 3 and Node.js. Run commands from the repository root. These tools are for building/testing; users do not need them to import artwork.

1. Clear XSE_SF_MODS_PATH and XSE_SF_GAME_PATH to prevent automatic installation. Override LSC_COMMONLIBSF only deliberately; the normal build uses the vendored dependency.
2. Run `xmake f -P native -m release --diagnostic_no_gameplay_reads=n -y`, then `xmake -P native -j4 -y`.
3. Run `powershell -File scripts/build-ui.ps1 -Java java -FFDec C:/Tools/ffdec/ffdec.jar`. The current branch builds two loading-screen SWFs and three settings-panel SWFs. It excludes main-menu and pause-menu replacements.
4. Run the checks below, then `python scripts/package.py`. The FOMOD ZIP is written to dist/ using VERSION.
5. Run `python tests/panel-package.py` against the resulting archive.

Useful checks:

```text
node tests/settings-controls.cjs
node tests/lifetime-random.cjs
node tests/polish.cjs
node tests/random-theme.cjs
node tests/artwork-selection.cjs
node tests/artwork-finalize.cjs
node tests/artwork-visibility.cjs
python tests/installer.py
python tests/custom-settings.py
python tests/artwork-themes.py
python tests/coin-glint.py
```

The shared catalog, OSF schema, embedded Gameplay TRDefinitions, native catalog and native OSF adapter must agree on keys, values and defaults. Internal names LSCNativeBridge.dll and loading-screen-configurator intentionally stay unchanged.

Approved theme assets are already included. When changing faction animation, use the corresponding `scripts/build-<faction>-coin.py` generator (Pillow required). Faction coins use one filtered bitmap, a three-second tilt and a six-second glint timeline; do not regenerate them from legacy working copies. The older default-artwork generator contains retired designs and is not a required packaging step.

Artwork importing uses Windows WIC. A standalone cache checker can be built from a Visual Studio developer prompt with `cl /std:c++latest /EHsc /I native/src tests/artwork-cache.cpp /Fe:build/artwork-cache.exe /link ole32.lib windowscodecs.lib`; Pillow is required for its fixture tests only.

Panel bridge research, crash evidence and test instructions: docs/PANEL_BRIDGE_TEST.md. Compilation and automated checks do not establish in-game stability.
