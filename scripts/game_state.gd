extends Node
## Autoload. Register in Project Settings -> Autoload with Node Name
## exactly "GameState". Tracks which level you're on and moves
## between them. Edit level_paths below once your level scenes exist
## -- script-only autoloads don't show exported arrays in the
## Inspector, so this is the place to change the list.

var level_paths: Array[String] = [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn",
	"res://scenes/level_5.tscn",
]

var current_index: int = 0


func next_level() -> void:
	current_index += 1
	if current_index >= level_paths.size():
		current_index = level_paths.size() - 1
		print("You win! (phase 10 replaces this print with a real win screen)")
		return
	get_tree().call_deferred("change_scene_to_file", level_paths[current_index])


func restart_level() -> void:
	get_tree().call_deferred("reload_current_scene")
