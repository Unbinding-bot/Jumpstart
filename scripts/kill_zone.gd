class_name KillZone
extends Area2D
## Drop this on any Area2D placed over a pit or hazard. Give it a
## CollisionShape2D child covering the danger area. Default collision
## layer/mask (1/1) is fine as long as Player is also left on the
## default layer; if you named layers in phase 1, set this node's
## Collision Mask to include the "player" layer.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
