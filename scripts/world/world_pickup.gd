extends Area3D

@export var item_id := "vale_item_01"
@export var item_name := "Лунная трава"
@export var amount := 1
@export var xp_reward := 12
@export var is_cache := false
var _elapsed := 0.0
var _taken := false

func _ready() -> void:
	add_to_group("ancient_relic")
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 2.1
	collision.shape = shape
	add_child(collision)
	var visual := MeshInstance3D.new()
	visual.name = "PickupVisual"
	if is_cache:
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.9, 0.65, 0.7)
		visual.mesh = mesh
	else:
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.48, 0.85, 0.48)
		visual.mesh = mesh
	visual.position.y = 0.8
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.88, 0.66, 0.24) if is_cache else Color(0.28, 0.9, 0.63)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.55
	material.emission_energy_multiplier = 1.2
	visual.material_override = material
	add_child(visual)
	if SaveManager.claimed_world_items.has(item_id):
		queue_free()

func _process(delta: float) -> void:
	if _taken:
		return
	_elapsed += delta
	rotation.y += delta * 0.65
	var visual := get_node_or_null("PickupVisual") as Node3D
	if visual:
		visual.position.y = 0.8 + sin(_elapsed * 2.0) * 0.12

func get_interaction_text() -> String:
	return "НАЖМИ E  •  Открыть сундук" if is_cache else "НАЖМИ E  •  Собрать " + item_name

func interact() -> void:
	if _taken:
		return
	_taken = true
	if SaveManager.claim_world_item(item_id, item_name, amount, xp_reward):
		var visual := get_node_or_null("PickupVisual")
		if visual:
			visual.visible = false
	queue_free()
