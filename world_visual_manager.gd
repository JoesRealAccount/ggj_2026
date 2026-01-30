extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().set_group("world_happiness", "transparancy", 0.5)
