extends Node

var depression_transparency: float = 0.9
var happiness_transparency: float = 0.0

var game_stopwatch: Stopwatch
var game_completion_time: float

signal gamestart_finished

func _ready() -> void:
	SignalManager.game_started.connect(_on_game_started)
	SignalManager.game_won.connect(_on_game_won)

func _on_game_started():
	if game_stopwatch:
		game_stopwatch.queue_free()
	game_stopwatch = Stopwatch.new()
	add_child(game_stopwatch)
	gamestart_finished.emit()

func _on_game_won():
	game_completion_time += game_stopwatch.time_elapsed
