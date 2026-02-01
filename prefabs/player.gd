extends CharacterBody3D


const SPEED = 5.0
const ROTATION_SPEED: float = 10.0 # Speed of rotation interpolation

enum JumpDirection {NONE, LEFT, RIGHT}

@export_range(1, 10, 1, "prefer_slider") var _max_jump_count: int = 1
@export var _jump_strengh = 8.0

@export_range(1, 10, 1, "prefer_slider") var _max_airdash_count: int = 1
@export var _dash_strengh: float = 20.0

## The amount of time it takes the player to stop once they stoped actively moving in a direction
@export var _velocity_decay_speed: float = 1.0
@export var _floor_velocity_decay_multiplier: float = 2.0

var spawn_position: Vector3

var jump_direction: JumpDirection = JumpDirection.NONE
var jump_x_velocity: float = 0.0
var _dash_velocity: float = 0.0:
	set(new_value):
		if new_value < 0:
			new_value = 1.0
		_dash_velocity = new_value
		return new_value
var _dash_tween: Tween

var _is_dead: bool = false

var input_dir: float = 0.0:
	set(new_value):
		if new_value != 0:
			_last_input_dir = new_value
		input_dir = new_value
		return new_value

var _last_input_dir: float = 1.0

var target_rotation_y: float = -90.0 * (PI / 180.0) # Start facing right

@onready var _current_double_jumps: int = _max_jump_count

@onready var _current_air_dashes: int = _max_airdash_count


@onready var model: Node3D = $Miwa

@onready var sfx_jump: AudioStreamPlayer3D = %sfx_jump
@onready var sfx_death: AudioStreamPlayer3D = %sfx_death
@onready var sfx_dash: AudioStreamPlayer3D = %sfx_dash

@onready var _animation_player: AnimationPlayer = $Miwa/AnimationPlayer

func _ready() -> void:
	_animation_player.speed_scale = 3
	spawn_position = global_position
	SignalManager.player_death.connect(_kill_player)
	SignalManager.game_started.emit()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_handle_gravity(delta)

	input_dir = Input.get_axis("move_left", "move_right")

	_handle_jump()
	_handle_movement(delta)
	_handle_rotation(delta)
	_check_fall()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") && !_is_dead:
		_handle_dash()



func _handle_dash():
	if is_on_floor():
		_current_air_dashes = _max_airdash_count
		_animation_player.play("Dash")
	sfx_dash.play()
	if _current_air_dashes > 0:
		_set_jump_dir_to_input_dir()
		_dash_velocity = _dash_strengh
		if (_dash_tween):
			_dash_tween.stop()
		_dash_tween = create_tween()
		_dash_tween.tween_property(self, "_dash_velocity", 0, 0.3).set_ease(Tween.EASE_OUT)
		_current_air_dashes -= 1
		_animation_player.play("Dash")
	sfx_dash.play()



func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		_current_air_dashes = _max_airdash_count
		_current_double_jumps = _max_jump_count

func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return

	if is_on_floor():
		velocity.y = _jump_strengh
		sfx_jump.play()
		_current_double_jumps = _max_jump_count
		_set_jump_dir_to_input_dir()
		_animation_player.play("Jump")

	elif _current_double_jumps > 0:
		velocity.y = _jump_strengh
		sfx_jump.play()
		_current_double_jumps -= 1
		_animation_player.play("Jump")

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
			if _animation_player.current_animation != "Walkcycle" && _animation_player.current_animation != "Jump":
				_animation_player.play("Walkcycle")
		else:
			_apply_velocity_decay(delta, _velocity_decay_speed*_floor_velocity_decay_multiplier)
			if is_zero_approx(velocity.x) && _animation_player.current_animation != "Jump":
				_animation_player.play("Idle")
	else:
		if input_dir && _is_input_jump_direction(input_dir):
			velocity.x = input_dir * (SPEED + _dash_velocity)
		else:
			_apply_velocity_decay(delta, _velocity_decay_speed)
			if _dash_velocity != 0:
				velocity.x = _last_input_dir * _dash_velocity

	# Lock Z-axis movement
	velocity.z = 0
	move_and_slide()

func _apply_velocity_decay(delta, velocity_decay):
	if velocity_decay != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * velocity_decay * delta)
	else:
		velocity.x = 0


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
	_is_dead = true
	sfx_death.play()
	_animation_player.speed_scale = 1.0
	_animation_player.play("Death")
	await get_tree().create_timer(_animation_player.current_animation_length).timeout
	_animation_player.speed_scale = 3.0
	global_position = spawn_position
	velocity = Vector3.ZERO
	_is_dead = false
	SignalManager.game_started.emit()
