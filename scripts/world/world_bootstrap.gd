extends Node3D

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const RELIC_SCRIPT := preload("res://scripts/world/ancient_relic.gd")
const DUMMY_SCRIPT := preload("res://scripts/world/waypoint_dummy.gd")
const HUD_SCRIPT := preload("res://scripts/ui/game_hud.gd")
const ENCOUNTER_SCRIPT := preload("res://scripts/combat/encounter_director.gd")

var _hud: Control
var _relic: Area3D

func _ready() -> void:
	_build_first_region()
	var player := PLAYER_SCENE.instantiate()
	player.position = Vector3(0.0, 1.2, 7.0)
	add_child(player)
	var encounters := Node3D.new()
	encounters.name = "EncounterDirector"
	encounters.set_script(ENCOUNTER_SCRIPT)
	add_child(encounters)
	_create_hud(player)

func _setup_sky_and_lighting() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.035, 0.075, 0.19)
	sky_material.sky_horizon_color = Color(0.34, 0.56, 0.72)
	sky_material.ground_bottom_color = Color(0.055, 0.075, 0.12)
	sky_material.ground_horizon_color = Color(0.22, 0.34, 0.42)
	sky_material.sun_angle_max = 18.0
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.62
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_color = Color(0.82, 0.9, 1.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _create_hud(player: Node3D) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_hud = Control.new()
	_hud.set_script(HUD_SCRIPT)
	layer.add_child(_hud)
	_hud.set("player", player)
	var relic := get_tree().get_first_node_in_group("ancient_relic")
	if relic:
		relic.relic_activated.connect(_on_relic_activated)
		if SaveManager.relic_awakened:
			relic.interact()

func _on_relic_activated() -> void:
	SaveManager.save_relic_awakened(true)
	if is_instance_valid(_hud):
		_hud.set_relic_complete()

func _build_first_region() -> void:
	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(100.0, 100.0)
	ground.mesh = ground_mesh
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.19, 0.34, 0.29)
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	ground.position.y = -0.15
	add_child(ground)

	var ground_body := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100.0, 0.3, 100.0)
	ground_shape.shape = box
	ground_body.position.y = -0.3
	ground_body.add_child(ground_shape)
	add_child(ground_body)

	_add_path()
	_add_ruin_gate(Vector3(0, 0, -12))
	_add_ruin_pillars()
	_add_stylized_rock(Vector3(-11, 0.0, -7), Vector3(3.2, 2.2, 2.8))
	_add_stylized_rock(Vector3(12, 0.0, -13), Vector3(3.8, 2.7, 3.0))
	_add_stylized_rock(Vector3(14, 0.0, 9), Vector3(2.2, 1.8, 2.5))
	_add_tree(Vector3(-13, 0, 8), 1.0)
	_add_tree(Vector3(-17, 0, 1), 1.2)
	_add_tree(Vector3(17, 0, -3), 1.1)
	_add_tree(Vector3(19, 0, 10), 0.9)
	_add_tree(Vector3(-20, 0, -14), 1.25)
	_add_relic(Vector3(0, 0, -19))
	_add_pulse_dummy(Vector3(5, 0, -7))
	_add_glowing_marker(Vector3(0, 0.0, -8))
	_add_ambient_lights()
	_add_frozen_ruins()

func _add_path() -> void:
	var path := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(5.0, 0.08, 34.0)
	path.mesh = mesh
	path.position = Vector3(0, -0.06, -8)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.37, 0.34)
	mat.roughness = 1.0
	path.material_override = mat
	add_child(path)

func _add_ruin_gate(at: Vector3) -> void:
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.43, 0.48, 0.54)
	stone.roughness = 0.88
	for x in [-3.0, 3.0]:
		var pillar := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.0, 6.5, 1.1)
		pillar.mesh = mesh
		pillar.position = at + Vector3(x, 3.25, 0)
		pillar.material_override = stone
		add_child(pillar)
	var lintel := MeshInstance3D.new()
	var lintel_mesh := BoxMesh.new()
	lintel_mesh.size = Vector3(7.0, 0.9, 1.25)
	lintel.mesh = lintel_mesh
	lintel.position = at + Vector3(0, 6.1, 0)
	lintel.material_override = stone
	add_child(lintel)

func _add_ruin_pillars() -> void:
	for i in range(7):
		var angle := float(i) * TAU / 7.0
		var pos := Vector3(cos(angle) * 7.0, 0.0, -19.0 + sin(angle) * 5.0)
		var pillar := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.42
		mesh.bottom_radius = 0.58
		mesh.height = randf_range(1.2, 3.4)
		pillar.mesh = mesh
		pillar.position = pos + Vector3(0, mesh.height * 0.5, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.39, 0.45, 0.5)
		mat.roughness = 0.95
		pillar.material_override = mat
		add_child(pillar)

