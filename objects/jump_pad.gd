extends Node3D

## Jump pad - step on it to get launched into the air!
## Change "Strength" in the Inspector to jump higher or lower.

@export var strength := 14.0

@onready var model: Node3D = $Model


func _ready() -> void:
	$Trigger.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	model.scale = model.scale.lerp(Vector3.ONE, delta * 10.0)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("bounce"):
		body.bounce(strength)
		model.scale = Vector3(1.3, 2.0, 1.3)
