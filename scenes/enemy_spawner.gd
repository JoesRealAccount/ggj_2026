extends Path3D
@export var _mob_spawn_location: PathFollow3D

@export_group("FlyingObjects")
@export var _depression_obstacles: Array[PackedScene]
@export var _depression_platforms: Array[PackedScene]
@export var _happiness_obstacles: Array[PackedScene]
@export var _happiness_platforms: Array[PackedScene]

@export var depression_obstacle_timer: Timer = Timer.new()
@export var depression_platform_timer: Timer = Timer.new()
@export var happiness_obstacle_timer: Timer = Timer.new()
@export var happiness_platform_timer: Timer = Timer.new()

@onready var _default_depression_obstacle_timer: float = depression_obstacle_timer.wait_time
@onready var _default_depression_platform_timer: float = depression_platform_timer.wait_time
@onready var _default_happiness_obstacle_timer: float = happiness_obstacle_timer.wait_time
@onready var _default_happiness_platform_timer: float = happiness_platform_timer.wait_time


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	depression_obstacle_timer.start()
	depression_obstacle_timer.timeout.connect(_spawn_random_body_from_array.bind(_depression_obstacles, depression_obstacle_timer, _default_depression_obstacle_timer))
	depression_platform_timer.start()
	depression_platform_timer.timeout.connect(_spawn_random_body_from_array.bind(_depression_platforms, depression_platform_timer, _default_depression_platform_timer))
	happiness_obstacle_timer.start()
	happiness_obstacle_timer.timeout.connect(_spawn_random_body_from_array.bind(_happiness_obstacles, happiness_obstacle_timer, _default_happiness_obstacle_timer))
	happiness_platform_timer.start()
	happiness_platform_timer.timeout.connect(_spawn_random_body_from_array.bind(_happiness_platforms, happiness_platform_timer, _default_happiness_platform_timer))

func _spawn_random_body_from_array(_spawn_array: Array[PackedScene], restart_timer: Timer, default_time):
	var new_body: StaticBody3D = _spawn_array[randi_range(0, _spawn_array.size()-1)].instantiate()
	_mob_spawn_location.progress_ratio = randf()
	new_body.position = _mob_spawn_location.position
	add_child(new_body)
	restart_timer.start(randf_range(1, default_time))




	
	
