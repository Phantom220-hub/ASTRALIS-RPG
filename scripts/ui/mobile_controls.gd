extends Control

const JOY_RADIUS := 76.0
const BUTTON_RADIUS := 42.0
var _joy_touch := -1
var _jump_touch := -1
var _dash_touch := -1
var _cast_touch := -1
var _interact_touch := -1
var _joy_vector := Vector2.ZERO

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for action in ["dash", "cast", "interact"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	var base := Vector2(112.0, size.y - 118.0)
	draw_circle(base, JOY_RADIUS, Color(0.06, 0.10, 0.17, 0.35))
	draw_arc(base, JOY_RADIUS, 0.0, TAU, 48, Color(0.72, 0.86, 1.0, 0.55), 2.0)
	draw_circle(base + _joy_vector * 43.0, 29.0, Color(0.42, 0.68, 0.92, 0.65))
	var jump_pos := Vector2(size.x - 92.0, size.y - 105.0)
	var dash_pos := Vector2(size.x - 190.0, size.y - 72.0)
	var cast_pos := Vector2(size.x - 190.0, size.y - 172.0)
	var interact_pos := Vector2(size.x - 92.0, size.y - 220.0)
	draw_circle(jump_pos, BUTTON_RADIUS, Color(0.18, 0.58, 0.86, 0.55))
	draw_arc(jump_pos, BUTTON_RADIUS, 0.0, TAU, 40, Color(0.82, 0.94, 1.0, 0.8), 2.0)
	draw_string(ThemeDB.fallback_font, jump_pos + Vector2(-14, 6), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_circle(dash_pos, BUTTON_RADIUS * 0.82, Color(0.25, 0.75, 0.72, 0.48))
	draw_arc(dash_pos, BUTTON_RADIUS * 0.82, 0.0, TAU, 40, Color(0.82, 1.0, 0.96, 0.8), 2.0)
	draw_string(ThemeDB.fallback_font, dash_pos + Vector2(-14, 5), "DASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_circle(cast_pos, BUTTON_RADIUS * 0.82, Color(0.42, 0.35, 0.86, 0.55))
	draw_arc(cast_pos, BUTTON_RADIUS * 0.82, 0.0, TAU, 40, Color(0.86, 0.82, 1.0, 0.85), 2.0)
	draw_string(ThemeDB.fallback_font, cast_pos + Vector2(-13, 5), "ECHO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_circle(interact_pos, BUTTON_RADIUS * 0.72, Color(0.78, 0.62, 0.28, 0.48))
	draw_arc(interact_pos, BUTTON_RADIUS * 0.72, 0.0, TAU, 40, Color(1.0, 0.91, 0.7, 0.85), 2.0)
	draw_string(ThemeDB.fallback_font, interact_pos + Vector2(-13, 5), "USE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var size := get_rect().size
			var jump_pos := Vector2(size.x - 92.0, size.y - 105.0)
			var dash_pos := Vector2(size.x - 190.0, size.y - 72.0)
			var cast_pos := Vector2(size.x - 190.0, size.y - 172.0)
			var interact_pos := Vector2(size.x - 92.0, size.y - 220.0)
			var is_button := event.position.distance_to(jump_pos) <= BUTTON_RADIUS * 1.25 or event.position.distance_to(dash_pos) <= BUTTON_RADIUS or event.position.distance_to(cast_pos) <= BUTTON_RADIUS or event.position.distance_to(interact_pos) <= BUTTON_RADIUS
			var is_joystick := event.position.x < size.x * 0.48 and event.position.y > size.y * 0.48
			if is_button or is_joystick:
				_handle_press(event.index, event.position)
				accept_event()
		else:
			if event.index in [_joy_touch, _jump_touch, _dash_touch, _cast_touch, _interact_touch]:
				_handle_release(event.index)
				accept_event()
	elif event is InputEventScreenDrag and event.index == _joy_touch:
		_update_joystick(event.position)
		accept_event()

func _handle_press(index: int, pos: Vector2) -> void:
	var size := get_rect().size
	var jump_pos := Vector2(size.x - 92.0, size.y - 105.0)
	var dash_pos := Vector2(size.x - 190.0, size.y - 72.0)
	var cast_pos := Vector2(size.x - 190.0, size.y - 172.0)
	var interact_pos := Vector2(size.x - 92.0, size.y - 220.0)
	if pos.distance_to(jump_pos) <= BUTTON_RADIUS * 1.25:
		_jump_touch = index
		Input.action_press("ui_accept")
	elif pos.distance_to(dash_pos) <= BUTTON_RADIUS:
		_dash_touch = index
		Input.action_press("dash")
	elif pos.distance_to(cast_pos) <= BUTTON_RADIUS:
		_cast_touch = index
		Input.action_press("cast")
	elif pos.distance_to(interact_pos) <= BUTTON_RADIUS:
		_interact_touch = index
		Input.action_press("interact")
	elif pos.x < size.x * 0.48 and pos.y > size.y * 0.48:
		_joy_touch = index
		_update_joystick(pos)

func _handle_release(index: int) -> void:
	if index == _joy_touch:
		_joy_touch = -1
		_joy_vector = Vector2.ZERO
		_apply_move_actions()
	if index == _jump_touch:
		_jump_touch = -1
		Input.action_release("ui_accept")
	if index == _dash_touch:
		_dash_touch = -1
		Input.action_release("dash")
	if index == _cast_touch:
		_cast_touch = -1
		Input.action_release("cast")
	if index == _interact_touch:
		_interact_touch = -1
		Input.action_release("interact")
	queue_redraw()

func _update_joystick(pos: Vector2) -> void:
	var center := Vector2(112.0, get_rect().size.y - 118.0)
	_joy_vector = ((pos - center) / JOY_RADIUS).limit_length(1.0)
	_apply_move_actions()
	queue_redraw()

func _apply_move_actions() -> void:
	_set_action("move_left", _joy_vector.x < -0.22)
	_set_action("move_right", _joy_vector.x > 0.22)
	_set_action("move_forward", _joy_vector.y < -0.22)
	_set_action("move_back", _joy_vector.y > 0.22)

func _set_action(action_name: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action_name)
	else:
		Input.action_release(action_name)
