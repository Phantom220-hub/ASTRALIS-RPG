extends Area3D

signal relic_activated

var activated := false
var _time := 0.0
@onready var core: MeshInstance3D = $Core
@onready var ring: MeshInstance3D = $Ring

func _process(delta: float) -> void:
	_time += delta
	rotation.y += delta * 0.45
	core.position.y = 1.15 + sin(_time * 1.7) * 0.12
	ring.rotation.z += delta * 0.65

func interact() -> void:
	if activated:
		return
	activated = true
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 1.0, 0.86)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.9, 0.72)
	mat.emission_energy_multiplier = 2.5
	core.material_override = mat
	relic_activated.emit()
