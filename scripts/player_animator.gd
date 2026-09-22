class_name PlayerAnimator
extends AnimatedSprite2D
## Attach directly to an AnimatedSprite2D child of Player, named
## "Sprite" (or anything -- this script doesn't rely on its own
## name). Reads the Player's velocity and floor state every frame
## and picks the matching animation. Requires a SpriteFrames
## resource with animations named exactly:
##   off, idle, run, jump, fall_start, fall_loop
## See the setup notes for how to build that resource and set each
## animation's loop flag and speed.

enum State { OFF, IDLE, RUN, JUMP, FALL_START, FALL_LOOP }

## Horizontal speed below which the player counts as idle, not running.
@export var run_threshold: float = 10.0

var _player: Player
var _state: State = State.OFF


func _ready() -> void:
	print("PlayerAnimator ready, parent is: ", get_parent().name)  # TEMP: remove once confirmed working
	_player = get_parent() as Player
	animation_finished.connect(_on_animation_finished)
	play("off")


func _process(_delta: float) -> void:
	_update_facing()
	_update_state()


## Art faces right by default. Flips based on which direction is
## currently held, not on velocity -- so the turn is instant even
## while the body is still sliding the old way from momentum.
func _update_facing() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0.0:
		flip_h = false
	elif direction < 0.0:
		flip_h = true


func _update_state() -> void:
	if not _player.has_ignited():
		_set_state(State.OFF)
		return

	if _player.is_on_floor():
		# Landing, or already grounded: idle/run either way.
		if absf(_player.velocity.x) > run_threshold:
			_set_state(State.RUN)
		else:
			_set_state(State.IDLE)
	else:
		if _player.velocity.y < 0.0:
			_set_state(State.JUMP)
		else:
			# Falling. Only start fall_start on the transition into
			# falling -- once in fall_start or fall_loop, leave it
			# alone; the finished signal handles fall_start -> fall_loop.
			if _state != State.FALL_START and _state != State.FALL_LOOP:
				_set_state(State.FALL_START)


func _on_animation_finished() -> void:
	if _state == State.FALL_START:
		_set_state(State.FALL_LOOP)


func _set_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	match _state:
		State.OFF:
			play("off")
		State.IDLE:
			play("idle")
		State.RUN:
			play("run")
		State.JUMP:
			play("jump")
		State.FALL_START:
			play("fall_start")
		State.FALL_LOOP:
			play("fall_loop")
