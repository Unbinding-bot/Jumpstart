class_name Goal
extends Area2D
## Give this a CollisionShape2D child. Place it at the end of a level.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.next_level()
