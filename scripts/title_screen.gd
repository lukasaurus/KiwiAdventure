extends Node3D

## Title screen. Change the text in the Inspector (click the TitleScreen node).

@export var game_title := "KIWI ADVENTURE"
@export var subtitle := "A Bathgate Park School game"
@export var orbit_speed := 8.0

const FONT := preload("res://fonts/lilita_one_regular.ttf")

@onready var pivot: Node3D = $CameraPivot
@onready var character_anim: AnimationPlayer = $Character/AnimationPlayer

var title_label: Label
var time := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if character_anim.has_animation("idle"):
		character_anim.play("idle")
	_build_ui()


func _process(delta: float) -> void:
	time += delta
	pivot.rotate_y(deg_to_rad(orbit_speed) * delta)
	if title_label:
		title_label.rotation = sin(time * 1.6) * 0.04
		var s := 1.0 + sin(time * 2.4) * 0.03
		title_label.scale = Vector2(s, s)
	# Little hop now and then
	var hop := maxf(0.0, sin(time * 3.0))
	$Character.position.y = 0.5 + pow(hop, 6.0) * 0.6


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(box)

	title_label = _label(game_title, 120, Color(1.0, 0.86, 0.25))
	title_label.add_theme_color_override("font_outline_color", Color(0.35, 0.18, 0.05))
	title_label.add_theme_constant_override("outline_size", 28)
	box.add_child(title_label)
	title_label.resized.connect(func(): title_label.pivot_offset = title_label.size / 2)

	var sub := _label(subtitle, 34, Color.WHITE)
	box.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	box.add_child(spacer)

	var play := _button("PLAY", Color(0.35, 0.78, 0.25))
	play.pressed.connect(func(): Game.play_level(Game.my_level))
	box.add_child(play)

	if ResourceLoader.exists(Game.example_level):
		var example := _button("EXAMPLE LEVEL", Color(0.25, 0.6, 0.9))
		example.pressed.connect(func(): Game.play_level(Game.example_level))
		box.add_child(example)

	var quit := _button("QUIT", Color(0.85, 0.35, 0.3))
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)

	var hint := _label("Collect every coin to unlock the flag!", 28, Color(1, 1, 1, 0.9))
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-400, -70)
	hint.size = Vector2(800, 40)
	root.add_child(hint)

	play.grab_focus()

	# Pop-in animation
	box.modulate.a = 0.0
	create_tween().tween_property(box, "modulate:a", 1.0, 0.6)


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 5)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.15, 0.7))
	label.add_theme_constant_override("outline_size", 10)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(380, 76)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 40)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.8))
	button.add_theme_stylebox_override("normal", _box(color))
	button.add_theme_stylebox_override("hover", _box(color.lightened(0.2)))
	button.add_theme_stylebox_override("focus", _box(color.lightened(0.2), true))
	button.add_theme_stylebox_override("pressed", _box(color.darkened(0.2)))
	button.pivot_offset = button.custom_minimum_size / 2
	button.mouse_entered.connect(func():
		Audio.play("res://sounds/coin.ogg")
		create_tween().tween_property(button, "scale", Vector2(1.08, 1.08), 0.1))
	button.mouse_exited.connect(func(): create_tween().tween_property(button, "scale", Vector2.ONE, 0.1))
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
