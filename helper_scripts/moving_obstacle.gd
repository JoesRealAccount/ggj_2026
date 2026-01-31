extends Node3D

@export var min_speed: float = 3.0
@export var max_speed: float = 5.0
@onready var _speed: float = randf_range(3.0, 5.0)

func _physics_process(delta: float) -> void:
	position.x -= _speed * delta


