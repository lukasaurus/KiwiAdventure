extends Control

## In-game HUD: coin counter, timer, pop-up messages and a controls hint.
## Built in code so it works in every level - just drop objects/hud.tscn in.

const FONT := preload("res://fonts/lilita_one_regular.ttf")
const COIN_ICON := preload("res://sprites/coin.png")

var coins_label: Label
var time_label: Label
var message_label: Label
var hint_label: Label
var message_tween: Tween


func _ready() -> void:
	add_to_group("hud")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Coins (top left)
	var icon := TextureRect.new()
	icon.texture = COIN_ICON
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(40, 36)
	icon.size = Vector2(56, 56)
	add_child(icon)

	coins_label = _make_label(48)
	coins_label.position = Vector2(108, 32)
	coins_label.text = "0 / 0"
	add_child(coins_label)

	# Timer (top right)
	time_label = _make_label(40)
	time_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.position = Vector2(-260, 36)
	time_label.size = Vector2(220, 60)
	time_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(time_label)

	# Pop-up message (top centre)
	message_label = _make_label(44)
	message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.size = Vector2(1000, 70)
	message_label.position = Vector2(-500, 110)
	message_label.pivot_offset = Vector2(500, 35)
	message_label.modulate.a = 0.0
	message_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.45))
	add_child(message_label)

	# Controls hint (bottom left) - fades after a few seconds
	hint_label = _make_label(22)
	hint_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hint_label.position = Vector2(40, -60)
	hint_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hint_label.text = "WASD move   •   SPACE jump (twice!)   •   MOUSE look   •   R restart   •   ESC free mouse"
	add_child(hint_label)
	var hint_tween := create_tween()
	hint_tween.tween_interval(8.0)
	hint_tween.tween_property(hint_label, "modulate:a", 0.0, 1.5)


func _make_label(size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_color_override("font_outline_color", Color(0.15, 0.1, 0.05, 0.6))
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func set_coins(collected: int, total: int) -> void:
	coins_label.text = "%d / %d" % [collected, total]
	coins_label.pivot_offset = coins_label.size / 2
	coins_label.scale = Vector2(1.3, 1.3)
	create_tween().tween_property(coins_label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	if total > 0 and collected >= total:
		coins_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))


func set_time(seconds: float) -> void:
	time_label.text = Game.format_time(seconds)


func show_message(text: String, duration := 3.0) -> void:
	message_label.text = text
	if message_tween:
		message_tween.kill()
	message_label.modulate.a = 1.0
	message_label.scale = Vector2(0.6, 0.6)
	message_tween = create_tween()
	message_tween.tween_property(message_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	message_tween.tween_interval(duration)
	message_tween.tween_property(message_label, "modulate:a", 0.0, 0.6)
