class_name  ShaderOverlayManager
extends ColorRect

@export var _screen_overlay_rect: ColorRect

@export_group("Overlay Color")


@export var depression_overlay_color: Color = Color.BLACK


@export_group("Depressive Overlay Effect parameters")
@export_range(0.0, 1.0) var min_corner_effect_strengh = 0.1
@export_range(0.0, 1.0) var max_corner_effect_strengh = 0.5
@export_range(0.0, 1.0) var min_grayscale_effect_strengh = 0.3
@export_range(0.0, 1.0) var max_grayscale_effect_strengh = 1.0
@export var time_to_fully_apply_effect: float = 20.0


var active_overlay_color = Color(0.0, 0.0, 1.0, 0.0)

var current_overlay: overlay_types = overlay_types.HAPPYNESS:
	set(new_overlay):
		_kill_all_current_tweens()
		current_overlay = new_overlay
		if new_overlay == overlay_types.DEPRESSION:
			_set_overlay_strengh(min_corner_effect_strengh, min_grayscale_effect_strengh, 0)
			_set_overlay_strengh(max_corner_effect_strengh, max_grayscale_effect_strengh, time_to_fully_apply_effect)
		else:
			_set_overlay_strengh(0.0, 0.0, 0.0)
		return new_overlay

var _current_tweens:Array[Tween]

enum overlay_types{
	DEPRESSION,
	HAPPYNESS,
}

func _ready() -> void:
	_screen_overlay_rect.color = active_overlay_color
	SignalManager.world_toggled_is_depression.connect(_on_worlds_toggled)

func _on_worlds_toggled(is_depression: bool):
	match is_depression:
		true:
			current_overlay = overlay_types.DEPRESSION
		_:
			current_overlay = overlay_types.HAPPYNESS

func _kill_all_current_tweens():
	for tween: Tween in _current_tweens:
		tween.kill()
	_current_tweens.clear()

func _tween_to_newscale(new_color: Color, corner_effect_strengh: float, tween_time_sec: float):
	var tween1: Tween = create_tween()
	tween1.tween_property(_screen_overlay_rect, "color", new_color, tween_time_sec)
	var tween2: Tween = create_tween()
	tween2.tween_property(_screen_overlay_rect.material, "shader_parameter/edge_intensity", corner_effect_strengh, tween_time_sec)
	_current_tweens.append(tween1)
	_current_tweens.append(tween2)

func _set_overlay_strengh(corner_strengh: float, grayscale_strengh: float, delay_time: float):
	if current_overlay == overlay_types.DEPRESSION:
		corner_strengh = clamp(corner_strengh, min_corner_effect_strengh, max_corner_effect_strengh)
		grayscale_strengh = clamp(grayscale_strengh, min_grayscale_effect_strengh, max_grayscale_effect_strengh)
	var new_color = active_overlay_color
	new_color.a = grayscale_strengh
	_tween_to_newscale(new_color, corner_strengh, delay_time)
