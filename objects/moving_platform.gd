extends AnimatableBody3D

## Moving platform - slides back and forth and carries the player.
## Change "Move Offset" in the Inspector to choose where it goes:
##   (0, 3, 0) = up and down,  (4, 0, 0) = left and right.

@export var move_offset := Vector3(4, 0, 0)
## Seconds to travel one way.
@export var move_time := 2.0
## Seconds to wait at each end.
@export var wait_time := 0.5

var start_position: Vector3


func _ready() -> void:
	start_position = position
	var tween := create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", start_position + move_offset, move_time).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(wait_time)
	tween.tween_property(self, "position", start_position, move_time).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(wait_time)
