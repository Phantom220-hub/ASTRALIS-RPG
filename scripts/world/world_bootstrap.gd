extends Node3D

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")

func _ready() -> void:
	_build_first_region()
	var player := PLAYER_SCENE.instantiate()
	player.position = Vector3(0.0, 1.2, 5.0)
	add_child(player)

func _build_first_region() -> void:
	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(90.0, 90.0)
	ground.mesh = ground_mesh
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.16, 0.31, 0.25)
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	ground.position.y = -0.15
	add_child(ground)

	var ground_body := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(90.0, 0.3, 90.0)
	ground_shape.shape = box
	ground_body.position.y = -0.3
	ground_body.add_child(ground_shape)
	add_child(ground_body)

	_add_stylized_rock(Vector3(-7, 0.0, -5), Vector3(2.8, 2.1, 2.4))
	_add_stylized_rock(Vector3(8, 0.0, -10), Vector3(3.8, 2.7, 3.0))
	_add_stylized_rock(Vector3(12, 0.0, 8), Vector3(2.2, 1.8, 2.5))
	_add_glowing_marker(Vector3(0, 0.0, -8))

func _add_stylized_rock(at: Vector3, scale_value: Vector3) -> void:
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 1.8
	rock.mesh = mesh
	rock.position = at
	rock.scale = scale_value
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.27, 0.34, 0.39)
	material.roughness = 0.92
	rock.material_override = material
	add_child(rock)

func _add_glowing_marker(at: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.08
	mesh.bottom_radius = 0.08
	mesh.height = 3.2
	marker.mesh = mesh
	marker.position = at + Vector3(0, 1.6, 0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.8, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.08, 0.55, 1.0)
	material.emission_energy_multiplier = 2.0
	marker.material_override = material
	add_child(marker)
