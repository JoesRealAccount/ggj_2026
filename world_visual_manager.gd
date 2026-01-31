extends Node

const WORLDS: Dictionary = {
	"DEPRESSION": "world_one_transparency",
	"HAPPINESS": "world_two_transparency"
}

## The percentage of transparency till which thi hitbox will stay toggled of/on
@export_range(0.0, 1.0) var hitbox_threshold: float = 0.8

var world_one_transparency: float:
	set(new_value):
		get_tree().set_group("world_depression", "transparency", new_value)
		_world_one_hitbox_toggle = _should_hitbox_by_transparency(_world_one_hitbox_toggle, new_value)
		world_one_transparency = new_value
		return new_value

var _world_one_hitbox_toggle = false:
	set(new_value):
		if _world_one_hitbox_toggle != new_value:
			get_tree().set_group("world_depression", "disabled", !new_value)
		_world_one_hitbox_toggle = new_value
		return new_value

var world_two_transparency: float:
	set(new_value):
		get_tree().set_group("world_happiness", "transparency", new_value)
		_world_two_hitbox_toggle = _should_hitbox_by_transparency(_world_two_hitbox_toggle, new_value)
		world_two_transparency = new_value
		return new_value


var _world_two_hitbox_toggle = true:
	set(new_value):
		get_tree().set_group("world_happiness", "disabled", !new_value)
		_world_two_hitbox_toggle = _should_hitbox_by_transparency(_world_two_hitbox_toggle, new_value)
		_world_two_hitbox_toggle = new_value
		return new_value

## Returns if a certain hitbox should be enabled at the given amount of transparency
func _should_hitbox_by_transparency(hitbox_toggle: bool, transparency: float) -> bool:
	if hitbox_toggle && transparency > hitbox_threshold:
		hitbox_toggle = false
	elif !hitbox_toggle && transparency < hitbox_threshold:
		hitbox_toggle = true
	return hitbox_toggle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.world_toggled_is_depression.connect(_toggle_worlds)

func _toggle_worlds(is_depression: bool):
	_kill_all_current_tweens()
	match is_depression:
		true:
			_tween_transparency(WORLDS.HAPPINESS, 1.0, 2.0)
			_tween_transparency(WORLDS.DEPRESSION, 0.0, 0.0)
		_:
			_tween_transparency(WORLDS.DEPRESSION, 1.0, 2.0)
			_tween_transparency(WORLDS.HAPPINESS, 0.0, 0.0)

func _kill_all_current_tweens():
	for tween: Tween in _current_tweens:
		tween.kill()
	_current_tweens.clear()

func _tween_transparency(world: String, new_transparency: float, tween_time_sec: float):
	assert(WORLDS.values().has(world))
	var new_tween: Tween = create_tween()
	new_tween.tween_property(self, world, new_transparency, tween_time_sec)
	_current_tweens.append(new_tween)


var _current_tweens:Array[Tween]
