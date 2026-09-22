class_name Player
extends CharacterBody2D
## Movement, jumping, and the hooks that later phases plug into.
## Attach this to the root node of player.tscn, then drag
## player_config.tres onto the "config" slot in the Inspector.

@export var config: PlayerConfig

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

# Set true by a WindZone (phase 6) while the player is inside one.
var in_wind: bool = false

# Set false at spawn once the flame system exists (phase 4/5).
# Left true for now so you can test movement on its own.
var can_move: bool = true


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump_buffer(delta)
	_handle_coyote_time(delta)

	if can_move:
		_handle_horizontal_movement(delta)
		_handle_jump()
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.friction * delta)

	var was_on_floor := is_on_floor()
	var fall_speed_before_land := velocity.y
	move_and_slide()

	if not was_on_floor and is_on_floor():
		_on_landed(fall_speed_before_land)

	$FlameSystem.update(delta, velocity, is_on_floor(), in_wind)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += config.gravity * delta
		velocity.y = min(velocity.y, config.max_fall_speed)
	else:
		velocity.y = 0.0


func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * config.run_speed, config.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.friction * delta)


func _handle_coyote_time(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = config.coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)


func _handle_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = config.jump_buffer_time
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)


func _handle_jump() -> void:
	var can_jump := _coyote_timer > 0.0 and _jump_buffer_timer > 0.0
	if can_jump:
		velocity.y = config.jump_velocity
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0

	# Variable jump height: cut the rise short if the button is released early.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5


func _on_landed(fall_speed: float) -> void:
	$FlameSystem.on_landed(fall_speed)


# Phase 6 hooks. Left as stubs so the QTE and hazard scripts have
# something to call once you build them.
func die() -> void:
	pass


func respawn(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	
	
func _ready() -> void:
	$FlameSystem.relight($FlameSystem.config.relight_amount)
