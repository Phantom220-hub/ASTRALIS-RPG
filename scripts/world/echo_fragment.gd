extends Area3D

@export var fragment_id := "echo_01"
var _time := 0.0
var _collected := false

func _ready() -> void:
	add_to_group("ancient_relic")
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 2.0
	collision.shape = shape
	add_child(collision)
	var shard := MeshInstance3D.new()
	shard.name = "Shard"
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.7, 1.25, 0.7)
	shard.mesh = mesh
	shard.position.y = 1.15
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.82, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.08, 0.58, 1.0)
	material.emission_energy_multiplier = 2.8
	shard.material_override = material
	add_child(shard)
	if SaveManager.collected_fragments.has(fragment_id):
		queue_free()

func _process(delta: float) -> void:
	if _collected:
		return
	_time += delta
	rotation.y += delta * 0.75
	var shard := get_node_or_null("Shard") as Node3D
	if shard:
		shard.position.y = 1.15 + sin(_time * 2.0) * 0.16

func get_interaction_text() -> String:
	return "НАЖМИ E / INTERACT  •  Собрать эхо-фрагмент"

func interact() -> void:
	if _collected or not SaveManager.collect_fragment(fragment_id):
		queue_free()
		return
	_collected = true
	var shard := get_node_or_null("Shard")
	if shard:
		shard.visible = false
	queue_free()
