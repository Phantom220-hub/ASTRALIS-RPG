extends Control

var player: Node3D
var relic_active := false
var title_label: Label
var objective_label: Label
var hint_label: Label
var status_label: Label
var pause_panel: PanelContainer
var overlay_panel: PanelContainer
var _pulse := 0.0
var fps_label: Label
var progression_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	title_label = _make_label("ASTRALIS  /  ECHOES OF THE LOST WORLD", Vector2(28, 18), 21)
	objective_label = _make_label("ЦЕЛЬ  •  Найдите древний источник света", Vector2(30, 52), 16)
	hint_label = _make_label("Исследуйте руины и найдите светящийся реликт", Vector2(30, 80), 13)
	status_label = _make_label("ЭНЕРГИЯ  100%     HP  100", Vector2(30, 110), 14)
	fps_label = _make_label("FPS: --", Vector2(30, 136), 12)
	progression_label = _make_label("УРОВЕНЬ 1  •  XP 0/100  •  ЗОЛОТО 0", Vector2(30, 158), 12)
	title_label.add_theme_color_override("font_color", Color(0.7, 0.91, 1.0))
	objective_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.69))
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.88, 0.96))
	status_label.add_theme_color_override("font_color", Color(0.52, 0.92, 0.9))
	var pause_button := Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(get_viewport_rect().size.x - 68, 18)
	pause_button.size = Vector2(48, 42)
	pause_button.pressed.connect(_toggle_pause)
	add_child(pause_button)
	_add_top_button("СУМКА", 178, _show_inventory)
	_add_top_button("ЗАДАНИЯ", 286, _show_quests)
	get_viewport().size_changed.connect(_reposition_top_buttons)
	_show_title_screen()

func _process(delta: float) -> void:
	_pulse += delta
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	if SaveManager.defeated_bosses.has("NYTHERA — Queen of the Void"):
		objective_label.text = "ГЛАВА ЗАВЕРШЕНА  •  Эхо мира восстановлено"
	elif SaveManager.defeated_bosses.has("VARKHOS — Fallen Guardian"):
		objective_label.text = "ФИНАЛЬНАЯ ЦЕЛЬ  •  Найдите NYTHERA в ледяных руинах"
	elif SaveManager.relic_awakened:
		objective_label.text = "ГЛАВНАЯ ЦЕЛЬ  •  Победите VARKHOS у древних руин"
	else:
		objective_label.text = "ЦЕЛЬ  •  Найдите древний источник света"
	if is_instance_valid(player):
		status_label.text = "ЭНЕРГИЯ  %d%%     HP  %d" % [int(player.get("energy")), int(player.get("health"))]
		progression_label.text = "УРОВЕНЬ %d  •  XP %d/%d  •  ЗОЛОТО %d" % [SaveManager.player_level, SaveManager.player_xp, SaveManager.player_level * 100, SaveManager.gold]
		if player.has_method("get_interaction_hint"):
			var hint: String = player.get_interaction_hint()
			if not hint.is_empty():
				hint_label.text = hint
				hint_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.83))
			elif not relic_active:
				hint_label.text = "Исследуйте руины и найдите светящийся реликт"
				hint_label.add_theme_color_override("font_color", Color(0.8, 0.88, 0.96))

func _add_top_button(caption: String, offset: float, callback: Callable) -> void:
	var button := Button.new()
	button.name = caption
	button.text = caption
	button.position = Vector2(get_viewport_rect().size.x - offset, 18)
	button.size = Vector2(98, 42)
	button.add_theme_font_size_override("font_size", 12)
	button.pressed.connect(callback)
	add_child(button)

func _reposition_top_buttons() -> void:
	for button_name in ["СУМКА", "ЗАДАНИЯ"]:
		var button := get_node_or_null(button_name) as Button
		if button:
			button.position.x = get_viewport_rect().size.x - (178.0 if button_name == "СУМКА" else 286.0)
	var pause := get_node_or_null("PauseButton") as Button
	if pause:
		pause.position.x = get_viewport_rect().size.x - 68.0

func set_relic_complete() -> void:
	relic_active = true
	objective_label.text = "ЦЕЛЬ ВЫПОЛНЕНА  •  Эхо пробудилось"
	hint_label.text = "Первый фрагмент памяти восстановлен"
	objective_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.77))

func _show_inventory() -> void:
	var lines: Array[String] = ["ЗОЛОТО: %d" % SaveManager.gold, ""]
	for item in SaveManager.inventory:
		lines.append("%s  ×  %d" % [item, int(SaveManager.inventory[item])])
	lines.append("")
	lines.append("Зелье лечения восстанавливает 45 HP.")
	_show_overlay("ИНВЕНТАРЬ", "\n".join(lines), true)

