extends Node3D
const HOSTILE := preload("res://scripts/combat/hostile_creature.gd")
func _ready() -> void:
	_spawn("Echo Wraith", Vector3(-7,0,-5), 45, false)
	_spawn("Echo Wraith", Vector3(8,0,-12), 45, false)
	_spawn("Echo Wraith", Vector3(-10,0,-22), 55, false)
	_spawn("VARKHOS — Fallen Guardian", Vector3(0,0,-36), 420, true)
func _spawn(title: String, at: Vector3, hp: int, boss: bool) -> void:
	var enemy := CharacterBody3D.new()
	enemy.name = title.replace(" ","_")
	enemy.set_script(HOSTILE)
	enemy.display_name = title
	enemy.max_health = hp
	enemy.move_speed = 2.0 if boss else 2.4
	enemy.boss_mode = boss
	enemy.position = at
	add_child(enemy)
