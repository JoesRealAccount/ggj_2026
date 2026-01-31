extends Node3D

@export var speed: float = 5.0

func _physics_process(delta: float) -> void:
	position.x -= speed * delta


