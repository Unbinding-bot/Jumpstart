extends Node
## Autoload. Register this in Project Settings -> Autoload as
## "IgniteInput" (name must match exactly, other scripts call it
## by that name). Reads the "ignite" action (mouse wheel down),
## debounces multi-events from one physical flick, and requires
## notches_required distinct notches within flick_window to
## count as one real flick.

signal flicked

## How many separate wheel notches make one flick. 1 = any notch
## counts immediately. 2 feels more like a real lighter flick.
@export var notches_required: int = 1

## Ignore any wheel event closer than this to the previous one.
## High-resolution mice/trackpads can send several events per notch.
@export var debounce_seconds: float = 0.05

## Notches must land within this window of each other to combine
## into one flick. A slow, separate scroll doesn't count.
@export var flick_window: float = 0.15

var _last_notch_time: float = -999.0
var _flick_start_time: float = -999.0
var _notch_count: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working while the QTE pauses the tree


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ignite"):
		return

	var now := Time.get_ticks_msec() / 1000.0

	if now - _last_notch_time < debounce_seconds:
		return
	_last_notch_time = now

	if now - _flick_start_time > flick_window:
		_notch_count = 0
		_flick_start_time = now

	_notch_count += 1
	if _notch_count >= notches_required:
		_notch_count = 0
		flicked.emit()
