extends Node3D

var _time := 0.0
@onready var orb: MeshInstance3D = $Orb

func _process(delta: float) -> void:
	_time += delta
	orb.position.y = 1.2 + sin(_time * 1.4) * 0.08
	orb.rotation.y += delta * 0.7

func receive_pulse() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.85, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.65, 1.0)
	mat.emission_energy_multiplier = 3.0
	orb.material_override = mat
