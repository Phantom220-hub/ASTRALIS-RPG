extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var jump_velocity: float = 6.0
@export var turn_speed: float = 10.0

@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _elapsed := 0.0

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	var direction := (right * input_vector.x + forward * -input_vector.y).normalized()

	if direction.length() > 0.05:
		var target_yaw := atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, turn_speed * delta)

	var target_horizontal := direction * move_speed
	velocity.x = move_toward(velocity.x, target_horizontal.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_horizontal.z, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	move_and_slide()
	_update_procedural_motion(input_vector.length(), delta)

func _update_procedural_motion(amount: float, delta: float) -> void:
	var body := visual.get_node_or_null("Body") as Node3D
	if body == null:
		return
	var speed := 9.0 if amount > 0.1 else 2.0
	var bob := 0.045 if amount > 0.1 else 0.012
	body.position.y = lerp(body.position.y, 0.9 + sin(_elapsed * speed) * bob, delta * 9.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		camera_pivot.rotate_y(-event.relative.x * 0.003)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - event.relative.y * 0.003, -0.65, 0.35)
