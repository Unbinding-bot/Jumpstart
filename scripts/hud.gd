class_name FlameHud
extends CanvasLayer
## Placeholder HUD. Shows the flame number as text and changes a
## box's color per stage. Swap the ColorRect for the real animated
## fire sprite in the art phase; the logic below stays the same.

@export var flame_system: FlameSystem

@onready var _label: Label = %FlameLabel
@onready var _stage_box: ColorRect = %StageColor

var _stage_colors: Array[Color] = [
	Color(0.35, 0.35, 0.35),  # 1: ashes
	Color(0.55, 0.1, 0.05),   # 2: barely there
	Color(0.8, 0.3, 0.05),    # 3: tiny flame
	Color(0.95, 0.5, 0.05),   # 4: weaker flame
	Color(1.0, 0.75, 0.1),    # 5: full bright
]


func _ready() -> void:
	if flame_system == null:
		push_warning("FlameHud has no flame_system assigned.")
		return
	flame_system.stage_changed.connect(_on_stage_changed)
	_on_stage_changed(flame_system.get_stage())


func _process(_delta: float) -> void:
	if flame_system == null:
		return
	_label.text = "Flame: %.0f  (stage %d)" % [flame_system.flame, flame_system.get_stage()]


func _on_stage_changed(stage: int) -> void:
	_stage_box.color = _stage_colors[stage - 1]
