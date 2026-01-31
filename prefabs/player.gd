extends CharacterBody3D

var spawn_position: Vector3

const SPEED = 5.0

const JUMP_UP_VELOCITY = 8.0
enum JumpDirection {NONE, LEFT, RIGHT}

var jump_direction: JumpDirection = JumpDirection.NONE
var jump_x_velocity: float = 0.0
@export_range(1, 3, 1, "prefer_slider") var max_jump_count: int = 1
var current_jump_quota: int = 1

var last_input_dir: float = 0.0

@export_range(1.0, 10.0) var teleport_distance: float = 5.0
var teleport_available: bool = false
var is_teleporting: bool = false
var teleport_start_pos: float = 0.0
var teleport_target_pos: float = 0.0
var teleport_progress: float = 0.0
var teleport_distance_traveled: float = 0.0
@export_range(0.1, 2.0) var teleport_duration: float = 0.3 # 300ms

var target_rotation_y: float = -90.0 * (PI / 180.0) # Start facing right
const ROTATION_SPEED: float = 10.0 # Speed of rotation interpolation

@onready var model: Node3D = $Miwa

@onready var sfx_jump: AudioStreamPlayer3D = %sfx_jump
@onready var sfx_death: AudioStreamPlayer3D = %sfx_death

func _ready() -> void:
	spawn_position = global_position
	SignalManager.player_death.connect(_kill_player)
	SignalManager.game_started.emit()


func _physics_process(delta: float) -> void:
	_handle_teleport(delta)
	_handle_gravity(delta)
	
	var input_dir := Input.get_axis("move_left", "move_right")
	
	_handle_jump(input_dir)
	_handle_movement(input_dir, delta)
	_handle_rotation(input_dir, delta)
	_check_fall()

func _handle_teleport(delta: float) -> void:
	if not is_teleporting:
		return
		
	teleport_progress += delta
	var t = clamp(teleport_progress / teleport_duration, 0.0, 1.0)
	# Use ease-out for smooth but fast feel
	t = 1.0 - pow(1.0 - t, 3.0)
	
	var new_x = lerp(teleport_start_pos, teleport_target_pos, t)
	var move_delta = new_x - global_position.x
	
	# Use test_move to check for collisions
	var collision = move_and_collide(Vector3(move_delta, 0, 0), true)
	
	if collision:
		# Hit something, stop teleporting
		is_teleporting = false
		teleport_available = false
	elif teleport_distance_traveled + abs(move_delta) >= teleport_distance:
		# Reached target distance
		var remaining = teleport_distance - teleport_distance_traveled
		global_position.x += sign(move_delta) * remaining
		is_teleporting = false
	else:
		# Continue moving
		global_position.x = new_x
		teleport_distance_traveled += abs(move_delta)
	
	if teleport_progress >= teleport_duration:
		is_teleporting = false

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_jump(input_dir: float) -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	
	if is_on_floor():
		sfx_jump.play()
		current_jump_quota = 1
		velocity.y = JUMP_UP_VELOCITY
		jump_direction = JumpDirection.NONE
		jump_x_velocity = 0.0
		teleport_available = true
		last_input_dir = 0.0
		if not is_zero_approx(input_dir):
			jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
			jump_x_velocity = input_dir * SPEED
			last_input_dir = input_dir
	elif current_jump_quota <= max_jump_count:
		sfx_jump.play()
		current_jump_quota += 1
		velocity.y = JUMP_UP_VELOCITY
		jump_direction = JumpDirection.NONE
		jump_x_velocity = 0.0
		teleport_available = true
		last_input_dir = 0.0
		if not is_zero_approx(input_dir):
			jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
			jump_x_velocity = input_dir * SPEED
			last_input_dir = input_dir

func _handle_movement(input_dir: float, delta: float) -> void:
	if is_on_floor():
		current_jump_quota = 1
		teleport_available = false
		last_input_dir = 0.0
		is_teleporting = false
		if input_dir:
			velocity.x = input_dir * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		_handle_air_teleport(input_dir)
		_handle_air_movement(input_dir, delta)
	
	# Lock Z-axis movement
	velocity.z = 0
	move_and_slide()

func _handle_air_teleport(input_dir: float) -> void:
	if not teleport_available or is_zero_approx(input_dir):
		return
	
	# Check if this is a second input
	var is_second_input = false
	if is_zero_approx(last_input_dir):
		# First input after being airborne with no input
		if jump_direction != JumpDirection.NONE:
			is_second_input = true
	elif sign(input_dir) == sign(last_input_dir):
		# Same direction pressed again
		is_second_input = true
	
	if is_second_input:
		# Start teleport animation
		var teleport_dir = sign(input_dir)
		is_teleporting = true
		teleport_start_pos = global_position.x
		teleport_target_pos = global_position.x + teleport_dir * teleport_distance
		teleport_progress = 0.0
		teleport_distance_traveled = 0.0
		teleport_available = false
	
	# Track input for teleport detection
	if not is_zero_approx(input_dir):
		last_input_dir = input_dir

func _handle_air_movement(input_dir: float, delta: float) -> void:
	# If no direction was set on jump, allow one mid-air choice
	if jump_direction == JumpDirection.NONE and not is_zero_approx(input_dir):
		jump_direction = JumpDirection.LEFT if input_dir < 0 else JumpDirection.RIGHT
		jump_x_velocity = input_dir * SPEED
	
	var valid_input_dir := input_dir
	if jump_direction != JumpDirection.NONE and not is_zero_approx(input_dir):
		if (input_dir < 0 and jump_direction == JumpDirection.RIGHT) or (input_dir > 0 and jump_direction == JumpDirection.LEFT):
			valid_input_dir = 0.0
	
	# Only move while a valid direction key is pressed
	if is_zero_approx(valid_input_dir):
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	else:
		# Lock movement direction if in the air
		velocity.x = jump_x_velocity

func _handle_rotation(input_dir: float, delta: float) -> void:
	# Update target rotation based on movement direction
	if not is_zero_approx(input_dir):
		if input_dir < 0: # Moving left
			target_rotation_y = 90.0 * (PI / 180.0)
		else: # Moving right
			target_rotation_y = -90.0 * (PI / 180.0)
	
	# Smoothly interpolate model rotation
	model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, ROTATION_SPEED * delta)

func _check_fall() -> void:
	# Reset if fallen below -20 meters
	if global_position.y < -20:
		global_position = spawn_position
		SignalManager.player_death.emit()

func _kill_player():
	sfx_death.play()
	global_position = spawn_position
	velocity = Vector3.ZERO
