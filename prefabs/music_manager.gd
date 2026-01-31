extends AudioStreamPlayer


@onready var _music_bus_index: int = AudioServer.get_bus_index("Music")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body

func _on_mask_toggled(is_depression: bool):
	pass

