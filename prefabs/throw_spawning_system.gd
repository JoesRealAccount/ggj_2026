extends Node3D


@export var throwable_objects: Array[PackedScene] = []
@export var spawn_interval: float = 2.0
@export var object_speed: float = 10.0
@export var spawn_x: float = 17.0
@export var spawn_y_min: float = 0.8
@export var spawn_y_max: float = 15.0
@export var spawn_z: float = 0.0

var spawn_timer: float = 0.0


func _process(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval and throwable_objects.size() > 0:
		spawn_random_object()
		spawn_timer = 0.0


func spawn_random_object() -> void:
	# Pick a random object from the collection
	var random_object = throwable_objects[randi() % throwable_objects.size()]
	
	if random_object == null:
		return
	
	# Instantiate the object
	var instance = random_object.instantiate()
	add_child(instance)
	
	# Set random spawn position
	var random_y = randf_range(spawn_y_min, spawn_y_max)
	instance.position = Vector3(spawn_x, random_y, spawn_z)
	
	# Add velocity component to move from right to left
	if instance.has_node(".") and instance.get_script():
		# If the instance has physics, try to apply velocity
		if instance is RigidBody3D:
			instance.linear_velocity = Vector3(-object_speed, 0, 0)
	
	# Alternative: use a tween to animate position from right to left
	var tween = create_tween()
	tween.tween_property(instance, "position:x", -17.0, 40.0 / object_speed)
	tween.tween_callback(instance.queue_free)