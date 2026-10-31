extends Node3D

const PICKUP := preload("res://scripts/world/world_pickup.gd")

func _ready() -> void:
	_build_whispering_vale()

func _mat(color: Color, glow: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	if glow:
		material.emission_enabled = true
		material.emission = color * 0.65
		material.emission_energy_multiplier = 1.35
	return material

func _mesh(mesh: Mesh, at: Vector3, material: Material, object_name: String) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = object_name
	node.mesh = mesh
	node.position = at
	node.material_override = material
	add_child(node)
	return node

func _build_whispering_vale() -> void:
	var bark := _mat(Color(0.24, 0.19, 0.17))
	var leaf := _mat(Color(0.12, 0.34, 0.29))
	var crystal := _mat(Color(0.12, 0.55, 0.75), true)
	var stone := _mat(Color(0.34, 0.41, 0.48))
	var gold := _mat(Color(0.78, 0.58, 0.24), true)
	var lantern := _mat(Color(0.22, 0.72, 0.92), true)
	# 12 trees
	for i in range(12):
		var x := 28.0 + float(i % 4) * 4.2
		var z := -12.0 - float(i / 4) * 8.0
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.16
		trunk.bottom_radius = 0.27
		trunk.height = 2.5
		_mesh(trunk, Vector3(x, 1.25, z), bark, "ValeTreeTrunk_%02d" % i)
		var crown := SphereMesh.new()
		crown.radius = 1.15
		crown.height = 2.2
		var crown_node := _mesh(crown, Vector3(x, 3.0, z), leaf, "ValeTreeCrown_%02d" % i)
		crown_node.scale = Vector3(1.0, 1.25, 1.0)
	# 10 crystal spires
	for i in range(10):
		var prism := PrismMesh.new()
		prism.size = Vector3(0.7 + float(i % 3) * 0.18, 1.5 + float(i % 4) * 0.55, 0.7)
		var x := 25.0 + float(i % 5) * 3.1
		var z := -18.0 - float(i / 5) * 22.0
		var node := _mesh(prism, Vector3(x, prism.size.y * 0.5, z), crystal, "ValeCrystal_%02d" % i)
		node.rotation.z = float(i % 3 - 1) * 0.12
	# 8 broken pillars
	for i in range(8):
		var pillar := CylinderMesh.new()
		pillar.top_radius = 0.35
		pillar.bottom_radius = 0.48
		pillar.height = 1.4 + float(i % 3) * 0.65
		var x := 24.0 + float(i % 4) * 4.0
		var z := -35.0 - float(i / 4) * 5.0
		_mesh(pillar, Vector3(x, pillar.height * 0.5, z), stone, "ValeBrokenPillar_%02d" % i)
	# 6 luminous lanterns
	for i in range(6):
		var post := CylinderMesh.new()
		post.top_radius = 0.09
		post.bottom_radius = 0.13
		post.height = 2.0
		var x := 27.0 + float(i % 2) * 10.0
		var z := -8.0 - float(i) * 8.0
		_mesh(post, Vector3(x, 1.0, z), stone, "ValeLanternPost_%02d" % i)
		var orb := SphereMesh.new()
		orb.radius = 0.28
		orb.height = 0.56
		_mesh(orb, Vector3(x, 2.15, z), lantern, "ValeLanternOrb_%02d" % i)
	# 6 harvestable herb clusters
	for i in range(6):
		var pickup := Area3D.new()
		pickup.name = "MoonHerb_%02d" % i
		pickup.set_script(PICKUP)
		pickup.item_id = "vale_herb_%02d" % i
		pickup.item_name = "Лунная трава"
		pickup.amount = 1
		pickup.xp_reward = 15
		pickup.position = Vector3(27.0 + float(i % 3) * 5.0, 0.0, -14.0 - float(i / 3) * 18.0)
		add_child(pickup)
	# 4 treasure caches
	for i in range(4):
		var cache := Area3D.new()
		cache.name = "ValeCache_%02d" % i
		cache.set_script(PICKUP)
		cache.item_id = "vale_cache_%02d" % i
		cache.item_name = "Золото"
		cache.amount = 35
		cache.xp_reward = 40
		cache.is_cache = true
		cache.position = Vector3(23.0 + float(i % 2) * 14.0, 0.0, -25.0 - float(i / 2) * 24.0)
		add_child(cache)
	# 4 floating stone fragments
	for i in range(4):
		var rock := SphereMesh.new()
		rock.radius = 0.8
		rock.height = 1.3
		var x := 24.0 + float(i) * 5.0
		var z := -48.0
		var node := _mesh(rock, Vector3(x, 2.0 + float(i % 2), z), stone, "ValeFloatingStone_%02d" % i)
		node.rotation.z = 0.35
