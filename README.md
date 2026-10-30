# ASTRALIS: Echoes of the Lost World

An original mobile-first 3D fantasy action-RPG prototype made with Godot 4. It takes broad inspiration from anime-style open-world presentation and fast mobile action games while using its own world, characters, names and story.

## Current milestone — playable foundation (target: first 40%)

The repository now contains:
- Godot project setup using the Compatibility renderer for Android-oriented development.
- Third-person player prototype with camera-relative movement, jump, dash and energy regeneration.
- Touch controls: virtual joystick, jump, dash, Echo pulse and contextual interaction.
- A first explorable region with a stone path, ancient gate, broken pillars, stylized trees, rocks, glowing lights and a central relic.
- A first story objective: find and awaken the ancient relic.
- Echo pulse ability and a non-hostile practice target that reacts to the pulse.
- HUD with objective, health/energy readout, interaction prompt and pause/restart panel.
- Local save data for the first relic objective.
- A basic animation driver hook and procedural placeholder character motion.

## Controls

### Android
- Left virtual joystick: move.
- Drag the open screen area: rotate the camera.
- JUMP: jump.
- DASH: short burst of movement; consumes energy.
- ECHO: send an energy pulse; consumes energy.
- USE: activate the ancient relic when close enough.
- Pause icon: pause, resume or restart.

### Keyboard (editor testing)
- WASD / arrow keys: move.
- E: interact with the relic.
- Space: jump.
- Mouse/touch drag: rotate camera.
- Dash and Echo are currently exposed through the on-screen controls.

## Project status and limitations

This is a playable systems prototype, not a finished commercial-quality RPG. The character is still a placeholder capsule, the environment is currently assembled from primitive meshes, and the animation driver is not yet connected to a finished rigged character or animation library. There is no finished combat system, quest chain, inventory, dialogue, map, audio package or production character art yet.

The project files have been committed to GitHub, but the current revision has **not** been launched inside Godot or profiled on the Samsung A16. GitHub file presence is not the same as a successful engine import or runtime test. The next test must be performed in Godot on Android, then any errors should be fixed before expanding content.

## Open the project

1. Download the repository as a ZIP.
2. Extract it on the Android device.
3. Open the extracted project folder from Godot 4 Android Edition.
4. Let Godot finish importing, then open the main scene and run it.
5. Report the first error shown by Godot, if any, so it can be corrected.

## Asset policy

Only assets whose individual licences permit the intended use will be included. Prefer CC0 assets where practical. Every imported asset must be recorded in [ASSET_CREDITS.md](ASSET_CREDITS.md), including source, creator, licence and original asset page. Never assume that every download on a marketplace has the same licence.


## Automated Android build
GitHub Actions builds a debug APK for arm64 Android on every push to `main`. The generated APK is attached to the workflow run as the `ASTRALIS-Android-APK` artifact (temporary build download, not a Play Store release).
