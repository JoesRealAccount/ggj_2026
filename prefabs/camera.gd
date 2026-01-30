extends Camera3D


@export var lookAtTarget: Node3D
@export var offset: Vector3 = Vector3(0, 2, -6)
@export var smoothSpeed: float = 5.0

func _process(delta: float) -> void:
	if lookAtTarget:
		var desiredPosition: Vector3 = lookAtTarget.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desiredPosition, smoothSpeed * delta)
		look_at(lookAtTarget.global_transform.origin, Vector3.UP)