func _show_quests() -> void:
	var first := "Пробудить древний реликт: " + ("ВЫПОЛНЕНО" if SaveManager.relic_awakened else "НЕ ВЫПОЛНЕНО")
	var second := "Победить VARKHOS: " + ("ВЫПОЛНЕНО" if SaveManager.defeated_bosses.has("VARKHOS — Fallen Guardian") else "НЕ ВЫПОЛНЕНО")
	var third := "Победить NYTHERA: " + ("ВЫПОЛНЕНО" if SaveManager.defeated_bosses.has("NYTHERA — Queen of the Void") else "НЕ ВЫПОЛНЕНО")
	var fragments := "Собрать эхо-фрагменты: %d / 8" % SaveManager.collected_fragments.size()
	_show_overlay("ЖУРНАЛ ЗАДАНИЙ", first + "\n\n" + second + "\n\n" + third + "\n\n" + fragments, false)

func _show_overlay(title_text: String, body_text: String, can_heal: bool) -> void:
	if is_instance_valid(overlay_panel):
		overlay_panel.queue_free()
	overlay_panel = PanelContainer.new()
	overlay_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	overlay_panel.position = Vector2(-210, -175)
	overlay_panel.size = Vector2(420, 350)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	overlay_panel.add_child(box)
	var heading := Label.new()
	heading.text = title_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	box.add_child(heading)
	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	if can_heal:
		var heal := Button.new()
		heal.text = "Использовать зелье"
		heal.pressed.connect(_use_healing_potion)
		box.add_child(heal)
	var close := Button.new()
	close.text = "ЗАКРЫТЬ"
	close.pressed.connect(func():
		overlay_panel.queue_free()
		overlay_panel = null
	)
	box.add_child(close)
	add_child(overlay_panel)

func _use_healing_potion() -> void:
	if int(SaveManager.inventory.get("Зелье лечения", 0)) <= 0 or not is_instance_valid(player):
		return
	SaveManager.inventory["Зелье лечения"] -= 1
	player.set("health", mini(100, int(player.get("health")) + 45))
	SaveManager.save_game()
	_show_inventory()

func _toggle_pause() -> void:
	if is_instance_valid(pause_panel):
		pause_panel.queue_free()
		pause_panel = null
		get_tree().paused = false
		return
	get_tree().paused = true
	pause_panel = PanelContainer.new()
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_panel.position = Vector2(-170, -125)
	pause_panel.size = Vector2(340, 250)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	pause_panel.add_child(box)
	var heading := Label.new()
	heading.text = "ПАУЗА"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 24)
	box.add_child(heading)
	var resume := Button.new()
	resume.text = "Продолжить"
	resume.pressed.connect(_toggle_pause)
	box.add_child(resume)
	var reset := Button.new()
	reset.text = "Начать заново"
	reset.pressed.connect(_reset_game)
	box.add_child(reset)
	add_child(pause_panel)

func _reset_game() -> void:
	get_tree().paused = false
	SaveManager.reset_progress()
	get_tree().reload_current_scene()

func _make_label(value: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
	return label


func _show_title_screen() -> void:
	get_tree().paused = true
	var backdrop := ColorRect.new()
	backdrop.name = "TitleScreen"
	backdrop.process_mode = Node.PROCESS_MODE_ALWAYS
	backdrop.color = Color(0.015, 0.035, 0.085, 0.96)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-190, -170)
	layout.size = Vector2(380, 340)
	layout.add_theme_constant_override("separation", 18)
	backdrop.add_child(layout)
	var title := Label.new()
	title.text = "ASTRALIS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.45, 0.84, 1.0))
	layout.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "ECHOES OF THE LOST WORLD"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	layout.add_child(subtitle)
	var story := Label.new()
	story.text = "Мир потерял своё эхо.\nНайди фрагменты памяти и пробуди древнюю силу."
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(story)
	var continue_button := Button.new()
	continue_button.text = "ПРОДОЛЖИТЬ"
	continue_button.custom_minimum_size.y = 52
	continue_button.pressed.connect(func():
		backdrop.queue_free()
		get_tree().paused = false
	)
	layout.add_child(continue_button)
	var new_game := Button.new()
	new_game.text = "НОВАЯ ИГРА"
	new_game.custom_minimum_size.y = 48
	new_game.pressed.connect(func():
		SaveManager.reset_progress()
		get_tree().reload_current_scene()
	)
	layout.add_child(new_game)
	var hint := Label.new()
	hint.text = "Мобильное управление • Исследование • Битвы с боссами"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 11)
	layout.add_child(hint)
	add_child(backdrop)
