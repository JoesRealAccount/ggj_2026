extends ColorRect

@export var _screen_overlay_rect: ColorRect

@export_group("Overlay Color")


@export var depression_overlay_color: Color = Color.BLACK

var active_overlay_color = Color(0.0, 0.0, 1.0, 0.0)

@export_group("Depressive Overlay Effect parameters")
@export_range(0.0, 1.0) var min_corner_effect_strengh = 0.1
@export_range(0.0, 1.0) var max_corner_effect_strengh = 0.5
@export_range(0.0, 1.0) var min_grayscale_effect_strengh = 0.3
@export_range(0.0, 1.0) var max_grayscale_effect_strengh = 1.0
@export var time_to_fully_apply_effect: float = 20.0


var current_overlay: overlay_types:
	set(new_overlay):
		if new_overlay == overlay_types.DEPRESSION:
			_set_overlay_strengh(min_corner_effect_strengh, min_grayscale_effect_strengh, 0)
			_set_overlay_strengh(max_corner_effect_strengh, max_grayscale_effect_strengh, time_to_fully_apply_effect) 
		else:
			_set_overlay_strengh(0.0, 0.0, 0.0)
		return new_overlay

enum overlay_types{
	DEPRESSION,
	HAPPYNESS,
}

func _ready() -> void:
	_screen_overlay_rect.color = active_overlay_color

func _tween_to_newscale(new_color: Color, corner_effect_strengh: float, tween_time_sec: float):
	get_tree().create_tween().tween_property(_screen_overlay_rect, "color", new_color, tween_time_sec)
	get_tree().create_tween().tween_property(_screen_overlay_rect.material, "shader_parameter/edge_intensity", corner_effect_strengh, tween_time_sec)

func _set_overlay_strengh(corner_strengh: float, grayscale_strengh: float, delay_time: float):
	if current_overlay == overlay_types.DEPRESSION:
		corner_strengh = clamp(corner_strengh, min_corner_effect_strengh, max_corner_effect_strengh)
		grayscale_strengh = clamp(grayscale_strengh, min_grayscale_effect_strengh, max_grayscale_effect_strengh)
	var new_color = active_overlay_color
	new_color.a = grayscale_strengh
	_tween_to_newscale(new_color, corner_strengh, delay_time)
