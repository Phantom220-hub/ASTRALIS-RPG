extends Node

const SAVE_PATH := "user://astralis_save.cfg"
var relic_awakened := false
var player_level := 1
var player_xp := 0
var gold := 0
var defeated_bosses: Array[String] = []
var collected_fragments: Array[String] = []
var claimed_world_items: Array[String] = []
var inventory: Dictionary = {"Эфирный осколок": 0, "Зелье лечения": 2}

func _ready() -> void:
	load_game()

func load_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	relic_awakened = bool(config.get_value("story", "first_relic_awakened", false))
	player_level = int(config.get_value("player", "level", 1))
	player_xp = int(config.get_value("player", "xp", 0))
	gold = int(config.get_value("player", "gold", 0))
	defeated_bosses = config.get_value("story", "defeated_bosses", [])
	collected_fragments = config.get_value("story", "collected_fragments", [])
	claimed_world_items = config.get_value("world", "claimed_items", [])
	inventory = config.get_value("inventory", "items", inventory)

func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("story", "first_relic_awakened", relic_awakened)
	config.set_value("story", "defeated_bosses", defeated_bosses)
	config.set_value("story", "collected_fragments", collected_fragments)
	config.set_value("world", "claimed_items", claimed_world_items)
	config.set_value("player", "level", player_level)
	config.set_value("player", "xp", player_xp)
	config.set_value("player", "gold", gold)
	config.set_value("inventory", "items", inventory)
	config.set_value("meta", "save_version", 2)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("ASTRALIS: save failed (%d)." % error)

func save_relic_awakened(value: bool) -> void:
	relic_awakened = value
	save_game()

func award_xp(amount: int) -> bool:
	player_xp += amount
	var leveled_up := false
	while player_xp >= player_level * 100:
		player_xp -= player_level * 100
		player_level += 1
		leveled_up = true
	save_game()
	return leveled_up

func add_item(item_name: String, amount: int = 1) -> void:
	inventory[item_name] = int(inventory.get(item_name, 0)) + amount
	save_game()

func record_boss_defeat(boss_name: String) -> void:
	if not defeated_bosses.has(boss_name):
		defeated_bosses.append(boss_name)
		gold += 100
		add_item("Эфирный осколок", 3)
	save_game()

func collect_fragment(fragment_id: String) -> bool:
	if collected_fragments.has(fragment_id):
		return false
	collected_fragments.append(fragment_id)
	add_item("Эхо-фрагмент", 1)
	award_xp(35)
	return true

func claim_world_item(item_id: String, item_name: String, amount: int, xp: int) -> bool:
	if claimed_world_items.has(item_id):
		return false
	claimed_world_items.append(item_id)
	add_item(item_name, amount)
	award_xp(xp)
	return true

func reset_progress() -> void:
	relic_awakened = false
	collected_fragments.clear()
	claimed_world_items.clear()
	player_level = 1
	player_xp = 0
	gold = 0
	defeated_bosses.clear()
	inventory = {"Эфирный осколок": 0, "Зелье лечения": 2}
	save_game()