func _add_tree(at: Vector3, size: float) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18 * size
	trunk_mesh.bottom_radius = 0.32 * size
	trunk_mesh.height = 2.4 * size
	trunk.mesh = trunk_mesh
	trunk.position = at + Vector3(0, 1.2 * size, 0)
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color(0.28, 0.22, 0.19)
	trunk.material_override = bark
	add_child(trunk)
	for layer in range(3):
		var crown := MeshInstance3D.new()
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 1.0
		crown_mesh.height = 1.8
		crown.mesh = crown_mesh
		crown.scale = Vector3(1.25, 0.85, 1.15) * size * (1.0 - layer * 0.12)
		crown.position = at + Vector3(0, (2.5 + layer * 0.65) * size, 0)
		var leaves := StandardMaterial3D.new()
		leaves.albedo_color = [Color(0.16, 0.37, 0.31), Color(0.2, 0.44, 0.34), Color(0.26, 0.49, 0.37)][layer]
		leaves.roughness = 1.0
		crown.material_override = leaves
		add_child(crown)

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

func _add_relic(at: Vector3) -> void:
	var relic := Area3D.new()
	relic.name = "AncientRelic"
	relic.set_script(RELIC_SCRIPT)
	relic.position = at
	relic.add_to_group("ancient_relic")
	var shape_node := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.2
	shape_node.shape = sphere
	relic.add_child(shape_node)
	var core := MeshInstance3D.new()
	core.name = "Core"
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.65
	core_mesh.height = 1.5
	core.mesh = core_mesh
	core.position.y = 1.15
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.18, 0.75, 1.0)
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.08, 0.5, 1.0)
	core_mat.emission_energy_multiplier = 2.2
	core.material_override = core_mat
	relic.add_child(core)
	var ring := MeshInstance3D.new()
	ring.name = "Ring"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.9
	ring_mesh.outer_radius = 1.04
	ring.mesh = ring_mesh
	ring.position.y = 1.15
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.25, 0.85, 1.0)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.1, 0.6, 1.0)
	ring_mat.emission_energy_multiplier = 1.8
	ring.material_override = ring_mat
	relic.add_child(ring)
	add_child(relic)

func _add_pulse_dummy(at: Vector3) -> void:
	var dummy := Node3D.new()
	dummy.name = "EchoTarget"
	dummy.set_script(DUMMY_SCRIPT)
	dummy.position = at
	dummy.add_to_group("pulse_targets")
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.7
	base_mesh.bottom_radius = 0.9
	base_mesh.height = 0.35
	base.mesh = base_mesh
	base.position.y = 0.18
	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.32, 0.39, 0.45)
	base.material_override = base_mat
	dummy.add_child(base)
	var orb := MeshInstance3D.new()
	orb.name = "Orb"
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.55
	orb_mesh.height = 1.1
	orb.mesh = orb_mesh
	orb.position.y = 1.2
	var orb_mat := StandardMaterial3D.new()
	orb_mat.albedo_color = Color(0.45, 0.31, 0.75)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(0.24, 0.12, 0.8)
	orb_mat.emission_energy_multiplier = 1.2
	orb.material_override = orb_mat
	dummy.add_child(orb)
	add_child(dummy)

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

func _add_ambient_lights() -> void:
	for pos in [Vector3(-6, 2.5, -17), Vector3(6, 2.5, -17)]:
		var light := OmniLight3D.new()
		light.position = pos
		light.light_color = Color(0.22, 0.65, 1.0)
		light.light_energy = 0.8
		light.omni_range = 8.0
		add_child(light)

func _add_frozen_ruins() -> void:
	var ice := StandardMaterial3D.new()
	ice.albedo_color = Color(0.18, 0.42, 0.58)
	ice.roughness = 0.28
	ice.metallic = 0.18
	for i in range(9):
		var shard := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(randf_range(1.0, 2.2), randf_range(3.0, 6.0), randf_range(1.0, 2.0))
		shard.mesh = mesh
		shard.position = Vector3(randf_range(-12.0,12.0), mesh.size.y * 0.5, -52.0 + randf_range(-9.0,9.0))
		shard.rotation.z = randf_range(-0.18,0.18)
		shard.material_override = ice
		add_child(shard)
	var platform := MeshInstance3D.new()
	var platform_mesh := CylinderMesh.new()
	platform_mesh.top_radius = 10.0
	platform_mesh.bottom_radius = 11.0
	platform_mesh.height = 0.6
	platform.mesh = platform_mesh
	platform.position = Vector3(0,-0.05,-68)
	platform.material_override = ice
	add_child(platform)
