extends Node

@export var shader_overlay_manager: ShaderOverlayManager

func _ready() -> void:
	SignalManager.player_death.connect(_on_player_death)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mask"):
		match shader_overlay_manager.current_overlay:
			shader_overlay_manager.overlay_types.HAPPYNESS:
				SignalManager.world_toggled_is_depression.emit(true)
			_:
				SignalManager.world_toggled_is_depression.emit(false)

func _on_player_death():
	SignalManager.world_toggled_is_depression.emit(false)
