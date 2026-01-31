class_name Stopwatch
extends Node

signal minute_changed(minute: int)

var time_elapsed: float = 0.0
var _minutes_elapsed: int:
	set(new_value):
		if _minutes_elapsed != new_value:
			minute_changed.emit(new_value)
			_minutes_elapsed = new_value

func _ready() -> void:
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_1_sec_passed)
	timer.start(1)

func _on_1_sec_passed() -> void:
	time_elapsed += 1
	@warning_ignore("integer_division")
	_minutes_elapsed = int(roundi(time_elapsed)/60)