extends GPUParticles3D

@export var effect_lifetime := 0.65

func _ready() -> void:
	one_shot = true
	emitting = true
	lifetime = effect_lifetime
