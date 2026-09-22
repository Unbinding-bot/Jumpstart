class_name Checkpoint
extends Area2D
## Give this a CollisionShape2D child over the checkpoint's art.
## Lights once and never again -- can't be reused to farm flame.

var _lit: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _lit or not (body is Player):
		return
	_lit = true
	body.touch_checkpoint(global_position)
	# Art phase hook: swap this node's sprite to its lit frame here.
