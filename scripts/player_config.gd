class_name PlayerConfig
extends Resource
## Every tunable number for player movement.
## Create one .tres from this and drag it onto the Player node's
## "config" export slot in the Inspector.

@export var run_speed: float = 90.0
@export var acceleration: float = 600.0
@export var friction: float = 800.0

## Used instead of acceleration when the held direction is opposite
## the current velocity, so reversing direction feels snappy instead
## of drifting the old way while it ramps down and back up.
@export var turn_deceleration: float = 1200.0

@export var jump_velocity: float = -230.0
@export var gravity: float = 700.0
@export var max_fall_speed: float = 300.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

## How fast horizontal velocity decays toward 0 while ashes (px per
## second squared). The player has no control during this -- it's a
## forced skid to a stop, not slowed movement.
@export var ashes_deceleration: float = 500.0
