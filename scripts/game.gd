extends Node

## Global game manager (autoload named "Game").
## Remembers which level to play and the result of the last finished level.

const TITLE_SCREEN := "res://scenes/title_screen.tscn"
const WIN_SCREEN := "res://scenes/win_screen.tscn"

## The level the big PLAY button starts.
var my_level := "res://scenes/my_level.tscn"
var example_level := "res://scenes/example_level.tscn"

# Results from the last level that was finished (shown on the win screen).
var last_level_path := ""
var last_level_name := ""
var last_coins := 0
var last_coins_total := 0
var last_time := 0.0
var new_best := false
var best_times := {}


func play_level(path: String) -> void:
	last_level_path = path
	get_tree().change_scene_to_file(path)


func replay() -> void:
	play_level(last_level_path if last_level_path != "" else my_level)


func go_to_title() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(TITLE_SCREEN)


func level_finished(path: String, level_name: String, coins: int, total: int, time: float) -> void:
	last_level_path = path
	last_level_name = level_name
	last_coins = coins
	last_coins_total = total
	last_time = time
	new_best = not best_times.has(path) or time < best_times[path]
	if new_best:
		best_times[path] = time


func show_win_screen() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(WIN_SCREEN)


static func format_time(seconds: float) -> String:
	var minutes := int(seconds) / 60
	var secs := fmod(seconds, 60.0)
	return "%d:%04.1f" % [minutes, secs]
