extends CharacterBody3D
@export var display_name := "Echo Wraith"
@export var max_health := 45
@export var move_speed := 2.2
@export var boss_mode := false
var health := 45
var _cooldown := 0.0
var _phase := 1
var _time := 0.0
var _player: Node3D
var _reward_claimed := false
var _body: MeshInstance3D
var _bar: Label3D

func _ready() -> void:
	health = max_health
	add_to_group("hostile_creatures")
	_player = get_tree().get_first_node_in_group("player")
	var shape := CapsuleShape3D.new()
	shape.radius = 0.62 if boss_mode else 0.38
	shape.height = 2.7 if boss_mode else 1.6
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = shape.height * 0.5
	add_child(collision)
	_body = MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = shape.radius
	mesh.height = shape.height
	_body.mesh = mesh
	_body.position.y = shape.height * 0.5
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22,0.09,0.39) if boss_mode else Color(0.13,0.25,0.39)
	mat.emission_enabled = true
	mat.emission = Color(0.32,0.08,0.75) if boss_mode else Color(0.06,0.38,0.62)
	mat.emission_energy_multiplier = 1.4
	_body.material_override = mat
	add_child(_body)
	var eye := MeshInstance3D.new()
	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.2 if boss_mode else 0.12
	eye.mesh = eye_mesh
	eye.position = Vector3(0, shape.height * 0.72, -0.34)
	var eye_mat := StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.25,0.9,1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.1,0.7,1.0)
	eye.material_override = eye_mat
	add_child(eye)
	_bar = Label3D.new()
	_bar.text = "%s  %d/%d" % [display_name, health, max_health]
	_bar.position = Vector3(0, shape.height + 0.8, 0)
	_bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bar.font_size = 32
	_bar.pixel_size = 0.006
	_bar.add_theme_font_size_override("font_size", 14 if boss_mode else 11)
	add_child(_bar)

func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	_time += delta
	_cooldown = maxf(0.0, _cooldown - delta)
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return
	var offset := _player.global_position - global_position
	offset.y = 0
	var distance := offset.length()
	var aggro := 26.0 if boss_mode else 13.0
	if distance < aggro and distance > 1.65:
		var direction := offset.normalized()
		var speed := move_speed * (1.35 if _phase == 2 else 1.0)
		velocity.x = move_toward(velocity.x, direction.x * speed, delta * 8.0)
		velocity.z = move_toward(velocity.z, direction.z * speed, delta * 8.0)
		rotation.y = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	move_and_slide()
	if distance <= 1.65 and _cooldown <= 0.0 and _player.has_method("take_damage"):
		_player.take_damage(18 if boss_mode and _phase == 2 else (14 if boss_mode else 8))
		_cooldown = 1.0 if boss_mode else 1.35
	_body.position.y = (1.35 if boss_mode else 0.8) + sin(_time * 2.5) * 0.08

func receive_damage(amount: int) -> void:
	if health <= 0:
		return
	health = maxi(0, health - amount)
	if boss_mode and health <= max_health / 2:
		_phase = 2
	_bar.text = "%s  %d/%d%s" % [display_name, health, max_health, " • PHASE 2" if _phase == 2 else ""]
	if health == 0:
		if not _reward_claimed:
			_reward_claimed = true
			var manager := get_node_or_null("/root/SaveManager")
			if is_instance_valid(_player) and _player.has_method("award_xp"):
				_player.award_xp(120 if boss_mode else 25)
			if manager:
				if boss_mode:
					manager.record_boss_defeat(display_name)
				else:
					manager.add_item("Эфирный осколок", 1)
		_bar.text = "ПОБЕЖДЁН • " + display_name
		_body.visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		await get_tree().create_timer(3.0).timeout
		queue_free()
