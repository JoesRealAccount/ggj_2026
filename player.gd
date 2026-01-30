extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8.0

var starting_position: Vector3


func _ready() -> void:
	starting_position = global_position


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction for 2.5D movement (X-axis only).
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir:
		velocity.x = input_dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Lock Z-axis movement
	velocity.z = 0

	move_and_slide()
	
	# Reset if fallen below -20 meters
	if global_position.y < -20:
		global_position = starting_position
		velocity = Vector3.ZERO
