class_name DifficultyConfig
extends Resource
## One of these per level. Create five .tres files from this script
## (difficulty_1.tres ... difficulty_5.tres) using the numbers in
## the plan doc, and drag the right one onto each level's
## "difficulty" export slot in the Inspector.

## Hit zone height as a fraction of the QTE bar (0 to 1).
@export_range(0.0, 1.0) var zone_size: float = 0.3

## Marker speed, in bar-lengths per second.
@export var marker_speed: float = 0.8

## Random range for how many hits the QTE needs.
@export var hits_min: int = 3
@export var hits_max: int = 3

## Starting seconds on the QTE timer, and seconds lost per miss.
@export var timer_seconds: float = 8.0
@export var miss_penalty: float = 0.5

## Multiplies all flame drain while in this level.
@export var drain_multiplier: float = 1.0

## Wind zone modifiers.
@export var wind_extra_hits: int = 1
@export var wind_zone_scale: float = 0.7
@export var wind_drain_multiplier: float = 3.0

func get_hits_needed(in_wind: bool) -> int:
	var hits := randi_range(hits_min, hits_max)
	if in_wind:
		hits += wind_extra_hits
	return hits
