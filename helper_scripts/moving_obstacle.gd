extends AnimatableBody3D

@export var kills: bool = false

@export var min_speed: float = 3.0
@export var max_speed: float = 5.0

@export_group("sine parameters")
@export var _amplitude: float = 0.2
@export var _frequency: float = 3.0
@export var _random_offset_strengh: float = 0.5

@export_group("rotation parameters")
@export var is_rotating: bool = true
@export var rotation_speed: float = 1.0
@export var random_rotation_speed: bool = true

@onready var _speed: float = randf_range(3.0, 5.0)
@onready var _rotation_speed: float = rotation_speed if not random_rotation_speed else randf_range(0.5, 2.0)
var _time: float
var _old_sine_pos: float
var _geometry_object: GeometryInstance3D

func _ready() -> void:
	var _hitbox_object: CollisionShape3D
	for child in get_children():
		if child is GeometryInstance3D:
			_geometry_object = child
		elif child is CollisionShape3D:
			_hitbox_object = child
	_amplitude = randf_range(_amplitude * _random_offset_strengh, _amplitude * (1+_random_offset_strengh))
	_frequency = randf_range(_frequency* _random_offset_strengh, _frequency * (1+_random_offset_strengh))
			
	if _geometry_object.is_in_group("world_depression"):
		_geometry_object.transparency = GameManager.depression_transparency if GameManager.depression_transparency != null else 0.0
		if GameManager.depression_transparency > 0:
			_hitbox_object.disabled = true
	elif _geometry_object.is_in_group("world_happiness"):
		_geometry_object.transparency = GameManager.happiness_transparency if GameManager.depression_transparency != null else 0.0
		if GameManager.happiness_transparency > 0:
			_hitbox_object.disabled = true
		
		
func _process(delta: float) -> void:
	if is_rotating and _geometry_object:
		_geometry_object.rotate_z((_rotation_speed / 3.0) * delta)

func _physics_process(delta: float) -> void:
	_time += delta
	var _current_sine_pos = (sin(_time*_frequency)-0.5)*_amplitude
	var _velocity: Vector3 = Vector3(-_speed * delta, _current_sine_pos - _old_sine_pos, 0.0)
	_old_sine_pos = _current_sine_pos
	var collision: KinematicCollision3D = move_and_collide(_velocity)
	if collision:
		var collider: Node3D = collision.get_collider()
		if collider.is_in_group("player") and kills:
			SignalManager.player_death.emit()
			queue_free()

	if position.x < -50.0:
		queue_free()
