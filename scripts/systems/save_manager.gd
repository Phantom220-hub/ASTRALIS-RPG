extends Node

const SAVE_PATH := "user://astralis_save.cfg"
var relic_awakened := false

func _ready() -> void:
	load_game()

func load_game() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error == OK:
		relic_awakened = bool(config.get_value("story", "first_relic_awakened", false))

func save_relic_awakened(value: bool) -> void:
	relic_awakened = value
	var config := ConfigFile.new()
	config.set_value("story", "first_relic_awakened", relic_awakened)
	config.set_value("meta", "save_version", 1)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("ASTRALIS: unable to save progress (error %d)." % error)

func reset_progress() -> void:
	relic_awakened = false
	var config := ConfigFile.new()
	config.set_value("story", "first_relic_awakened", false)
	config.set_value("meta", "save_version", 1)
	config.save(SAVE_PATH)
