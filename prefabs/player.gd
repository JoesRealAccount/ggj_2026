extends CharacterBody3D

const SPEED = 5.0
const JUMP_UP_VELOCITY = 8.0

enum JumpDirection {NONE, LEFT, RIGHT}


var spawn_position: Vector3
var jump_direction: JumpDirection = JumpDirection.NONE
var jump_x_velocity: float = 0.0

@export_range(1, 3, 1, "prefer_slider") var max_jump_count: int = 2
var current_jump_quota: int = 1
var target_rotation_y: float = -90.0 * (PI / 180.0) # Start facing right
const ROTATION_SPEED: float = 10.0 # Speed of rotation interpolation

@onready var model: Node3D = $Miwa

func _ready() -> void:
	spawn_position = global_position


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction for 2.5D movement (X-axis only).
	var input_dir := Input.get_axis("move_left", "move_right")

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			current_jump_quota = 1
			velocity.y = JUMP_UP_VELOCITY
			jump_direction = JumpDirection.NONE
			jump_x_velocity = 0.0
			if not is_zero_approx(input_dir):
				jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
				jump_x_velocity = input_dir * SPEED
		elif current_jump_quota <= max_jump_count:
			current_jump_quota += 1
			velocity.y = JUMP_UP_VELOCITY
			jump_direction = JumpDirection.NONE
			jump_x_velocity = 0.0
			if not is_zero_approx(input_dir):
				jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
				jump_x_velocity = input_dir * SPEED
	
	if is_on_floor():
		current_jump_quota = 1
		if input_dir:
			velocity.x = input_dir * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# If no direction was set on jump, allow one mid-air choice.
		if jump_direction == JumpDirection.NONE and not is_zero_approx(input_dir):
			jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
			jump_x_velocity = input_dir * SPEED
		var valid_input_dir := input_dir
		if jump_direction != JumpDirection.NONE and not is_zero_approx(input_dir):
			if (input_dir < 0 and jump_direction == JumpDirection.RIGHT) or (input_dir > 0 and jump_direction == JumpDirection.LEFT):
				valid_input_dir = 0.0
		# Only move while a valid direction key is pressed.
		if is_zero_approx(valid_input_dir):
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		else:
			# Lock movement direction if in the air.
			velocity.x = jump_x_velocity

	# Lock Z-axis movement
	velocity.z = 0

	move_and_slide()
	
	# Update target rotation based on movement direction
	if not is_zero_approx(input_dir):
		if input_dir < 0: # Moving left
			target_rotation_y = 90.0 * (PI / 180.0)
		else: # Moving right
			target_rotation_y = -90.0 * (PI / 180.0)
	
	# Smoothly interpolate model rotation
	model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, ROTATION_SPEED * delta)
	
	# Reset if fallen below -20 meters
	if global_position.y < -20:
		global_position = spawn_position
		_kill_player()

func _kill_player():
	SignalManager.player_death.emit()
	global_position = spawn_position
	velocity = Vector3.ZERO
