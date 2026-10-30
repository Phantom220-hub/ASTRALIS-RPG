extends Node

## Animation bridge for the future rigged character.
## Assign an AnimationTree and AnimationPlayer after importing the licensed character pack.

@export var animation_tree_path: NodePath
@export var idle_state: StringName = &"parameters/conditions/idle"
@export var move_state: StringName = &"parameters/conditions/moving"

var _tree: AnimationTree

func _ready() -> void:
	if not animation_tree_path.is_empty():
		_tree = get_node_or_null(animation_tree_path) as AnimationTree
	if _tree:
		_tree.active = true

func set_locomotion(is_moving: bool) -> void:
	if _tree == null:
		return
	_tree.set(idle_state, not is_moving)
	_tree.set(move_state, is_moving)

func play_one_shot(state_path: StringName) -> void:
	if _tree == null:
		return
	var playback := _tree.get("parameters/OneShot")
	if playback is AnimationNodeOneShot:
		_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
