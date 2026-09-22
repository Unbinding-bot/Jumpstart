class_name Player
extends CharacterBody2D
## Movement, jumping, the flame lifecycle, and the QTE hookup.
## Attach this to the root node of player.tscn, then drag
## player_config.tres onto the "config" slot in the Inspector.
## Expects two children named exactly "FlameSystem" and "Qte".

@export var config: PlayerConfig

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

# Set true by a WindZone (phase 6) while the player is inside one.
var in_wind: bool = false

# True once the flame has been ignited for the first time. Before
# that, the player is frozen. After that, movement is never fully
# blocked by can_move again -- ashes has its own no-control skid.
var _has_ignited: bool = false
var can_move: bool = false

# True from the moment the flame goes to ashes until the QTE
# actually starts. Checked every physics frame: the QTE only
# fires once the player is grounded AND has skidded to a stop.
var _awaiting_qte: bool = false

var _has_checkpoint: bool = false
var _respawn_position: Vector2 = Vector2.ZERO
var _is_dying: bool = false


func _ready() -> void:
	IgniteInput.flicked.connect(_on_flicked)
	$FlameSystem.ashes_reached.connect(_on_ashes_reached)
	$Qte.succeeded.connect(_on_qte_succeeded)
	$Qte.failed.connect(_on_qte_failed)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump_buffer(delta)
	_handle_coyote_time(delta)

	if can_move:
		if _is_ashes():
			_handle_ashes_deceleration(delta)
		else:
			_handle_horizontal_movement(delta)
			_handle_jump()
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.friction * delta)

	var was_on_floor := is_on_floor()
	var fall_speed_before_land := velocity.y
	move_and_slide()

	if not was_on_floor and is_on_floor():
		_on_landed(fall_speed_before_land)

	if _awaiting_qte and is_on_floor() and is_zero_approx(velocity.x):
		_awaiting_qte = false
		_start_qte()

	$FlameSystem.update(delta, velocity, is_on_floor(), in_wind)


func _is_ashes() -> bool:
	return _has_ignited and not $FlameSystem.lit


func has_ignited() -> bool:
	return _has_ignited


func is_lit() -> bool:
	return $FlameSystem.lit


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += config.gravity * delta
		velocity.y = min(velocity.y, config.max_fall_speed)
	else:
		velocity.y = 0.0


func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		var rate := config.acceleration
		if sign(velocity.x) != 0.0 and sign(velocity.x) != sign(direction):
			rate = config.turn_deceleration
		velocity.x = move_toward(velocity.x, direction * config.run_speed, rate * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, config.friction * delta)


# No input read here on purpose -- the player has no control while
# ashes, this is a forced skid to a stop.
func _handle_ashes_deceleration(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, config.ashes_deceleration * delta)


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

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5


func _on_landed(fall_speed: float) -> void:
	$FlameSystem.on_landed(fall_speed)


func _on_flicked() -> void:
	if not _has_ignited:
		_has_ignited = true
		can_move = true
		$FlameSystem.relight($FlameSystem.config.relight_amount)


func _on_ashes_reached() -> void:
	_awaiting_qte = true


func touch_checkpoint(pos: Vector2) -> void:
	_has_checkpoint = true
	_respawn_position = pos
	$FlameSystem.relight($FlameSystem.config.checkpoint_relight_amount)


func _start_qte() -> void:
	get_tree().paused = true
	var difficulty: DifficultyConfig = $FlameSystem.difficulty if $FlameSystem.difficulty else DifficultyConfig.new()
	$Qte.start(difficulty, in_wind)


func _on_qte_succeeded() -> void:
	get_tree().paused = false
	$FlameSystem.relight($FlameSystem.config.relight_amount)


func _on_qte_failed() -> void:
	get_tree().paused = false
	die()


# Waits about 0.5 s, then respawns at the last checkpoint touched,
# or reloads the level if none has been touched yet. Called from
# QTE failure and from KillZone -- both may fire during a physics
# callback, so nothing here removes/reloads nodes synchronously.
func die() -> void:
	if _is_dying:
		return
	_is_dying = true
	get_tree().paused = false
	can_move = false

	await get_tree().create_timer(0.5).timeout

	_is_dying = false
	if _has_checkpoint:
		respawn(_respawn_position)
	else:
		get_tree().call_deferred("reload_current_scene")


func respawn(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	$FlameSystem.relight($FlameSystem.config.checkpoint_relight_amount)
	can_move = true
