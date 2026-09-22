class_name FlameConfig
extends Resource
## Everything about how the flame drains and relights.
## Create one .tres from this and drag it onto FlameSystem's
## "config" export slot in the Inspector.

@export var base_drain: float = 1.5
@export var move_drain: float = 0.02
@export var fall_drain_threshold: float = 200.0
@export var fall_drain_amount: float = 10.0
@export var relight_amount: float = 100.0
@export var checkpoint_relight_amount: float = 100.0

## Stage cutoffs: flame value at or above each number gives that stage.
## Anything below stage_2_min and above 0 is stage 2. Exactly 0 is stage 1.
@export var stage_5_min: float = 80.0
@export var stage_4_min: float = 55.0
@export var stage_3_min: float = 30.0
@export var stage_2_min: float = 0.01

func get_stage(flame: float) -> int:
	if flame <= 0.0:
		return 1
	elif flame >= stage_5_min:
		return 5
	elif flame >= stage_4_min:
		return 4
	elif flame >= stage_3_min:
		return 3
	else:
		return 2
