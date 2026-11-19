extends Node3D

## Third-person camera that orbits the player.
##  Mouse        - look around (click the game window to grab the mouse)
##  Scroll wheel - zoom in / out
##  Arrow keys / right stick - also look around
##  Esc          - free the mouse again
## A SpringArm3D stops the camera from going through walls.

@export var target: Node3D

@export_group("Distance")
@export var distance := 6.0
@export var min_distance := 2.0
@export var max_distance := 14.0
## How high above the player's feet the camera looks.
@export var height := 1.0

@export_group("Looking")
@export var mouse_sensitivity := 0.2
@export var key_rotation_speed := 120.0
@export var min_pitch := -75.0
@export var max_pitch := 30.0
@export var invert_y := false

var yaw := 0.0
var pitch := -20.0

@onready var spring_arm: SpringArm3D = $SpringArm


func _ready() -> void:
	yaw = rotation_degrees.y
	pitch = clamp(rotation_degrees.x, min_pitch, max_pitch)
	if target:
		if target is CollisionObject3D:
			spring_arm.add_excluded_object(target.get_rid())
		global_position = target.global_position + Vector3.UP * height
	spring_arm.spring_length = distance
	_capture_mouse()


func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity * (-1.0 if invert_y else 1.0)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance -= 0.5
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance += 0.5
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_capture_mouse()
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	# Keyboard / gamepad looking
	yaw -= Input.get_axis("camera_left", "camera_right") * key_rotation_speed * delta
	pitch -= Input.get_axis("camera_up", "camera_down") * key_rotation_speed * delta
	distance += Input.get_axis("zoom_in", "zoom_out") * 10.0 * delta

	pitch = clamp(pitch, min_pitch, max_pitch)
	distance = clamp(distance, min_distance, max_distance)
	rotation_degrees = Vector3(pitch, yaw, 0)

	if target:
		var goal := target.global_position + Vector3.UP * height
		global_position = global_position.lerp(goal, clamp(delta * 12.0, 0.0, 1.0))

	spring_arm.spring_length = lerp(spring_arm.spring_length, distance, clamp(delta * 8.0, 0.0, 1.0))
