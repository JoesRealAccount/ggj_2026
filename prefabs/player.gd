extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8.0

var starting_position: Vector3
var jump_direction: float = 0.0


func _ready() -> void:
	starting_position = global_position


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction for 2.5D movement (X-axis only).
	var input_dir := Input.get_axis("move_left", "move_right")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_direction = input_dir

	if is_on_floor():
		if input_dir:
			velocity.x = input_dir * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# If no direction was set on jump, allow one mid-air choice.
		if is_zero_approx(jump_direction) and not is_zero_approx(input_dir):
			jump_direction = input_dir
		var valid_input_dir := input_dir
		if not is_zero_approx(jump_direction) and not is_zero_approx(input_dir):
			if sign(input_dir) != sign(jump_direction):
				valid_input_dir = 0.0
		# Only move while a valid direction key is pressed.
		if is_zero_approx(valid_input_dir):
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		else:
			# Lock movement direction if in the air.
			velocity.x = jump_direction * SPEED
	
	# Lock Z-axis movement
	velocity.z = 0

	move_and_slide()
	
	# Reset if fallen below -20 meters
	if global_position.y < -20:
		global_position = starting_position
		velocity = Vector3.ZERO
