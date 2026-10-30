# ASTRALIS: Echoes of the Lost World

An original mobile-first 3D fantasy action-RPG prototype made with Godot 4. It takes broad inspiration from anime-style open-world presentation and fast mobile action games while using its own world, characters, names and story.

## Current milestone — combat and progression foundation

The repository now contains:
- Godot project setup using the Compatibility renderer for Android-oriented development.
- Third-person player prototype with camera-relative movement, jump, dash and energy regeneration.
- Touch controls: virtual joystick, jump, dash, Echo pulse, melee attack and contextual interaction.
- A first explorable region with a stone path, ancient gate, broken pillars, stylized trees, rocks, glowing lights and a central relic.
- First story objective: find and awaken the ancient relic.
- Hostile Echo Wraith encounters and two boss encounters: VARKHOS and NYTHERA (NYTHERA unlocks after VARKHOS).
- Melee attacks and an Echo pulse that damages nearby enemies.
- Enemy health/name indicators, boss phase change, enemy defeat rewards, XP, levels, gold and persistent inventory.
- Inventory and quest journal overlays, including healing potion use.
- A frozen-ruins arena section for the second boss.
- Echo pulse ability and a non-hostile practice target that reacts to the pulse.
- HUD with objective, health/energy, FPS, progression readout, inventory, quest journal and pause/restart panel.
- Local save data for relic progress, defeated bosses, level, XP, gold and inventory.
- A basic animation driver hook and procedural placeholder character motion.

## Controls

### Android
- Left virtual joystick: move.
- Drag the open screen area: rotate the camera.
- JUMP: jump.
- DASH: short burst of movement; consumes energy.
- ECHO: send an energy pulse; consumes energy and damages nearby enemies.
- ATK: melee attack; consumes a small amount of energy.
- СУМКА / ЗАДАНИЯ: inventory and quest journal.
- USE: activate the ancient relic when close enough.
- Pause icon: pause, resume or restart.

### Keyboard (editor testing)
- WASD / arrow keys: move.
- E: interact with the relic.
- Space: jump.
- Mouse/touch drag: rotate camera.
- Dash and Echo are currently exposed through the on-screen controls.

## Project status and limitations

This is still an actively developed RPG foundation, not a finished commercial-scale open-world game. The current world is assembled from procedural primitive meshes; the hero and enemies are procedural placeholders rather than detailed rigged anime models. The project still needs expanded playable regions, story/dialogue scenes, more enemy types and boss patterns, polished animations, sound/music, settings, map/fast travel, balancing, accessibility and extensive Android device testing.

Automated CI verifies Godot import/startup and Android APK export. That does not prove real-device performance or that every gameplay interaction feels correct on a Samsung A16. Do not treat a successful export as a finished game.

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
