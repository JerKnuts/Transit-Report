# 0.9.5 validation

Completed: MSVC/xmake native compilation; six Gameplay Options SWF compilations; loading SWF compilation; 17 setting choice/default mapping checks; matching OSF/standalone defaults; FOMOD structure and ZIP integrity checks.

Pending: in-game standalone root-menu binding, persistence after restart, defaults reset, keyboard/controller operation and compatibility with other menu mods. Prior runtime testing confirmed loading backgrounds, lifetime counter display and keyboard/controller page navigation; this does not establish the new standalone backend is fully tested.

The tester reproduced the FaceCustomization renderer crash with this mod disabled. This version does not claim to fix that separate crash.

Installer-only update: native compilation and FOMOD XSD pass. Automated tests cover all 17 default and non-default choices, conditional pages, destination INIs, and absence of installer-only menu/schema files. Runtime confirmation of this new backend remains pending.
