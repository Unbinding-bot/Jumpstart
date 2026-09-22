class_name Qte
extends CanvasLayer
## The relight quick time event. Build the matching qte.tscn as a
## child of Player (see the setup notes) so every player instance
## carries its own QTE overlay with no per-level wiring needed.

signal succeeded
signal failed

@onready var _bar: ColorRect = %Bar
@onready var _zone: ColorRect = %Zone
@onready var _marker: ColorRect = %Marker
@onready var _timer_fill: ColorRect = %TimerFill
@onready var _hits_label: Label = %HitsLabel

var _timer_fill_full_width: float = 0.0

var _hits_needed: int = 0
var _timer: float = 0.0
var _timer_max: float = 1.0

var _marker_pos: float = 0.0  # 0 to 1, fraction down the bar
var _marker_dir: int = 1
var _marker_speed: float = 0.8  # bar-lengths per second

var _zone_size: float = 0.3  # fraction of bar height
var _zone_pos: float = 0.0   # top of the zone, 0 to (1 - zone_size)

var _miss_penalty: float = 0.5
var _active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps running while the tree is paused
	visible = false
	_timer_fill_full_width = _timer_fill.size.x
	IgniteInput.flicked.connect(_on_flicked)


func start(difficulty: DifficultyConfig, in_wind: bool) -> void:
	_hits_needed = randi_range(difficulty.hits_min, difficulty.hits_max)
	if in_wind:
		_hits_needed += difficulty.wind_extra_hits

	_zone_size = difficulty.zone_size * (difficulty.wind_zone_scale if in_wind else 1.0)
	_marker_speed = difficulty.marker_speed
	_miss_penalty = difficulty.miss_penalty
	_timer_max = difficulty.timer_seconds
	_timer = _timer_max

	_marker_pos = 0.0
	_marker_dir = 1
	_place_zone()
	_update_hits_label()

	_active = true
	visible = true


func _process(delta: float) -> void:
	if not _active:
		return

	_marker_pos += _marker_dir * _marker_speed * delta
	if _marker_pos >= 1.0:
		_marker_pos = 1.0
		_marker_dir = -1
	elif _marker_pos <= 0.0:
		_marker_pos = 0.0
		_marker_dir = 1

	_timer -= delta
	_update_visuals()

	if _timer <= 0.0:
		_finish(false)


func _on_flicked() -> void:
	if not _active:
		return

	if _marker_pos >= _zone_pos and _marker_pos <= _zone_pos + _zone_size:
		_hits_needed -= 1
		_update_hits_label()
		if _hits_needed <= 0:
			_finish(true)
		else:
			_place_zone()
	else:
		_timer -= _miss_penalty


func _place_zone() -> void:
	_zone_pos = randf() * (1.0 - _zone_size)


func _update_hits_label() -> void:
	_hits_label.text = "Hits left: %d" % _hits_needed


func _update_visuals() -> void:
	var bar_height := _bar.size.y
	_marker.position.y = _marker_pos * bar_height - _marker.size.y / 2.0
	_zone.position.y = _zone_pos * bar_height
	_zone.size.y = _zone_size * bar_height
	_timer_fill.size.x = _timer_fill_full_width * maxf(_timer / _timer_max, 0.0)


func _finish(success: bool) -> void:
	_active = false
	visible = false
	if success:
		succeeded.emit()
	else:
		failed.emit()
