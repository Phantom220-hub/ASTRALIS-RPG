extends CharacterBody3D

@export var move_speed: float = 5.2
@export var acceleration: float = 18.0
@export var jump_velocity: float = 6.2
@export var turn_speed: float = 10.0
@export var dash_speed: float = 12.0

@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var health: int = 100
var energy: float = 100.0
var _elapsed := 0.0
var _dash_time := 0.0
var _dash_cooldown := 0.0
var _cast_cooldown := 0.0
var _interaction_hint := ""
var _character: Node3D
var level := 1
var experience := 0

func _ready() -> void:
	add_to_group("player")
	level = SaveManager.player_level
	experience = SaveManager.player_xp
	var old_body := visual.get_node_or_null("Body")
	if old_body:
		old_body.queue_free()
	_character = Node3D.new()
	_character.name = "AnimeAdventurer"
	_character.set_script(load("res://scripts/player/anime_character_visual.gd"))
	visual.add_child(_character)
	for action in ["dash", "cast", "interact", "attack"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	var interact_key := InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	InputMap.action_add_event("interact", interact_key)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	energy = minf(100.0, energy + delta * 8.0)
	_dash_time = maxf(0.0, _dash_time - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_cast_cooldown = maxf(0.0, _cast_cooldown - delta)
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	var direction := (right * input_vector.x + forward * -input_vector.y).normalized()

	if direction.length() > 0.05:
		var target_yaw := atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, turn_speed * delta)

	if Input.is_action_just_pressed("dash") and _dash_cooldown <= 0.0 and energy >= 20.0:
		var dash_direction := direction if direction.length() > 0.05 else -camera_pivot.global_basis.z
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		_dash_time = 0.18
		_dash_cooldown = 1.0
		energy -= 20.0

	if _dash_time <= 0.0:
		var target_horizontal := direction * move_speed
		velocity.x = move_toward(velocity.x, target_horizontal.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_horizontal.z, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("attack"):
		_perform_attack()
	if Input.is_action_just_pressed("cast") and _cast_cooldown <= 0.0 and energy >= 12.0:
		_cast_echo_pulse()

	move_and_slide()
	_update_procedural_motion(input_vector.length(), delta)
	_update_interaction_hint()

func _update_procedural_motion(amount: float, delta: float) -> void:
	if is_instance_valid(_character) and _character.has_method("animate_locomotion"):
		_character.animate_locomotion(amount, delta, not is_on_floor())

func _nearest_interactable() -> Node3D:
	var nearest: Node3D
	var nearest_distance := 4.5
	for item in get_tree().get_nodes_in_group("ancient_relic"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < nearest_distance:
				nearest = item
				nearest_distance = distance
	return nearest

func _update_interaction_hint() -> void:
	_interaction_hint = ""
	var target := _nearest_interactable()
	if target:
		_interaction_hint = "НАЖМИ E / INTERACT  •  Пробудить реликт"

func get_interaction_hint() -> String:
	return _interaction_hint

func _try_interact() -> void:
	var target := _nearest_interactable()
	if target and target.has_method("interact"):
		target.interact()

func _cast_echo_pulse() -> void:
	energy -= 12.0
	_cast_cooldown = 0.65
	var pulse := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	pulse.mesh = mesh
	pulse.global_position = global_position + Vector3(0, 1.2, 0) - camera_pivot.global_basis.z * 1.6
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.2, 0.85, 1.0, 0.65)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color(0.1, 0.7, 1.0)
	material.emission_energy_multiplier = 2.5
	pulse.material_override = material
	get_tree().current_scene.add_child(pulse)
	var tween := create_tween()
	tween.tween_property(pulse, "scale", Vector3.ONE * 5.0, 0.32)
	tween.parallel().tween_property(pulse, "transparency", 1.0, 0.32)
	tween.tween_callback(pulse.queue_free)
	for enemy in get_tree().get_nodes_in_group("hostile_creatures"):
		if enemy is Node3D and enemy.has_method("receive_damage") and global_position.distance_to(enemy.global_position) < 8.0:
			enemy.receive_damage(45)
	for target in get_tree().get_nodes_in_group("pulse_targets"):
		if target is Node3D and global_position.distance_to(target.global_position) < 8.0:
			if target.has_method("receive_pulse"):
				target.receive_pulse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * 0.003)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - event.relative.y * 0.003, -0.65, 0.35)

func _perform_attack() -> void:
	if energy < 5.0:
		return
	energy -= 5.0
	var forward := -visual.global_basis.z
	for enemy in get_tree().get_nodes_in_group("hostile_creatures"):
		if enemy is Node3D and enemy.has_method("receive_damage"):
			var offset: Vector3 = enemy.global_position - global_position
			var distance := offset.length()
			if distance <= 3.4 and forward.dot(offset.normalized()) > -0.15:
				enemy.receive_damage(28)

func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	if health == 0:
		health = 100
		energy = 100.0
		global_position = Vector3(0.0, 1.2, 7.0)
		velocity = Vector3.ZERO

func award_xp(amount: int) -> void:
	var leveled_up: bool = SaveManager.award_xp(amount)
	level = SaveManager.player_level
	experience = SaveManager.player_xp
	if leveled_up:
		health = 100
		energy = 100.0
		move_speed += 0.15
