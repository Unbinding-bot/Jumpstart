class_name WindZone
extends Area2D
## Drop this over a stretch of level with a CollisionShape2D child
## covering the area, and add a CPUParticles2D child for the visual
## (small white squares, direction blowing sideways, in the editor --
## no script needed for that part).

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.in_wind = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.in_wind = false
