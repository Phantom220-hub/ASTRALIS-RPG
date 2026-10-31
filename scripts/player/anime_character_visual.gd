extends Node3D
## Lightweight stylized anime-inspired adventurer. Replace with a licensed rigged GLB/VRM later.
var _parts: Dictionary = {}
var _time := 0.0
func _mat(color: Color, roughness := 0.72, emission := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	if emission:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.35
	return m
func _mesh(parent: Node3D, name: String, mesh: Mesh, pos: Vector3, material: Material, scale_value := Vector3.ONE) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.name = name
	n.mesh = mesh
	n.position = pos
	n.scale = scale_value
	n.material_override = material
	parent.add_child(n)
	return n
func _capsule(radius: float, height: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = radius
	m.height = height
	m.radial_segments = 10
	m.rings = 4
	return m
func _build() -> void:
	var skin := _mat(Color(0.96, 0.72, 0.59))
	var coat := _mat(Color(0.12, 0.22, 0.42))
	var coat_light := _mat(Color(0.22, 0.48, 0.72))
	var dark := _mat(Color(0.055, 0.075, 0.13))
	var gold := _mat(Color(0.95, 0.69, 0.27), 0.42, true)
	var hair := _mat(Color(0.12, 0.16, 0.27))
	var eye := _mat(Color(0.18, 0.83, 1.0), 0.3, true)
	_mesh(self, "Torso", _capsule(0.29, 0.82), Vector3(0, 1.08, 0), coat)
	_mesh(self, "ChestPanel", _capsule(0.205, 0.58), Vector3(0, 1.13, -0.12), coat_light)
	_mesh(self, "Waist", _capsule(0.22, 0.28), Vector3(0, 0.69, 0), dark)
	_mesh(self, "Head", SphereMesh.new(), Vector3(0, 1.82, -0.015), skin, Vector3(0.245, 0.29, 0.225))
	_mesh(self, "HairCap", SphereMesh.new(), Vector3(0, 2.00, 0.015), hair, Vector3(0.265, 0.19, 0.24))
	for i in range(5):
		var spike := _mesh(self, "HairSpike%d" % i, _capsule(0.075, 0.27), Vector3(-0.17 + i * 0.085, 2.02 + (0.05 if i % 2 == 0 else 0.0), -0.12), hair)
		spike.rotation.z = -0.45 + i * 0.22
	for x in [-0.095, 0.095]:
		_mesh(self, "Eye", SphereMesh.new(), Vector3(x, 1.84, -0.218), eye, Vector3(0.035, 0.045, 0.018))
	_mesh(self, "Scarf", _capsule(0.12, 0.18), Vector3(0, 1.52, -0.01), gold)
	for side in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.name = "ArmPivotL" if side < 0 else "ArmPivotR"
		arm.position = Vector3(side * 0.34, 1.38, 0)
		add_child(arm)
		_mesh(arm, "Sleeve", _capsule(0.105, 0.48), Vector3(0, -0.20, 0), coat)
		_mesh(arm, "Glove", _capsule(0.085, 0.16), Vector3(0, -0.47, 0), dark)
		_parts[arm.name] = arm
		var leg := Node3D.new()
		leg.name = "LegPivotL" if side < 0 else "LegPivotR"
		leg.position = Vector3(side * 0.14, 0.62, 0)
		add_child(leg)
		_mesh(leg, "Leg", _capsule(0.115, 0.48), Vector3(0, -0.23, 0), dark)
		_mesh(leg, "Boot", _capsule(0.12, 0.22), Vector3(0, -0.47, -0.045), coat_light)
		_parts[leg.name] = leg
	_mesh(self, "ShoulderGoldL", SphereMesh.new(), Vector3(-0.34, 1.42, 0), gold, Vector3(0.13, 0.13, 0.13))
	_mesh(self, "ShoulderGoldR", SphereMesh.new(), Vector3(0.34, 1.42, 0), gold, Vector3(0.13, 0.13, 0.13))
func _ready() -> void:
	_build()
func animate_locomotion(speed_ratio: float, delta: float, airborne: bool) -> void:
	_time += delta
	var swing := sin(_time * 10.0) * clampf(speed_ratio, 0.0, 1.0) * 0.62
	for key in ["LegPivotL", "LegPivotR"]:
		if _parts.has(key):
			var sign := -1.0 if key.ends_with("L") else 1.0
			var pivot: Node3D = _parts[key]
			pivot.rotation.x = swing * sign if not airborne else -0.35
	for key in ["ArmPivotL", "ArmPivotR"]:
		if _parts.has(key):
			var sign := 1.0 if key.ends_with("L") else -1.0
			var pivot: Node3D = _parts[key]
			pivot.rotation.x = -swing * sign * 0.72 if not airborne else 0.45
	var moving := clampf(speed_ratio, 0.0, 1.0)
	var idle_breath := sin(_time * 2.2) * 0.018
	position.y = (0.035 * absf(sin(_time * 10.0)) * moving + idle_breath) if not airborne else 0.0
	rotation.z = sin(_time * 1.4) * 0.012
	if _parts.has("ArmPivotR") and moving < 0.05 and not airborne:
		var idle_arm: Node3D = _parts["ArmPivotR"]
		idle_arm.rotation.z = sin(_time * 1.7) * 0.035
