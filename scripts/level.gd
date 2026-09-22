class_name Level
extends Node2D
## Attach to the root Node2D of every level scene. Requires a direct
## child named exactly "Player" (drag player.tscn in and make sure
## it keeps that name).

@export var difficulty: DifficultyConfig

@onready var _player: Player = $Player


func _ready() -> void:
	_player.get_node("FlameSystem").difficulty = difficulty


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		GameState.restart_level()
