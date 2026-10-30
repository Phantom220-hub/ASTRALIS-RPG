extends Control

var player: Node3D
var relic_active := false
var title_label: Label
var objective_label: Label
var hint_label: Label
var status_label: Label
var _pulse := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label = _make_label("ASTRALIS  /  THE FIRST ECHO", Vector2(28, 22), 23)
	objective_label = _make_label("ЦЕЛЬ  •  Найдите древний источник света", Vector2(30, 58), 17)
	hint_label = _make_label("Исследуйте руины и коснитесь светящегося реликта", Vector2(30, 88), 14)
	status_label = _make_label("ЭНЕРГИЯ  ■■■■■■■■■■     HP  100", Vector2(30, 124), 14)
	title_label.add_theme_color_override("font_color", Color(0.7, 0.91, 1.0))
	objective_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.69))
	hint_label.add_theme_color_override("font_color", Color(0.8, 0.88, 0.96))
	status_label.add_theme_color_override("font_color", Color(0.52, 0.92, 0.9))

func _process(delta: float) -> void:
	_pulse += delta
	if is_instance_valid(player):
		var energy := int(player.get("energy"))
		var hp := int(player.get("health"))
		status_label.text = "ЭНЕРГИЯ  %d%%     HP  %d" % [energy, hp]
		if player.has_method("get_interaction_hint"):
			var hint: String = player.get_interaction_hint()
			if not hint.is_empty():
				hint_label.text = hint
				hint_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.83))
			elif not relic_active:
				hint_label.text = "Исследуйте руины и найдите светящийся реликт"
				hint_label.add_theme_color_override("font_color", Color(0.8, 0.88, 0.96))

func set_relic_complete() -> void:
	relic_active = true
	objective_label.text = "ЦЕЛЬ ВЫПОЛНЕНА  •  Эхо пробудилось"
	hint_label.text = "Первый фрагмент памяти восстановлен"
	objective_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.77))

func _make_label(value: String, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
	return label
