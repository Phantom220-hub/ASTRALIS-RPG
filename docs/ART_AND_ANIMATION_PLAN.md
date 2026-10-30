# ASTRALIS Art and Animation Plan

## Visual target
Original stylized fantasy art direction: readable silhouettes, rich but controlled colors, layered scenery, atmospheric depth, soft shadows, glowing environmental accents, and clear visual feedback. Genshin Impact and Tower of Fantasy are references for broad presentation goals only; all characters, locations, UI and story content remain original.

## Character pipeline
1. Import a rigged humanoid base character in glTF/GLB format.
2. Confirm skeleton rest pose and scale in Godot.
3. Import compatible CC0 animation clips.
4. Retarget clips to the selected skeleton.
5. Build an AnimationTree with idle, walk, run, jump, land and general action states.
6. Blend transitions and test on the Android device.

## Environment pipeline
- Terrain: large walkable spaces with clear landmarks.
- Nature: trees, grass, rocks and flowers with low-cost materials.
- Architecture: ancient ruins and modular fantasy structures.
- Materials: use texture atlases where practical and keep mobile texture sizes modest.
- Atmosphere: sky, fog and carefully limited particles.

## Mobile performance rules
- Start with Godot Compatibility renderer.
- Use LOD or simplified meshes for distant objects.
- Limit real-time shadow casters and transparent particle overdraw.
- Use compressed textures and avoid unnecessarily large texture maps.
- Test frame pacing, memory use and touch controls on the actual phone.

## Current implementation status
The repository currently contains the initial Godot project configuration, a procedural prototype region, a placeholder player scene and early movement/animation hooks. Real character meshes, environment packs and imported animation clips are still pending asset integration and in-engine validation.
