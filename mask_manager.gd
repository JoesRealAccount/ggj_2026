extends Node

@export var shader_overlay_manager: ShaderOverlayManager

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mask"):
		match shader_overlay_manager.current_overlay:
			shader_overlay_manager.overlay_types.HAPPYNESS:
				shader_overlay_manager.current_overlay = shader_overlay_manager.overlay_types.DEPRESSION
			_:
				shader_overlay_manager.current_overlay = shader_overlay_manager.overlay_types.HAPPYNESS
