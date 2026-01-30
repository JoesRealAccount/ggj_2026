extends SpotLight3D

@export var target: Node3D


func _process(_delta: float) -> void:
	if target:
		look_at(target.global_transform.origin, Vector3.UP)