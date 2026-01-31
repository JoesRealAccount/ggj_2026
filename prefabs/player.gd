extends CharacterBody3D

var spawn_position: Vector3

const SPEED = 5.0

const JUMP_UP_VELOCITY = 8.0
enum JumpDirection {NONE, LEFT, RIGHT}

var jump_direction: JumpDirection = JumpDirection.NONE
var jump_x_velocity: float = 0.0
var _dash_velocity: float = 0.0:
	set(new_value):
		if new_value < 0:
			new_value = 1.0
		_dash_velocity = new_value
		return new_value
var _dash_tween: Tween

var input_dir: float = 0.0

@export_range(1, 3, 1, "prefer_slider") var max_jump_count: int = 1
@onready var _current_double_jumps: int = max_jump_count

var last_input_dir: float = 0.0
@export var _dash_strengh: float = 20.0

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
	_handle_gravity(delta)
	
	input_dir = Input.get_axis("move_left", "move_right")
	
	_handle_jump()
	_handle_movement(delta)
	_handle_rotation(delta)
	_check_fall()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		_set_jump_dir_to_input_dir()
		_dash_velocity = _dash_strengh
		if (_dash_tween):
			_dash_tween.stop()
		_dash_tween = create_tween()
		_dash_tween.tween_property(self, "_dash_velocity", 0, 0.3).set_ease(Tween.EASE_OUT)
		

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	
	if is_on_floor():
		velocity.y = JUMP_UP_VELOCITY
		sfx_jump.play()
		_current_double_jumps = max_jump_count
		_set_jump_dir_to_input_dir()
		
	elif _current_double_jumps > 0:
		velocity.y = JUMP_UP_VELOCITY
		sfx_jump.play()
		_current_double_jumps -= 1

func _set_jump_dir_to_input_dir():
	if input_dir < 0:
		jump_direction = JumpDirection.LEFT
	else:
		jump_direction = JumpDirection.RIGHT




func _handle_movement(delta: float) -> void:
	if is_on_floor():
		jump_direction = JumpDirection.NONE
		if input_dir:
			velocity.x = input_dir * (SPEED + _dash_velocity)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	else:
		if input_dir && _is_input_jump_direction(input_dir):
			velocity.x = input_dir * (SPEED + _dash_velocity)
		else:
			velocity.x = move_toward(velocity.x, 0, 0.5 * delta)
	
	# Lock Z-axis movement
	velocity.z = 0
	move_and_slide()

func _is_input_jump_direction(input: float) -> bool:
	match jump_direction:
		JumpDirection.LEFT:
			if input < 0:
				return true
			else:
				return false
		JumpDirection.RIGHT:
			if input > 0:
				return true
			else:
				return false
		_:
			if input <0:
				jump_direction = JumpDirection.LEFT
			else:
				jump_direction = JumpDirection.RIGHT
			return true

func _handle_rotation(delta: float) -> void:
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
	SignalManager.game_started.emit()
