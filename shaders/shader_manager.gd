extends ColorRect

@export var _screen_overlay_rect: ColorRect

@export_group("Overlay Color")

@export var overlay_color: Color = Color.WHITE:
	set(new_value):
		new_value.a = overlay_color.a
		return new_value

@export var opacity: float = 1.0:
	set(new_value):
		overlay_color.a = new_value
		return new_value



func _ready() -> void:
	_screen_overlay_rect.color = overlay_color
	# tween_to_newscale(3.0)

func tween_to_newscale(tween_time_sec: float):
	get_tree().create_tween().tween_property(_screen_overlay_rect, "color", overlay_color, tween_time_sec)