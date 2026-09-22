class_name FlameSystem
extends Node
## Child node of Player. Owns the flame value and everything that
## drains or relights it. The QTE and Checkpoint scripts (phases 5
## and 6) will both call relight() so there's one path in.

signal stage_changed(stage: int)
signal ashes_reached
signal relit

@export var config: FlameConfig

## Assigned by the level root once levels exist (phase 6/7).
## Left unset for now, drain multipliers just default to 1.0
## so you can test the flame system before levels exist.
var difficulty: DifficultyConfig

var flame: float = 0.0
var lit: bool = false

var _stage: int = 0


func _ready() -> void:
	_stage = config.get_stage(flame)


## Call every physics frame from Player._physics_process.
func update(delta: float, velocity: Vector2, _on_floor: bool, in_wind: bool) -> void:
	if not lit:
		return

	var drain_multiplier := difficulty.drain_multiplier if difficulty else 1.0
	var wind_multiplier := 1.0
	if in_wind:
		wind_multiplier = difficulty.wind_drain_multiplier if difficulty else 1.0

	var drain_per_second := (config.base_drain + absf(velocity.x) * config.move_drain) \
		* drain_multiplier * wind_multiplier

	_apply_drain(drain_per_second * delta)


## Call once from Player when a landing is detected, passing the
## fall speed captured just before move_and_slide() zeroed it out.
func on_landed(fall_speed: float) -> void:
	if not lit:
		return
	if fall_speed < config.fall_drain_threshold:
		return
	var over := fall_speed / config.fall_drain_threshold
	_apply_drain(config.fall_drain_amount * over)


## The single way anything relights the flame. QTE success and
## checkpoints both call this with their own amount.
func relight(amount: float) -> void:
	lit = true
	flame = clampf(amount, 0.0, 100.0)
	_update_stage()
	relit.emit()


func get_stage() -> int:
	return _stage


func _apply_drain(amount: float) -> void:
	if flame <= 0.0:
		return
	flame = maxf(flame - amount, 0.0)
	_update_stage()
	if flame <= 0.0:
		lit = false
		ashes_reached.emit()


func _update_stage() -> void:
	var new_stage := config.get_stage(flame)
	if new_stage != _stage:
		_stage = new_stage
		stage_changed.emit(_stage)
