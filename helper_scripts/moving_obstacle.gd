extends AnimatableBody3D

@export var min_speed: float = 3.0
@export var max_speed: float = 5.0
@onready var _speed: float = randf_range(3.0, 5.0)

func _ready() -> void:
	var _geometry_object: GeometryInstance3D
	var _hitbox_object: CollisionShape3D
	for child in get_children():
		if child is GeometryInstance3D:
			_geometry_object = child
		elif child is CollisionShape3D:
			_hitbox_object = child
			
	if _geometry_object.is_in_group("world_depression"):
		_geometry_object.transparency = GameManager.depression_transparency if GameManager.depression_transparency != null else 0
		if GameManager.depression_transparency > 0:
			_hitbox_object.disabled = true
	elif _geometry_object.is_in_group("world_happiness"):
		_geometry_object.transparency = GameManager.happiness_transparency if GameManager.depression_transparency != null else 0
		if GameManager.happiness_transparency > 0:
			_hitbox_object.disabled = true
		
		
func _physics_process(delta: float) -> void:
	position.x -= _speed * delta
