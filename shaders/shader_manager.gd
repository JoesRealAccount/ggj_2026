extends ColorRect

@export var _screen_overlay_rect: ColorRect

@export_group("Overlay Color")


@export var normal_color: Color = Color(0.0, 0.0, 1.0, 0.0)
@export var depressive_overlay_color = Color.BLACK
@export var happiness_overlay_color = Color.GREEN

var active_overlay_color: Color = Color.BLACK

var current_overlay: overlay_types = overlay_types.DEPRESSION:
	set(new_overlay):
		if new_overlay != current_overlay:
			if new_overlay == overlay_types.DEPRESSION:
				active_overlay_color = depressive_overlay_color
			else:
				active_overlay_color = happiness_overlay_color
		return new_overlay

enum overlay_types{
	DEPRESSION,
	HAPPYNESS,
}

func _ready() -> void:
	_screen_overlay_rect.color = normal_color

func _tween_to_newscale(new_color: Color, tween_time_sec: float):
	get_tree().create_tween().tween_property(_screen_overlay_rect, "color", new_color, tween_time_sec)

func set_overlay_strengh(strengh: float):
	strengh = clamp(strengh, 0.0, 1.0)
	var new_color = active_overlay_color
	new_color.a = strengh
	_tween_to_newscale(new_color, 1.0)
