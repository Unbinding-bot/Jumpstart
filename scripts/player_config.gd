class_name PlayerConfig
extends Resource
## Every tunable number for player movement.
## Create one .tres from this and drag it onto the Player node's
## "config" export slot in the Inspector.

@export var run_speed: float = 90.0
@export var acceleration: float = 600.0
@export var friction: float = 800.0
@export var jump_velocity: float = -230.0
@export var gravity: float = 700.0
@export var max_fall_speed: float = 300.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
