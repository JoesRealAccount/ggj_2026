extends Node

const WORLDS: Dictionary = {
	"DEPRESSION": "world_one_transparency",
	"HAPPINESS": "world_two_transparency"
}

var world_one_transparency: float:
	set(new_value):
		get_tree().set_group("world_happiness", "transparency", new_value)
		return new_value

var _world_one_hitbox_toggle = true:
	set(new_value):
		get_tree().set_group("world_happiness", "disabled", new_value)
		return new_value

var world_two_transparency: float:
	set(new_value):
		get_tree().set_group("world_depression", "transparency", new_value)
		return new_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tween_transparency(WORLDS.DEPRESSION, 1.0, 10)

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
