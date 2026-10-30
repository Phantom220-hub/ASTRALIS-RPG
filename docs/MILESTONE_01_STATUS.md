# First milestone: playable foundation

## Implemented in the repository
1. **Project shell:** Godot 4 project, Android-oriented Compatibility renderer, main scene and initial environment.
2. **Player foundation:** CharacterBody3D, camera-relative movement, jump, mobile camera drag, dash, energy regeneration and simple procedural movement.
3. **Mobile interface:** virtual joystick, jump, dash, Echo pulse and USE buttons.
4. **Exploration zone:** large ground plane, path, ancient gate, broken pillars, rocks, stylized trees, colored lights and a relic landmark.
5. **First objective:** approach the ancient relic and activate it; the HUD updates when it is awakened.
6. **Ability prototype:** Echo pulse visual and a practice target that reacts when nearby.
7. **Interface and persistence:** objective/status HUD, pause/restart panel and local save flag for the relic objective.

## Still required before calling this milestone tested
- Open/import the project in Godot 4.7.x Android Edition and resolve any parser or runtime errors.
- Test touch hit areas, screen scaling, camera drag and pause behavior on the actual phone.
- Replace primitive player/environment meshes with licensed rigged and stylized assets.
- Connect a real animation state machine to the final player rig.
- Profile frame rate, memory and thermal behavior on the target device.

## Not included yet
Production anime character models, finished locomotion animation set, full combat, enemies with AI, dialogue, inventory, equipment, multiple regions, story chapters, audio, settings menu and final effects polish.

## Milestone estimate
This is the initial playable foundation milestone, planned as approximately the first 40% of the larger project. The percentage is a scope estimate, not a claim that the game is 40% feature-complete or tested. The next phase should focus on real art/rig/animation integration and a complete playable encounter loop.
