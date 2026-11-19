extends Node3D

## Put this script on the root node of every level.
## It does the boring stuff so you can focus on building:
##  - counts the coins in the level
##  - unlocks the goal flag once every coin is collected
##  - shows the win screen when you touch the unlocked flag
##  - makes any model without collision solid (so you can stand on it)

## The name shown on the win screen.
@export var level_name := "My Level"
## Turn off if you want a model to be walk-through (e.g. clouds).
@export var auto_collision := true

var coins_total := 0
var coins_collected := 0
var time := 0.0
var finished := false

var player: Node3D
var hud: Node


func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# Roughly match the Forward+ look when using the Compatibility renderer.
		if has_node("Sun"):
			$Sun.light_energy = 0.24
			$Sun.shadow_opacity = 0.85
		if has_node("Environment"):
			$Environment.environment.background_energy_multiplier = 0.25

	if Game.last_level_path == "":
		Game.last_level_path = scene_file_path

	if auto_collision:
		_add_missing_collision(self)

	player = get_tree().get_first_node_in_group("player")
	hud = get_tree().get_first_node_in_group("hud")
	coins_total = get_tree().get_nodes_in_group("coin").size()

	if player and player.has_signal("coin_collected"):
		player.coin_collected.connect(_on_coin_collected)

	var unlocked := coins_total == 0
	for flag in get_tree().get_nodes_in_group("goal"):
		flag.set_unlocked(unlocked, false)

	if hud:
		hud.set_coins(0, coins_total)
		if unlocked:
			hud.show_message("Find the flag!")
		else:
			hud.show_message("Collect all %d coins to unlock the flag!" % coins_total)


func _process(delta: float) -> void:
	if not finished:
		time += delta
		if hud:
			hud.set_time(time)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F1 or (event.keycode == KEY_T and event.ctrl_pressed):
			Game.go_to_title()


func _on_coin_collected(coins: int) -> void:
	coins_collected = coins
	if hud:
		hud.set_coins(coins_collected, coins_total)

	if coins_collected == coins_total:
		for flag in get_tree().get_nodes_in_group("goal"):
			flag.set_unlocked(true, true)
		if hud:
			hud.show_message("All coins found! The flag is unlocked - GO!", 3.0)
	elif coins_total - coins_collected <= 3 and hud:
		var left := coins_total - coins_collected
		hud.show_message("%d coin%s left!" % [left, "" if left == 1 else "s"], 1.5)


## Called by the goal flag when the player touches it.
func goal_touched() -> void:
	if finished or (player and player.get("dead")):
		return
	if coins_collected < coins_total:
		if hud:
			var left := coins_total - coins_collected
			hud.show_message("Locked! Find %d more coin%s." % [left, "" if left == 1 else "s"], 2.0)
		return

	finished = true
	Game.level_finished(scene_file_path, level_name, coins_collected, coins_total, time)
	if hud:
		hud.show_message("YOU DID IT!", 3.0)
	if player and player.has_method("celebrate"):
		player.celebrate()
	await get_tree().create_timer(2.0).timeout
	Game.show_win_screen()


# --- Auto collision -----------------------------------------------------------

func _add_missing_collision(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionObject3D:
			continue # Already handles its own physics (player, coins, flag...)
		if child.scene_file_path != "" and _has_collision(child):
			continue # A ready-made piece that already has collision
		if child.is_in_group("no_collision"):
			continue
		if child is MeshInstance3D and child.mesh != null:
			child.create_trimesh_collision()
		_add_missing_collision(child)


func _has_collision(node: Node) -> bool:
	if node is CollisionObject3D:
		return true
	for child in node.get_children():
		if _has_collision(child):
			return true
	return false
