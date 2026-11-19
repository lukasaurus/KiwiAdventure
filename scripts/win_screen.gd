extends Control

## Win screen - shown after touching the unlocked flag.

@export var win_text := "YOU WIN!"

const FONT := preload("res://fonts/lilita_one_regular.ttf")
const COIN := preload("res://sprites/coin.png")
const PARTICLE := preload("res://sprites/particle.png")

var big_label: Label
var time := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()
	Audio.play("res://sounds/coin.ogg")


func _process(delta: float) -> void:
	time += delta
	if big_label:
		var s := 1.0 + sin(time * 4.0) * 0.06
		big_label.scale = Vector2(s, s)
		big_label.rotation = sin(time * 2.0) * 0.05


func _build() -> void:
	# Sunny sky gradient background
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.35, 0.7, 1.0))
	gradient.set_color(1, Color(1.0, 0.85, 0.45))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	var bg := TextureRect.new()
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Coins raining down
	var rain := CPUParticles2D.new()
	rain.texture = COIN
	rain.amount = 40
	rain.lifetime = 4.0
	rain.preprocess = 4.0
	rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain.emission_rect_extents = Vector2(1100, 10)
	rain.position = Vector2(640, -60)
	rain.direction = Vector2(0, 1)
	rain.spread = 10.0
	rain.gravity = Vector2(0, 250)
	rain.initial_velocity_min = 50.0
	rain.initial_velocity_max = 150.0
	rain.angular_velocity_min = -200.0
	rain.angular_velocity_max = 200.0
	rain.scale_amount_min = 0.12
	rain.scale_amount_max = 0.25
	add_child(rain)
	resized.connect(func(): rain.position.x = size.x / 2)

	# Sparkle burst
	var burst := CPUParticles2D.new()
	burst.texture = PARTICLE
	burst.amount = 60
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.lifetime = 1.6
	burst.spread = 180.0
	burst.gravity = Vector2(0, 300)
	burst.initial_velocity_min = 250.0
	burst.initial_velocity_max = 600.0
	burst.scale_amount_min = 0.2
	burst.scale_amount_max = 0.5
	burst.color = Color(1, 0.95, 0.5)
	burst.position = get_viewport_rect().size * Vector2(0.5, 0.3)
	rain.position.x = get_viewport_rect().size.x / 2
	add_child(burst)
	resized.connect(func(): burst.position = Vector2(size.x / 2, size.y * 0.3))

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	big_label = _label(win_text, 150, Color(1.0, 0.86, 0.2))
	big_label.add_theme_color_override("font_outline_color", Color(0.4, 0.2, 0.05))
	big_label.add_theme_constant_override("outline_size", 30)
	box.add_child(big_label)
	big_label.resized.connect(func(): big_label.pivot_offset = big_label.size / 2)

	if Game.last_level_name != "":
		box.add_child(_label(Game.last_level_name + " complete!", 44, Color.WHITE))

	box.add_child(_label("Coins:  %d / %d" % [Game.last_coins, Game.last_coins_total], 48, Color.WHITE))
	box.add_child(_label("Time:  " + Game.format_time(Game.last_time), 48, Color.WHITE))

	if Game.new_best and Game.best_times.size() > 0:
		var best := _label("NEW BEST TIME!", 40, Color(1.0, 0.5, 0.75))
		box.add_child(best)
		var tween := create_tween().set_loops()
		tween.tween_property(best, "modulate:a", 0.3, 0.4)
		tween.tween_property(best, "modulate:a", 1.0, 0.4)
	elif Game.best_times.has(Game.last_level_path):
		box.add_child(_label("Best:  " + Game.format_time(Game.best_times[Game.last_level_path]), 36, Color(1, 1, 1, 0.85)))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	box.add_child(spacer)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 30)
	box.add_child(buttons)

	var again := _button("PLAY AGAIN", Color(0.35, 0.78, 0.25))
	again.pressed.connect(Game.replay)
	buttons.add_child(again)

	var title := _button("TITLE SCREEN", Color(0.25, 0.6, 0.9))
	title.pressed.connect(Game.go_to_title)
	buttons.add_child(title)

	again.grab_focus()

	# Everything drops in
	box.modulate.a = 0.0
	box.position.y = -60
	var tween := create_tween().set_parallel()
	tween.tween_property(box, "modulate:a", 1.0, 0.5)
	tween.tween_property(box, "position:y", 0.0, 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 5)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.15, 0.3, 0.6))
	label.add_theme_constant_override("outline_size", 10)
	return label


func _button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(340, 76)
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 38)
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		button.add_theme_color_override(state, Color.WHITE)
	button.add_theme_stylebox_override("normal", _box(color))
	button.add_theme_stylebox_override("hover", _box(color.lightened(0.2)))
	button.add_theme_stylebox_override("focus", _box(color.lightened(0.2), true))
	button.add_theme_stylebox_override("pressed", _box(color.darkened(0.2)))
	button.mouse_entered.connect(func(): Audio.play("res://sounds/coin.ogg"))
	return button


func _box(color: Color, outline := false) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(24)
	box.border_color = color.darkened(0.35)
	box.border_width_bottom = 8
	if outline:
		box.border_color = Color.WHITE
		box.set_border_width_all(5)
		box.border_width_bottom = 8
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_size = 6
	box.shadow_offset = Vector2(0, 4)
	return box
