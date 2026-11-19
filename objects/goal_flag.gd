extends Area3D

## The goal! It starts LOCKED (see-through, with a padlock above it).
## Collect every coin in the level and it unlocks.
## Touch it once it's unlocked to win.

var unlocked := false

@onready var flag_model: Node3D = $Flag
@onready var lock_model: Node3D = $Lock
@onready var sparkles: CPUParticles3D = $Sparkles
@onready var glow: OmniLight3D = $Glow


func _ready() -> void:
	add_to_group("goal")
	body_entered.connect(_on_body_entered)
	_apply_look(false)


func _process(delta: float) -> void:
	if lock_model.visible:
		lock_model.rotate_y(delta * 2.0)
		lock_model.position.y = 1.7 + sin(Time.get_ticks_msec() * 0.003) * 0.1


func set_unlocked(value: bool, celebrate := true) -> void:
	if value == unlocked and not celebrate:
		_apply_look(value)
		return
	unlocked = value
	_apply_look(value)
	if value and celebrate:
		Audio.play("res://sounds/break.ogg")
		flag_model.scale = Vector3(0.6, 1.6, 0.6)
		var tween := create_tween()
		tween.tween_property(flag_model, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _apply_look(is_unlocked: bool) -> void:
	lock_model.visible = not is_unlocked
	sparkles.emitting = is_unlocked
	glow.visible = is_unlocked
	for mesh in flag_model.find_children("*", "GeometryInstance3D", true, false):
		mesh.transparency = 0.0 if is_unlocked else 0.65


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var level := get_tree().current_scene
	if level and level.has_method("goal_touched"):
		level.goal_touched()
