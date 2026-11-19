extends Node3D

## Hazard - touching it sends the player back to the start!
## Optional: make it spin and/or slide back and forth (Inspector).

## Degrees per second to spin the model (saws look great with this).
@export var spin_speed := 0.0
## How far to slide (e.g. x = 3 slides 3 metres left/right). Leave at 0 to stay still.
@export var move_offset := Vector3.ZERO
## Seconds to slide one way.
@export var move_time := 1.5

@onready var model: Node3D = $Model
var start_position: Vector3


func _ready() -> void:
	$Hitbox.body_entered.connect(_on_body_entered)
	start_position = position
	if move_offset != Vector3.ZERO:
		var tween := create_tween().set_loops()
		tween.tween_property(self, "position", start_position + move_offset, move_time).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", start_position, move_time).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	if spin_speed != 0.0:
		model.rotate_object_local(Vector3.FORWARD, deg_to_rad(spin_speed) * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("die"):
		body.die()
