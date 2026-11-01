# Build

Use Windows x64, Visual Studio 2022 C++ tools, xmake 3+, Java and JPEXS FFDec 26.4.0, Python 3 and Node.js for checks. Run commands from the repository root.

1. Clear XSE_SF_MODS_PATH and XSE_SF_GAME_PATH to avoid automatic installation. Set LSC_COMMONLIBSF only if deliberately overriding the vendored dependency.
2. Run `xmake f -P native -m release --diagnostic_no_gameplay_reads=n -y`, then `xmake -P native -j4 -y`.
3. Run `powershell -File scripts/build-ui.ps1 -Java java -FFDec C:/Tools/ffdec/ffdec.jar`.
4. Run `node tests/settings-controls.cjs`.
5. Run `python scripts/package.py`. The FOMOD ZIP is created in dist/.

Settings defaults live in src/settings-catalog.json, src/osf/loading-screen-configurator.json, the embedded TRDefinitions in src/gameplay, native/src/TRSettingsCatalog.inl and native/src/LSCSettings.inl. Update them together; the loading script also has fallback display defaults.

The DLL name and internal OSF ID intentionally stay LSCNativeBridge / loading-screen-configurator to preserve settings compatibility. Do not rename them when changing the product title.

Installer-only backend: select **Neither — configure in installer** for all 17 FOMOD choices with no OSF schema or Gameplay menu patches. Values come from Data/SFSE/Plugins/TransitReport/Installer/*.ini; saved menu preferences are ignored. Reinstall with Replace to change options.

Run `python tests/installer.py` to check the three-backend FOMOD and all installer choices.
