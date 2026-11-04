# 0.9.7 release validation

## Completed

- Native plugin and eight UI files built successfully after the seven-theme integration.
- Theme paths, settings mappings and three FOMOD backends passed automated checks.
- All seven faction coins contain filtered 192px textures and 90 frames at 30fps.
- All faction wallpapers are packaged as static artwork.
- User confirmed Crimson Fleet texture filtering improved in-game appearance.
- User approved the faster tilt/glint comparison and all faction artwork.

## Final in-game verification required

- Install the current complete archive with Replace and test each settings backend.
- Check all seven themes on full loading screens and indicators on short transitions.
- Verify the latest three-second animation, glint, readability and lack of overlapping indicators.
- Check keyboard/controller stat navigation, Custom pools, initial save load and post-load performance.

Compilation and automated checks do not establish in-game stability. The earlier FaceCustomization crash also occurred with Transit Report disabled; its root cause remains unresolved.

No new version bump, GitHub push or Nexus upload is part of this staging cleanup.


0.9.7: Each artwork selector now includes Theme. Only slots set to Theme use the chosen faction. Original, Hidden, built-in and Custom choices work independently with any faction selected. Existing saved slot values are respected; select Theme explicitly to use faction artwork. Theme with no faction selected falls back to Orbiting Star/Orbital Chart. Runtime verification pending.
